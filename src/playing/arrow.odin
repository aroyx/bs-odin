package playing

import hm "core:container/handle_map"
import "core:math/linalg"

import "../camera"

import "vendor:box2d"
import rl "vendor:raylib"

@(private)
arrow_1_texutre: rl.Texture
@(private)
arrow_2_texutre: rl.Texture

COLISSION_INTERVAL :: 0.1

@(private)
spawnArrow :: proc(p_pos, t_pos: [2]f32, shooter: EntityHandle) {
	height := camera.state.cs * 2
	dir := linalg.normalize0(t_pos - p_pos)

	pos := p_pos
	pos.y += height / 2

	a_data: ArrowData = {
		start_pos       = pos,
		dir             = dir,
		strength        = 1,
		shooter         = shooter,
		collision_timer = COLISSION_INTERVAL,
	}

	a_entity: Entity = {
		size   = {3, 3},
		health = 1,
		pos    = pos,
		data   = a_data,
	}

	addEntity(&a_entity)
}

@(private)
updateArrow :: proc(e: ^Entity, handle: EntityHandle, dt: f32) {
	data, ok := &e.data.(ArrowData)
	if !ok do return

	data.strength -= 0.2 * dt

	if data.strength <= 0 {
		removeEntity(handle)
		return
	}

	e.pos += data.dir * dt * data.strength * camera.state.cs * 15

	data.collision_timer -= dt
	if data.collision_timer <= 0 {
		data.collision_timer = COLISSION_INTERVAL

		check_collision_arrow_with_other_people_this_is_a_big_name_yeah_idc_this_is_fun_I_will_only_use_this_function_once_ig_the_sky_is_blue_the_ground_is_brown_my_future_is_dark_my_love_is_red(
			e,
			data,
			dt,
		)
	}
}

@(private = "file")
check_collision_arrow_with_other_people_this_is_a_big_name_yeah_idc_this_is_fun_I_will_only_use_this_function_once_ig_the_sky_is_blue_the_ground_is_brown_my_future_is_dark_my_love_is_red :: proc(
	e: ^Entity,
	data: ^ArrowData,
	dt: f32,
) {
	cs := camera.state.cs
	hit_radius := cs * 1.5
	hit_rad_sq := hit_radius * hit_radius

	it := hm.iterator_make(&entities)

	for oe, o_handle in hm.iterate(&it) {
		if o_handle == data.shooter do continue

		dx := oe.pos.x - e.pos.x
		if linalg.abs(dx) > hit_radius do continue

		dy := oe.pos.y - e.pos.y
		if linalg.abs(dy) > hit_radius do continue

		d_sq := (dx * dx) + (dy * dy)
		if d_sq > hit_rad_sq do continue

        hit := false
		switch &odata in &oe.data {
		case PlayerData:
			oe.health -= 35 * data.strength

			if oe.health <= 0 {
				changePlayerState(&odata, .DEAD)
			} else {
				changePlayerState(&odata, .HURT)
			}

            hit = true
		case EnemyData:
			oe.health -= 85 * data.strength

			if oe.health <= 0 {
				changeEnemyState(&odata, .DEAD)
			} else {
				changeEnemyState(&odata, .HURT)
			}

			knock_dir := linalg.normalize0(data.dir)
			force: f32 = 5
			impulse: box2d.Vec2 = {knock_dir.x * force, knock_dir.y * force}

			box2d.Body_ApplyLinearImpulseToCenter(e.physics_id, impulse, true)

            hit = true
		case FoliageData:
			odata.is_dying = true
			odata.time_left = 0.5

			playSound(.CUT_FOLIAGE)
		case BombData, ArrowData:
		//wtf
		}
        
        if hit {
            removeEntity(e.handle)
        }
	}
}

@(private)
drawArrow :: proc(data: ^ArrowData, pos, camTopLeft: [2]f32) {
	s_pos := [2]f32 {
		pos.x - camTopLeft.x + camera.state.x_offset,
		pos.y - camTopLeft.y + camera.state.y_offset,
	}

	tex := arrow_textures[player_skin.bow]

	src: rl.Rectangle = {
		x      = 0,
		y      = 0,
		width  = f32(tex.width),
		height = f32(tex.height),
	}

	scale := camera.state.cs / 230

	dst: rl.Rectangle = {
		x      = s_pos.x,
		y      = s_pos.y,
		width  = f32(tex.width) * scale,
		height = f32(tex.height) * scale,
	}

	origin: [2]f32 = {dst.width / 2, dst.height / 2}
	rotation := linalg.to_degrees(linalg.atan2(data.dir.y, data.dir.x))

	rl.DrawTexturePro(tex, src, dst, origin, rotation, rl.WHITE)
}

@(private)
drawArrowTrajectory :: proc(data: ^PlayerData, p_pos, camTopLeft: [2]f32) {

}
