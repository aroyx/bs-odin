package playing

import "../camera"
import "core:math"

import "core:math/linalg"
import "core:time"

import rl "vendor:raylib"

@(private)
bomb_tex: rl.Texture

@(private)
spawnBomb :: proc(pos, target: [2]f32) {
	b_data: BombData = {
		start      = pos,
		dest       = target,
		start_time = time.now(),
		dur        = 1,
		height     = 0,
	}

	b_entity: Entity = {
		size   = {3, 3},
		health = 1,
		pos    = pos,
		data   = b_data,
	}

	addEntity(&b_entity)
}

@(private)
updateBomb :: proc(e: ^Entity, handle: EntityHandle, dt: f32) {
	data, ok := &e.data.(BombData)
	if !ok do return

	diff := f32(time.duration_seconds(time.diff(data.start_time, time.now())))
	if data.dur < diff {
		// explode
		removeEntity(handle)
		return
	}

	t := clamp(diff / data.dur, 0, 1)
	e.pos = linalg.lerp(data.start, data.dest, t)

	// max_height: f32 = clamp(linalg.distance(data.start, data.dest) * 0.5, 10, 50)
	max_height: f32 = 3 * camera.state.cs

	// this is a crazy parabola I worked on, t(x) belongs to [0, 1] and height(y) belongs to [0, max_height]
	// https://www.desmos.com/calculator/ycnr3cclho
	data.height = max_height - (4 * max_height * math.pow(t - 0.5, 2))
}

@(private)
drawBomb :: proc(data: ^BombData, pos, camTopLeft: [2]f32) {

	if bomb_tex.id == 0 do return

	s_pos := [2]f32 {
		pos.x - camTopLeft.x + camera.state.x_offset,
		pos.y - camTopLeft.y + camera.state.y_offset - data.height,
	}

	rl.DrawTextureEx(bomb_tex, s_pos, 0, 1, rl.WHITE)
}
