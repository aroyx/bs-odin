package playing

import "../camera"
import "vendor:box2d"

import rl "vendor:raylib"

playerStateMachineUpdate :: proc(dt: f32) {
	if pData, ok := &entities.data[0].(PlayerData); ok {

		x_axis: f32 = 0
		y_axis: f32 = 0

		if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP) do y_axis = -1
		if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN) do y_axis = 1
		if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT) do x_axis = -1
		if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) do x_axis = 1

		running := rl.IsKeyDown(.C)
		attacking := rl.IsKeyDown(.X)

		pData.attack_cooldown -= dt
		pData.stun_cooldown -= dt

		switch pData.state {
		case .ATTACK:
			if pData.stun_cooldown <= 0 {
				pData.state = .IDLE
				changeAnimation(&pData.animation, .IDLE)
			}

			speed: f32 = running ? 10 : 5
			force: box2d.Vec2 = {x_axis * speed, y_axis * speed}
			box2d.Body_ApplyForceToCenter(entities.physics_id[0], force, true)

		case .IDLE, .WALK, .RUN:
			if attacking {
				pData.state = .ATTACK
				pData.attack_cooldown = 2
				pData.stun_cooldown = 0.4 // complete animation
				changeAnimation(&pData.animation, .SLASHING)

				// use box2d to detect attack hit later
			} else {
				speed: f32 = running ? 10 : 5
				force: box2d.Vec2 = {x_axis * speed, y_axis * speed}
				box2d.Body_ApplyForceToCenter(entities.physics_id[0], force, true)

				if x_axis != 0 || y_axis != 0 {
					camera.startTagAlong(entities.pos[0])

					if running {
						pData.state = .RUN
						if pData.animation.current_animation != .RUNNING {
							changeAnimation(&pData.animation, .RUNNING)
						}
					} else {
						pData.state = .WALK
						if pData.animation.current_animation != .WALKING {
							changeAnimation(&pData.animation, .WALKING)
						}
					}
				} else {
					pData.state = .IDLE
					changeAnimation(&pData.animation, .IDLE)
				}

				if x_axis < 0 {
					pData.animation.flip_x = -1
				} else if x_axis > 0 {
					pData.animation.flip_x = 1
				}
			}

		case .DEAD, .JUMP:
		// revive? idk
		}

		if pData.stun_cooldown > 0 {
			box2d.Body_SetLinearVelocity(entities.physics_id[0], {})
		}
	}
}
