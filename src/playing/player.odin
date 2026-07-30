package playing

import hm "core:container/handle_map"
import "core:math"
import "core:math/linalg"

import "../camera"

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

@(private)
playerStateMachineUpdate :: proc(dt: f32) {
	p_entity := hm.get(&entities, player_handle)
	p_data, ok := &p_entity.data.(PlayerData)

	if !ok do return

	dir = {}
	running = false
	attacking = false

	if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP) do dir.y = -1
	if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN) do dir.y = 1
	if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT) do dir.x = -1
	if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) do dir.x = 1

	dir = linalg.normalize0(dir)

	running = rl.IsKeyDown(.C) || ui_run
	attacking = rl.IsKeyDown(.X) || ui_attack

	p_data.attack_cooldown -= dt
	p_data.stun_cooldown -= dt
	regen_wait -= dt

    attack_button_data.cool_down = p_data.attack_cooldown

	if regen_wait <= 0 && p_data.state != .DEAD && p_entity.health < 100 {
		p_entity.health += 10
		regen_wait = 1
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
		}

	case .DEAD, .JUMP:
	// revive? idk
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
		for e, handle in hm.iterate(&it) {
			if handle == player_handle do continue

			e_pos := e.pos
			atk_dir := e_pos - p_pos

			if math.abs(atk_dir.x) > cs * 4 || math.abs(atk_dir.y) > cs * 4 do continue // to far to do smth

			if !rl.CheckCollisionPointRec(e_pos, attak_box) do continue

			// can be flowers too!
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
			case FoliageData:
				data.is_dying = true
				data.time_left = 0.5
			}
		}
	}
}

@(private = "file")
updatePlayerMovement :: proc(p_data: ^PlayerData) {
	if attacking && p_data.attack_cooldown <= 0 {
		changePlayerState(p_data, .ATTACK)
	} else {
		speed: f32 = running ? 10 : 5
		force: box2d.Vec2 = dir * speed
		p_entity := hm.get(&entities, player_handle)

		box2d.Body_ApplyForceToCenter(p_entity.physics_id, force, true)

		if dir.x != 0 || dir.y != 0 {
			camera.startTagAlong(p_entity.pos)

			if running {
				changePlayerState(p_data, .RUN)
			} else {
				changePlayerState(p_data, .WALK)
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

@(private)
changePlayerState :: proc(data: ^PlayerData, new_state: PlayerState) {
	if data.state == new_state do return

	data.state = new_state

	switch data.state {
	case .IDLE:
		// playSound(.PLAYER_IDLE)
		if data.animation.current_animation != .IDLE {
			changeAnimation(&data.animation, .IDLE)
		}
	case .WALK:
		// playSound(.PLAYER_IDLE)
		if data.animation.current_animation != .WALKING {
			changeAnimation(&data.animation, .WALKING)
		}
	case .RUN:
		// playSound(.PLAYER_IDLE)
		if data.animation.current_animation != .RUNNING {
			changeAnimation(&data.animation, .RUNNING)
		}
	case .JUMP:
	//idk man
	case .ATTACK:
		changeAnimation(&data.animation, .SLASHING)
		data.attack_cooldown = 1
		data.stun_cooldown = data.animation.current_animation_length / 1000
		attack_landed = false
		regen_wait = 5
		playSound(.PLAYER_ATTACK)
	case .HURT:
		changeAnimation(&data.animation, .HURT)
		data.stun_cooldown = data.animation.current_animation_length / 1000
		regen_wait = 5
		playSound(.PLAYER_HURT)
	case .DEAD:
		playSound(.PLAYER_DEAD)
		changeAnimation(&data.animation, .DYING)
		data.stun_cooldown = data.animation.current_animation_length / 1000
	}
}
