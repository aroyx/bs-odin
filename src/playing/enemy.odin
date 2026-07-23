package playing

import hm "core:container/handle_map"
import "core:math/linalg"
import "core:math/rand"

import "../camera"

import "vendor:box2d"

@(private = "file")
speed: f32 : 15.0

@(private)
enemyStateMachineUpdate :: proc(dt: f32) {
	p_entity := hm.get(&entities, player_handle)
	p_pos := p_entity.pos

	it := hm.iterator_make(&entities)
	for e, handle in hm.iterate(&it) {
		#partial switch &entity in &e.data {
		case EnemyData:
			if entity.state == .DEAD do continue

			entity.target_time -= dt
			entity.stun_cooldown -= dt
			entity.attack_cooldown -= dt

			switch entity.state {
			case .ROAM:
				updateEnemyRoam(e, p_pos)
			case .CHASE:
				updateEnemyChase(e, p_pos)
			case .ATTACK:
				if !updateEnemyAttack(e, p_pos) do continue
			case .HURT:
				if entity.stun_cooldown <= 0 {
					changeEnemyState(&entity, .CHASE)
				}

			case .DEAD:
				continue
			}

			if entity.stun_cooldown > 0 && entity.state != .HURT {
				box2d.Body_SetLinearVelocity(e.physics_id, {})
			}
		}
	}
}

@(private = "file")
updateEnemyRoam :: proc(entity: ^Entity, p_pos: [2]f32) {
	e_pos := entity.pos
    data := &entity.data.(EnemyData)

	dist := linalg.length(p_pos - e_pos)
	cs := camera.state.cs

	if dist <= cs * 10 { 	// player is close attack
		changeEnemyState(data, .CHASE)
		playSound(.PLAYER_SHOCKED)
	} else if linalg.length(e_pos - data.target_pos) < cs * 0.1 { 	// already arrived at target.
		if data.animation.current_animation != .IDLE {
			changeAnimation(&data.animation, .IDLE)
		}

		if data.target_time <= 0 { 	// find a new target
			x := (rand.float32() * 10 - 5) * cs
			y := (rand.float32() * 10 - 5) * cs
			t := rand.float32() * 3 + 2

			data.target_pos = {e_pos.x + x, e_pos.y + y}
			data.target_time = t

			if data.animation.current_animation != .WALKING {
				changeAnimation(&data.animation, .WALKING)
			}
		}
	} else if data.target_time <= 0 {
		x := (rand.float32() * 20 - 10) * cs
		y := (rand.float32() * 20 - 10) * cs
		t := rand.float32() * 5 + 5

		data.target_pos = {e_pos.x + x, e_pos.y + y}
		data.target_time = t

		if data.animation.current_animation != .WALKING {
			changeAnimation(&data.animation, .WALKING)
		}
	} else { 	// go towards target
		dir := linalg.normalize0(data.target_pos - e_pos) * speed * 0.25
		box2d.Body_ApplyForceToCenter(entity.physics_id, dir, true)

		if dir.x < 0 do data.animation.flip_x = -1
		else if dir.x > 0 do data.animation.flip_x = 1
	}
}

@(private = "file")
updateEnemyChase :: proc(entity: ^Entity, p_pos: [2]f32) {
	e_pos := entity.pos
    data := &entity.data.(EnemyData)

	dist := linalg.length(p_pos - e_pos)
	cs := camera.state.cs

	if dist >= cs * 15 { 	// player ran too far
		changeEnemyState(data, .ROAM)
	} else if dist <= cs * 2 { 	// attack
		if data.attack_cooldown <= 0 {
			changeEnemyState(data, .ATTACK)
		} else {
			if data.animation.current_animation != .IDLE {
				changeAnimation(&data.animation, .IDLE)
			}
		}
	} else {
		dir := linalg.normalize0(p_pos - e_pos) * speed * 0.5
		box2d.Body_ApplyForceToCenter(entity.physics_id, dir, true)

		if dir.x < 0 do data.animation.flip_x = -1
		else if dir.x > 0 do data.animation.flip_x = 1

		if data.animation.current_animation != .RUNNING {
			changeAnimation(&data.animation, .RUNNING)
		}
	}
}

updateEnemyAttack :: proc(entity: ^Entity, p_pos: [2]f32) -> bool {
	e_pos := entity.pos
    data := &entity.data.(EnemyData)

	dist := linalg.length(p_pos - e_pos)
	cs := camera.state.cs
	speed: f32 = 5.0

	anim_length := f32(data.animation.current_animation_length / 1000)
	land_hit_stall := anim_length * 0.3

	if anim_length - data.stun_cooldown >= land_hit_stall && !data.attack_landed {
		data.attack_landed = true

        p_entity, ok := hm.get(&entities, player_handle) 
		p_data, ok1 := &p_entity.data.(PlayerData)

		if !ok || !ok1 do return false
		if p_data.state == .DEAD do return false

		p_entity.health -= 15

		if p_entity.health < 0 {
			changePlayerState(p_data, .DEAD)
		} else {
			changePlayerState(p_data, .HURT)
		}

		knock_dir := linalg.normalize0(p_pos - e_pos)
		force: f32 = 5
		impulse: box2d.Vec2 = {knock_dir.x * force, knock_dir.y * force}

		box2d.Body_ApplyLinearImpulseToCenter(p_entity.physics_id, impulse, true)
	}

	if data.stun_cooldown <= 0 {
		changeEnemyState(data, .CHASE)
	}

	return true
}

@(private)
changeEnemyState :: proc(data: ^EnemyData, new_state: EnemyState) {
	if data.state == new_state do return

	data.state = new_state

	switch data.state {
	case .ROAM:
		data.target_time = 0
	case .CHASE:
		changeAnimation(&data.animation, .RUNNING)
	case .ATTACK:
		data.state = .ATTACK
		data.attack_cooldown = 1
		data.target_time = 0
		data.attack_landed = false
		changeAnimation(&data.animation, .SLASHING)
		data.stun_cooldown = data.animation.current_animation_length / 1000
	case .HURT:
		changeAnimation(&data.animation, .HURT)
		data.stun_cooldown = data.animation.current_animation_length / 1000
	case .DEAD:
		changeAnimation(&data.animation, .DYING)
		data.stun_cooldown = data.animation.current_animation_length / 1000
	}
}
