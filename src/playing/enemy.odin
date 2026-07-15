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
					// } else if dist <= cs * 2 { // attack
				} else {
					dir := linalg.normalize0(p_pos - e_pos) * speed * 0.5
					box2d.Body_ApplyForceToCenter(entities[i].physics_id, dir, true)

					if dir.x < 0 do entity.animation.flip_x = -1
					else if dir.x > 0 do entity.animation.flip_x = 1
                }
			case .ATTACK, .HURT:
			case .DEAD:
				continue
			}
		}
	}
}
