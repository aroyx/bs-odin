package playing

import "core:math/rand"
import "core:time"

import "../camera"
import "../terrain"
import "../utils"

import "vendor:box2d"
import rl "vendor:raylib"

@(private)
foliage_textures: [dynamic]rl.Texture

@(private)
loadFoliage :: proc() {
	foliage_textures = make([dynamic]rl.Texture)

	files := rl.LoadDirectoryFiles("res/images/foliage")

	for i in 0 ..< files.count {
		path := files.paths[i]

		if !rl.FileExists(path) do continue

		append(&foliage_textures, rl.LoadTexture(path))
	}

	for i in 0 ..< utils.GRID_SIZE {
		for j in 0 ..< utils.GRID_SIZE {
			chunk_visible_state[i][j] = false
			foliage_handles_chunk[i][j] = make([dynamic]EntityHandle)
		}
	}
}

@(private)
unLoadFoliage :: proc() {
	for i in foliage_textures {
		rl.UnloadTexture(i)
	}

	for i in 0 ..< utils.GRID_SIZE {
		for j in 0 ..< utils.GRID_SIZE {
			delete(foliage_handles_chunk[i][j])
		}
	}
}

@(private)
foliageStateMachineUpdate :: proc(entity: ^Entity, handle: EntityHandle, dt: f32) {
	data := &entity.data.(FoliageData)

	if !data.is_dying do return

	data.time_left -= dt

	if data.time_left <= 0 {
		removeEntity(handle)
		return
	}

	data.alpha = u8(data.time_left / 0.5 * 255.0)
}

@(private)
FoliageAnimationData :: struct {
	offset_time:          f32,
	animation_duration:   f32,
	animation_start_time: time.Time,
}

@(private = "file")
chunk_visible_state: [utils.GRID_SIZE][utils.GRID_SIZE]bool

@(private = "file")
foliage_handles_chunk: [utils.GRID_SIZE][utils.GRID_SIZE][dynamic]EntityHandle

@(private)
updateFoliage :: proc() {
	for i in 0 ..< utils.GRID_SIZE {
		for j in 0 ..< utils.GRID_SIZE {
			is_visible := terrain.isChunkVisible(i, j)

			if is_visible && !chunk_visible_state[i][j] {
				generateFoliageChunk(i, j)
				chunk_visible_state[i][j] = true
			} else if !is_visible && chunk_visible_state[i][j] {
				deleteFoliageChunk(i, j)
				chunk_visible_state[i][j] = false
			}
		}
	}
}

@(private = "file")
generateFoliageChunk :: proc(i, j: int) {
	cs := camera.state.cs
	cnk_sz: f32 = utils.CHUNK_SIZE
	start_x := f32(i) * cnk_sz * cs
	start_y := f32(j) * cnk_sz * cs

	// AI helped me with generating the deterministic randomness
	seed := (u64(u32(i)) << 32) | u64(u32(j))
	r := rand.create(seed)
	gen := rand.default_random_generator(&r)

	for _ in 0 ..< 30 {
		x := start_x + (cnk_sz * rand.float32(gen) * cs)
		y := start_y + (cnk_sz * rand.float32(gen) * cs)

		if !terrain.isLand(x, y) do continue

		f_data := FoliageData {
			plant_type = int(rand.float32(gen) * f32(len(foliage_textures))),
			alpha      = 255,
			time_left  = 0.5,
			is_dying   = false,
		}

		tex := foliage_textures[f_data.plant_type]

		f_entity := Entity {
			pos        = {x, y},
			data       = f_data,
			physics_id = box2d.BodyId{}, // no physics needed
			health     = 100,
			size       = {f32(tex.width) * 0.015, f32(tex.height) * 0.015},
		}

		handle := addEntity(&f_entity)
		append(&foliage_handles_chunk[i][j], handle)
	}
}

@(private = "file")
deleteFoliageChunk :: proc(i, j: int) {
	for handle in foliage_handles_chunk[i][j] {
		removeEntity(handle)
	}

	clear(&foliage_handles_chunk[i][j])
}

@(private)
drawFoliage :: proc(
	data: ^FoliageData,
	pos, camTopLeft, p_pos: [2]f32,
	bounding_box: rl.Rectangle,
) {
	tex := foliage_textures[data.plant_type]

	if tex.id == 0 do return

	cs := camera.state.cs
	tex_w, tex_h := f32(tex.width), f32(tex.height)

	draw_x := pos.x - camTopLeft.x + camera.state.x_offset
	draw_y := pos.y - camTopLeft.y + camera.state.y_offset

	scale := cs * 0.015

	offset_y := 0.08 * cs * 4.0
	x := draw_x - (tex_w * scale * 0.5)
	y := draw_y - (tex_h * scale) + offset_y

	if !data.is_dying {
		p_pos_screen: [2]f32 = {
			p_pos.x - camTopLeft.x + camera.state.x_offset,
			p_pos.y - camTopLeft.y + camera.state.y_offset,
		}

		if rl.CheckCollisionPointRec(p_pos_screen, bounding_box) {
			data.alpha = 150
		} else {
			data.alpha = 255
		}
	}

	rl.DrawTextureEx(tex, {x, y}, 0.0, scale, {255, 255, 255, data.alpha})
}
