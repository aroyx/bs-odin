package playing

import "../camera"
import "core:math/linalg"
import "core:math/rand"
import "vendor:box2d"

enemyStateMachineUpdate :: proc(dt: f32) {
	p_pos := entities.pos[0]

	for i in 0 ..< len(entities) {

		#partial switch &entity in entities[i].data {
		case EnemyData:
			if entity.state == .DEAD do continue

			e_pos := entities[i].pos

			dist := linalg.length(p_pos - e_pos)
			cs := camera.state.cs
			speed: f32 = 5.0

			entity.target_time -= dt
			entity.stun_cooldown -= dt
			entity.attack_cooldown -= dt

			switch entity.state {
			case .ROAM:
				if dist <= cs * 10 { 	// player is close attack
					entity.state = .CHASE
					changeAnimation(&entity.animation, .RUNNING)
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

			case .CHASE:
				if dist >= cs * 15 { 	// player ran too far
					entity.state = .ROAM
					entity.target_time = 0
				} else if dist <= cs * 2 { 	// attack
					if entity.attack_cooldown <= 0 {
						entity.state = .ATTACK
						entity.attack_cooldown = 1
						entity.target_time = 0
						entity.attack_landed = false
						changeAnimation(&entity.animation, .SLASHING)
						entity.stun_cooldown = entity.animation.current_animation_length / 1000

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

			case .ATTACK:
				anim_length := f32(entity.animation.current_animation_length / 1000)
				land_hit_stall := anim_length * 0.3

				if anim_length - entity.stun_cooldown >= land_hit_stall && !entity.attack_landed {
					entity.attack_landed = true
					p_data, ok := &entities[0].data.(PlayerData)

					if !ok do continue
					if p_data.state == .DEAD do continue

					entities[0].health.health -= 15

					if entities[0].health.health < 0 {
						p_data.state = .DEAD
						changeAnimation(&p_data.animation, .DYING)
						p_data.stun_cooldown = p_data.animation.current_animation_length / 1000
					} else {
						p_data.state = .HURT
						changeAnimation(&p_data.animation, .HURT)
						p_data.stun_cooldown = p_data.animation.current_animation_length / 1000
					}

					knock_dir := linalg.normalize0(p_pos - e_pos)
					force: f32 = 5
					impulse: box2d.Vec2 = {knock_dir.x * force, knock_dir.y * force}

					box2d.Body_ApplyLinearImpulseToCenter(entities[0].physics_id, impulse, true)
				}

				if entity.stun_cooldown <= 0 {
					entity.state = .CHASE
					changeAnimation(&entity.animation, .RUNNING)
				}

			case .HURT:
				if entity.stun_cooldown <= 0 {
					entity.state = .CHASE
					changeAnimation(&entity.animation, .RUNNING)
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
