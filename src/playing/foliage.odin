package playing

import "core:math/rand"
import "core:time"
import "vendor:box2d"

import "../camera"
import "../terrain"
import "../utils"

import rl "vendor:raylib"

@(private)
FoliageTextureType :: enum u8 {
	PLANT,
}

@(private)
foliage_textures: [FoliageTextureType]rl.Texture

@(private)
loadFoliage :: proc() {
	foliage_textures[.PLANT] = rl.LoadTexture("res/images/foliage/plant.png")

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

	for k in 0 ..< 20 {
		x := start_x + (cnk_sz * rand.float32() * cs)
		y := start_y + (cnk_sz * rand.float32() * cs)

		if !terrain.isLand(x, y) do continue

		f_data := FoliageData {
			plant_type = .PLANT,
		}

		f_entity := Entity {
			pos        = {x, y},
			data       = f_data,
			physics_id = box2d.BodyId{}, // no physics needed
			health     = 100,
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
