package playing

import hm "core:container/handle_map"
import "core:math"
import "core:math/linalg"
import "core:time"

import "../camera"
import "../ui"
import "../utils"

import "vendor:box2d"
import rl "vendor:raylib"

@(private = "file")
attack_landed := false
@(private = "file")
running := false
@(private = "file")
attacking := false
@(private = "file")
dir: [2]f32 = {}
@(private = "file")
regen_wait: f32 = 1000
@(private = "file")
death_time: time.Time
@(private = "file")
footstep_timer: f32 = 0.5
@(private = "file")
breathed := false
@(private = "file")
heartbeat_timer: f32 = 0.5

@(private)
playerStateMachineUpdate :: proc(dt: f32) {
	p_entity := hm.get(&entities, player_handle)
	p_data, ok := &p_entity.data.(PlayerData)

	if !ok do return

	dir = {}
	running = false
	attacking = false

	if rl.IsKeyDown(.W) do dir.y = -1
	if rl.IsKeyDown(.S) do dir.y = 1
	if rl.IsKeyDown(.A) do dir.x = -1
	if rl.IsKeyDown(.D) do dir.x = 1

	dir = linalg.normalize0(dir)

	running = rl.IsKeyDown(.LEFT_SHIFT) || ui_run
	attacking = ui_attack

	if !utils.global.options.on_mobile {
		attacking = attacking || rl.IsMouseButtonDown(.LEFT)
	} else {
		attacking = attacking || rl.IsKeyDown(.X)
	}

	p_data.attack_cooldown -= dt
	p_data.stun_cooldown -= dt
	p_data.bomb_cooldown -= dt

	regen_wait -= dt
	footstep_timer -= dt
	heartbeat_timer -= dt

	attack_button_data.cool_down = p_data.attack_cooldown

	if linalg.length(joy_dir) > 0 {
		dir = linalg.normalize0(joy_dir)

		if linalg.length(joy_dir) >= 0.5 {
			running = true
		} else {
			running = false
		}
	}

	if regen_wait <= 0 && p_data.state != .DEAD && p_entity.health < 100 {
		p_entity.health += 10
		regen_wait = 1

		if !breathed {
			playSound(.BREATHE)
			breathed = true
		}
	}

	if p_entity.health <= 30 && p_data.state != .DEAD {
		rl.SetMasterVolume(0.5)
		if heartbeat_timer <= 0 {
			playSound(.HEARTBEAT)
			heartbeat_timer = 1.0
		}
	} else {
		rl.SetMasterVolume(1)
	}

	switch p_data.state {
	case .ATTACK:
		updatePlayerAttack(p_data)

	case .IDLE, .WALK, .RUN:
		updatePlayerMovement(p_data)

	case .HURT:
		if p_data.stun_cooldown <= 0 {
			changePlayerState(p_data, .IDLE)
			regen_wait = 5
			breathed = false
		}

	case .DEAD:
		diff := f32(time.duration_milliseconds(time.diff(death_time, time.now())))

		if diff >= 3000 {
			playing_end = true
		}
	case .BOMB_AIM:
		updatePlayerBombAim(p_data)
	case .BOMB_THROW:
		updatePlayerBombThrow(p_data)
	}

	if p_data.stun_cooldown > 0 && p_data.state != .HURT {
		box2d.Body_SetLinearVelocity(p_entity.physics_id, {})
	}
}

@(private = "file")
updatePlayerAttack :: proc(p_data: ^PlayerData) {
	p_entity := hm.get(&entities, player_handle)
	if p_data.stun_cooldown <= 0 {
		changePlayerState(p_data, .IDLE)
	}

	speed: f32 = running ? 20 : 10
	force: box2d.Vec2 = dir * speed
	box2d.Body_ApplyForceToCenter(p_entity.physics_id, force, true)

	anim_length := f32(p_data.animation.current_animation_length / 1000)
	land_hit_stall := anim_length * 0.3

	if anim_length - p_data.stun_cooldown >= land_hit_stall && !attack_landed {
		attack_landed = true

		p_pos := p_entity.pos
		cs := camera.state.cs

		box_w := cs * 2.5
		box_h := cs * 3

		box_x := p_data.animation.flip_x == 1 ? p_pos.x : p_pos.x - box_w
		box_y := p_pos.y - (box_h * 0.5)

		attak_box: rl.Rectangle = {
			x      = box_x,
			y      = box_y,
			width  = box_w,
			height = box_h,
		}

		it := hm.iterator_make(&entities)
		attack_hit := false

		for e, handle in hm.iterate(&it) {
			if handle == player_handle do continue

			e_pos := e.pos
			atk_dir := e_pos - p_pos

			if math.abs(atk_dir.x) > cs * 4 || math.abs(atk_dir.y) > cs * 4 do continue // to far to do smth

			if !rl.CheckCollisionPointRec(e_pos, attak_box) do continue

			switch &data in &e.data {
			case PlayerData:
				continue // wtf

			case EnemyData:
				e.health -= 30

				if e.health <= 0 {
					changeEnemyState(&data, .DEAD)
				} else {
					changeEnemyState(&data, .HURT)
				}

				knock_dir := linalg.normalize0(atk_dir)
				force: f32 = 5
				impulse: box2d.Vec2 = {knock_dir.x * force, knock_dir.y * force}

				box2d.Body_ApplyLinearImpulseToCenter(e.physics_id, impulse, true)

				// sounds
				playSound(.ATTACK)
				attack_hit = true
			case FoliageData:
				data.is_dying = true
				data.time_left = 0.5

				playSound(.CUT_FOLIAGE)
				attack_hit = true
			case BombData:
			}
		}

		if !attack_hit {
			playSound(.ATTACK_MISS)
		}
	}
}

@(private = "file")
updatePlayerMovement :: proc(p_data: ^PlayerData) {
	if attacking && p_data.attack_cooldown <= 0 {
		changePlayerState(p_data, .ATTACK)
	} else {
		if rl.IsMouseButtonPressed(.RIGHT) {
			if p_data.bomb_cooldown <= 0 {
				changePlayerState(p_data, .BOMB_AIM)
				return
			}
		}

		speed: f32 = running ? 10 : 5
		force: box2d.Vec2 = dir * speed
		p_entity := hm.get(&entities, player_handle)

		box2d.Body_ApplyForceToCenter(p_entity.physics_id, force, true)

		if dir.x != 0 || dir.y != 0 {
			camera.startTagAlong(p_entity.pos)

			if running {
				changePlayerState(p_data, .RUN)
				if footstep_timer <= 0 {
					footstep_timer = 0.25
					playSound(.FOOTSTEP)
				}
			} else {
				changePlayerState(p_data, .WALK)
				if footstep_timer <= 0 {
					footstep_timer = 0.5
					playSound(.FOOTSTEP)
				}
			}
		} else {
			changePlayerState(p_data, .IDLE)
		}

		if dir.x < 0 {
			p_data.animation.flip_x = -1
		} else if dir.x > 0 {
			p_data.animation.flip_x = 1
		}
	}
}

@(private = "file")
updatePlayerBombAim :: proc(p_data: ^PlayerData) {
	if rl.IsMouseButtonPressed(.RIGHT) {
		changePlayerState(p_data, .IDLE)
		return
	}

	speed: f32 = running ? 10 : 5
	force: box2d.Vec2 = dir * speed
	p_entity := hm.get(&entities, player_handle)

	box2d.Body_ApplyForceToCenter(p_entity.physics_id, force, true)

	if dir.x != 0 || dir.y != 0 {
		camera.startTagAlong(p_entity.pos)

		if running {
			if p_data.animation.current_animation != .RUNNING {
				changeAnimation(&p_data.animation, .RUNNING)
			}
			if footstep_timer <= 0 {
				footstep_timer = 0.25
				playSound(.FOOTSTEP)
			}
		} else {
			if p_data.animation.current_animation != .WALKING {
				changeAnimation(&p_data.animation, .WALKING)
			}
			if footstep_timer <= 0 {
				footstep_timer = 0.5
				playSound(.FOOTSTEP)
			}
		}
	} else {
		if p_data.animation.current_animation != .IDLE {
			changeAnimation(&p_data.animation, .IDLE)
		}
	}

	if dir.x < 0 {
		p_data.animation.flip_x = -1
	} else if dir.x > 0 {
		p_data.animation.flip_x = 1
	}

	if attacking { 	// attaking in bomb_aim means we throw bomb
		changePlayerState(p_data, .BOMB_THROW)

		p_pos := p_entity.pos
		m_pos := rl.GetMousePosition()

		cs := camera.state.cs
		cp := camera.camPos

		camTopLeft: linalg.Vector2f32 = {
			math.clamp(
				cp.x - (cs * camera.state.hcc * 0.5),
				0,
				cs * (utils.MAP_SIZE - camera.state.hcc),
			),
			math.clamp(
				cp.y - (cs * camera.state.vcc * 0.5),
				0,
				cs * (utils.MAP_SIZE - camera.state.vcc),
			),
		}

		t_pos: [2]f32 = {
			camTopLeft.x + m_pos.x - camera.state.x_offset,
			camTopLeft.y + m_pos.y - camera.state.y_offset,
		}

		p_pos.y -= (cs * 2)

		spawnBomb(p_pos, t_pos)

		if p_pos.x > t_pos.x {
			p_data.animation.flip_x = -1
		}; if p_pos.x < t_pos.x {
			p_data.animation.flip_x = 1
		}

	}
}

@(private = "file")
updatePlayerBombThrow :: proc(p_data: ^PlayerData) {
	if p_data.stun_cooldown <= 0 {
		changePlayerState(p_data, .IDLE)
		return
	}

}

@(private)
changePlayerState :: proc(data: ^PlayerData, new_state: PlayerState) {
	if data.state == new_state do return

	if data.state == .BOMB_AIM {
		ui.changeMouseState(.NORMAL)

		if utils.global.options.on_mobile {
			ui.showCursor()
		} else {
			ui.hideCursor()
		}
	}

	data.state = new_state

	switch data.state {
	case .IDLE:
		if data.animation.current_animation != .IDLE {
			changeAnimation(&data.animation, .IDLE)
		}
	case .WALK:
		if data.animation.current_animation != .WALKING {
			changeAnimation(&data.animation, .WALKING)
		}
	case .RUN:
		if data.animation.current_animation != .RUNNING {
			changeAnimation(&data.animation, .RUNNING)
		}
	case .ATTACK:
		changeAnimation(&data.animation, .SLASHING)
		data.attack_cooldown = 1
		data.stun_cooldown = data.animation.current_animation_length / 1000
		attack_landed = false
		regen_wait = 5
		breathed = false
	case .HURT:
		changeAnimation(&data.animation, .HURT)
		data.stun_cooldown = data.animation.current_animation_length / 1000
		regen_wait = 5
		breathed = false
		playSound(.HURT)
		camera.startShake(100)
	case .DEAD:
		playSound(.DYING)
		changeAnimation(&data.animation, .DYING)
		data.stun_cooldown = data.animation.current_animation_length / 1000
		camera.startShake(300)
		death_time = time.now()
	case .BOMB_AIM:
		ui.showCursor()
		ui.changeMouseState(.TARGET)
	case .BOMB_THROW:
		changeAnimation(&data.animation, .THROWING)
		data.stun_cooldown = data.animation.current_animation_length / 1000
		data.bomb_cooldown = 3
		attack_landed = false
		regen_wait = 5
		breathed = false
	}
}
