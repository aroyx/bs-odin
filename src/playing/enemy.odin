package playing

import "../camera"
import "core:math/linalg"
import "core:math/rand"
import "vendor:box2d"

@(private)
enemyStateMachineUpdate :: proc(dt: f32) {
	p_pos := entities.pos[0]

	for i in 0 ..< len(entities) {

		#partial switch &entity in entities[i].data {
		case EnemyData:
			if entity.state == .DEAD do continue

			entity.target_time -= dt
			entity.stun_cooldown -= dt
			entity.attack_cooldown -= dt

			switch entity.state {
			case .ROAM:
				updateEnemyRoam(&entity, i)
			case .CHASE:
				updateEnemyChase(&entity, i)
			case .ATTACK:
				if !updateEnemyAttack(&entity, i) do continue
			case .HURT:
				if entity.stun_cooldown <= 0 {
					changeEnemyState(&entity, .CHASE)
				}

			case .DEAD:
				continue
			}

			if entity.stun_cooldown > 0 && entity.state != .HURT {
				box2d.Body_SetLinearVelocity(entities.physics_id[i], {})
			}
		}
	}
}

@(private = "file")
updateEnemyRoam :: proc(entity: ^EnemyData, i: int) {
	e_pos := entities[i].pos
	p_pos := entities.pos[0]

	dist := linalg.length(p_pos - e_pos)
	cs := camera.state.cs
	speed: f32 = 5.0

	if dist <= cs * 10 { 	// player is close attack
		changeEnemyState(entity, .CHASE)
	} else if linalg.length(e_pos - entity.target_pos) < cs * 0.1 { 	// already arrived at target.
		if entity.animation.current_animation != .IDLE {
			changeAnimation(&entity.animation, .IDLE)
		}

		if entity.target_time <= 0 { 	// find a new target
			x := (rand.float32() * 10 - 5) * cs
			y := (rand.float32() * 10 - 5) * cs
			t := rand.float32() * 3 + 2

			entity.target_pos = {e_pos.x + x, e_pos.y + y}
			entity.target_time = t

			if entity.animation.current_animation != .WALKING {
				changeAnimation(&entity.animation, .WALKING)
			}
		}
	} else if entity.target_time <= 0 {
		x := (rand.float32() * 20 - 10) * cs
		y := (rand.float32() * 20 - 10) * cs
		t := rand.float32() * 5 + 5

		entity.target_pos = {e_pos.x + x, e_pos.y + y}
		entity.target_time = t

		if entity.animation.current_animation != .WALKING {
			changeAnimation(&entity.animation, .WALKING)
		}
	} else { 	// go towards target
		dir := linalg.normalize0(entity.target_pos - e_pos) * speed * 0.5
		box2d.Body_ApplyForceToCenter(entities[i].physics_id, dir, true)

		if dir.x < 0 do entity.animation.flip_x = -1
		else if dir.x > 0 do entity.animation.flip_x = 1
	}
}

@(private = "file")
updateEnemyChase :: proc(entity: ^EnemyData, i: int) {
	e_pos := entities[i].pos
	p_pos := entities.pos[0]

	dist := linalg.length(p_pos - e_pos)
	cs := camera.state.cs
	speed: f32 = 5.0

	if dist >= cs * 15 { 	// player ran too far
		changeEnemyState(entity, .ROAM)
	} else if dist <= cs * 2 { 	// attack
		if entity.attack_cooldown <= 0 {
			changeEnemyState(entity, .ATTACK)
		} else {
			if entity.animation.current_animation != .IDLE {
				changeAnimation(&entity.animation, .IDLE)
			}
		}
	} else {
		dir := linalg.normalize0(p_pos - e_pos) * speed * 0.5
		box2d.Body_ApplyForceToCenter(entities[i].physics_id, dir, true)

		if dir.x < 0 do entity.animation.flip_x = -1
		else if dir.x > 0 do entity.animation.flip_x = 1

		if entity.animation.current_animation != .RUNNING {
			changeAnimation(&entity.animation, .RUNNING)
		}
	}
}

updateEnemyAttack :: proc(entity: ^EnemyData, i: int) -> bool {
	e_pos := entities[i].pos
	p_pos := entities.pos[0]

	dist := linalg.length(p_pos - e_pos)
	cs := camera.state.cs
	speed: f32 = 5.0

	anim_length := f32(entity.animation.current_animation_length / 1000)
	land_hit_stall := anim_length * 0.3

	if anim_length - entity.stun_cooldown >= land_hit_stall && !entity.attack_landed {
		entity.attack_landed = true
		p_data, ok := &entities[0].data.(PlayerData)

		if !ok do return false
		if p_data.state == .DEAD do return false

		entities[0].health.health -= 15

		if entities[0].health.health < 0 {
			changePlayerState(p_data, .DEAD)
		} else {
			changePlayerState(p_data, .HURT)
		}

		knock_dir := linalg.normalize0(p_pos - e_pos)
		force: f32 = 5
		impulse: box2d.Vec2 = {knock_dir.x * force, knock_dir.y * force}

		box2d.Body_ApplyLinearImpulseToCenter(entities[0].physics_id, impulse, true)
	}

	if entity.stun_cooldown <= 0 {
		changeEnemyState(entity, .CHASE)
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
