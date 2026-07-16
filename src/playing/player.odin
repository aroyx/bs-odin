package playing

import "../camera"
import "core:math"
import "core:math/linalg"

import "vendor:box2d"
import rl "vendor:raylib"

@(private = "file")
attack_landed := false

playerStateMachineUpdate :: proc(dt: f32) {
	if p_data, ok := &entities.data[0].(PlayerData); ok {

		x_axis: f32 = 0
		y_axis: f32 = 0

		if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP) do y_axis = -1
		if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN) do y_axis = 1
		if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT) do x_axis = -1
		if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) do x_axis = 1

		running := rl.IsKeyDown(.C)
		attacking := rl.IsKeyDown(.X)

		p_data.attack_cooldown -= dt
		p_data.stun_cooldown -= dt

		switch p_data.state {
		case .ATTACK:
			if p_data.stun_cooldown <= 0 {
				p_data.state = .IDLE
				changeAnimation(&p_data.animation, .IDLE)
			}

			speed: f32 = running ? 10 : 5
			force: box2d.Vec2 = {x_axis * speed, y_axis * speed}
			box2d.Body_ApplyForceToCenter(entities.physics_id[0], force, true)

			anim_length := f32(p_data.animation.current_animation_length / 1000)
			land_hit_stall := anim_length * 0.3

			if anim_length - p_data.stun_cooldown >= land_hit_stall && !attack_landed {
				attack_landed = true

				p_pos := entities.pos[0]
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

				for i in 1 ..< len(entities) {
					e_pos := entities.pos[i]
					dir := e_pos - p_pos

					if math.abs(dir.x) > cs * 4 || math.abs(dir.y) > cs * 4 do continue // to far to do smth

					if rl.CheckCollisionPointRec(e_pos, attak_box) {
						id := entities.physics_id[i]
						data, ok := &entities[i].data.(EnemyData)

						if !ok do continue

						entities[i].health.health -= 30

						if entities[i].health.health < 0 {
							data.state = .DEAD
							changeAnimation(&data.animation, .DYING)
							data.stun_cooldown = data.animation.current_animation_length / 1000
						} else {
							data.state = .HURT
							changeAnimation(&data.animation, .HURT)
							data.stun_cooldown = data.animation.current_animation_length / 1000
						}

						knock_dir := linalg.normalize0(dir)
						force: f32 = 5
						impulse: box2d.Vec2 = {knock_dir.x * force, knock_dir.y * force}

						box2d.Body_ApplyLinearImpulseToCenter(id, impulse, true)
					}
				}
			}

		case .IDLE, .WALK, .RUN:
			if attacking && p_data.attack_cooldown <= 0 {
				p_data.state = .ATTACK
				p_data.attack_cooldown = 1
				changeAnimation(&p_data.animation, .SLASHING)
				p_data.stun_cooldown = p_data.animation.current_animation_length / 1000
				attack_landed = false

			} else {
				speed: f32 = running ? 10 : 5
				force: box2d.Vec2 = {x_axis * speed, y_axis * speed}
				box2d.Body_ApplyForceToCenter(entities.physics_id[0], force, true)

				if x_axis != 0 || y_axis != 0 {
					camera.startTagAlong(entities.pos[0])

					if running {
						p_data.state = .RUN
						if p_data.animation.current_animation != .RUNNING {
							changeAnimation(&p_data.animation, .RUNNING)
						}
					} else {
						p_data.state = .WALK
						if p_data.animation.current_animation != .WALKING {
							changeAnimation(&p_data.animation, .WALKING)
						}
					}
				} else {
					p_data.state = .IDLE
					if p_data.animation.current_animation != .IDLE {
						changeAnimation(&p_data.animation, .IDLE)
					}
				}

				if x_axis < 0 {
					p_data.animation.flip_x = -1
				} else if x_axis > 0 {
					p_data.animation.flip_x = 1
				}
			}

		case .HURT:
			if p_data.stun_cooldown <= 0 {
				p_data.state = .IDLE
				changeAnimation(&p_data.animation, .IDLE)
			}

		case .DEAD, .JUMP:
		// revive? idk
		}

		if p_data.stun_cooldown > 0 && p_data.state != .HURT {
			box2d.Body_SetLinearVelocity(entities.physics_id[0], {})
		}
	}
}
