package playing

import hm "core:container/handle_map"
import "core:math"
import "core:math/linalg"
import "core:time"

import "../camera"
import "../physics"

import "vendor:box2d"
import rl "vendor:raylib"

@(private)
bomb_tex: rl.Texture

@(private)
spawnBomb :: proc(pos, target: [2]f32) {
	b_data: BombData = {
		start      = pos,
		dest       = target,
		start_time = time.now(),
		dur        = 2,
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
		rad: f32 = 2.25
		explode_def := box2d.DefaultExplosionDef()
		explode_def.position = data.dest / camera.state.cs
		explode_def.falloff = 0
		explode_def.impulsePerLength = 17
		explode_def.radius = rad

		box2d.World_Explode(physics.phyWorld, explode_def)

		it := hm.iterator_make(&entities)
		radius := rad * camera.state.cs
		rad_sq := radius * radius

		for oe, handle in hm.iterate(&it) {
			dx := abs(oe.pos.x - e.pos.x)
			dy := abs(oe.pos.y - e.pos.y)
			d_sq := (dx * dx) + (dy * dy)

			if d_sq > rad_sq do continue

			dist := math.pow(d_sq, 0.5)

			damage := linalg.lerp(f32(70), f32(20), dist / radius)

			switch &odata in &oe.data {
			case PlayerData:
				oe.health -= damage * 0.5

				if oe.health <= 0 {
					changePlayerState(&odata, .DEAD)
				} else {
					changePlayerState(&odata, .HURT)
				}
			case EnemyData:
				oe.health -= damage

				if oe.health <= 0 {
					changeEnemyState(&odata, .DEAD)
				} else {
					changeEnemyState(&odata, .HURT)
				}
			case FoliageData:
				odata.is_dying = true
				odata.time_left = 0.5

				playSound(.CUT_FOLIAGE)
			case BombData:
			//wtf
			}
		}

		removeEntity(handle) // remove the bomb entity
		return
	}

	t := clamp(diff / data.dur, 0, 1)
	e.pos = linalg.lerp(data.start, data.dest, t)

	// max_height: f32 = clamp(linalg.distance(data.start, data.dest) * 0.5, 10, 50)
	max_height: f32 = 5 * camera.state.cs

	// this is a crazy parabola I worked on, t(x) belongs to [0, 1] and height(y) belongs to [0, max_height]
	// https://www.desmos.com/calculator/ycnr3cclho
	data.height = max_height - (4 * max_height * math.pow(t - 0.5, 2))
}

@(private)
drawBomb :: proc(data: ^BombData, pos, camTopLeft: [2]f32) {

	if bomb_tex.id == 0 do return

	s_pos := [2]f32 {
		pos.x - camTopLeft.x + camera.state.x_offset - (f32(bomb_tex.width) * 0.5),
		pos.y - camTopLeft.y + camera.state.y_offset - data.height - (f32(bomb_tex.height) * 0.5),
	}

	rl.DrawTextureEx(bomb_tex, s_pos, 0, 1, rl.WHITE)
}
