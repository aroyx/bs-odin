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

	append(&foliage_textures, rl.LoadTexture("res/images/foliage/big_plant.png"))
	append(&foliage_textures, rl.LoadTexture("res/images/foliage/big_plant2.png"))
	append(&foliage_textures, rl.LoadTexture("res/images/foliage/big_plant4.png"))
	append(&foliage_textures, rl.LoadTexture("res/images/foliage/big_plant5.png"))
	append(&foliage_textures, rl.LoadTexture("res/images/foliage/big_plant6.png"))
	append(&foliage_textures, rl.LoadTexture("res/images/foliage/big_plant7.png"))
	append(&foliage_textures, rl.LoadTexture("res/images/foliage/medium_plant.png"))
	append(&foliage_textures, rl.LoadTexture("res/images/foliage/medium_plant2.png"))
	append(&foliage_textures, rl.LoadTexture("res/images/foliage/medium_plant4.png"))
	append(&foliage_textures, rl.LoadTexture("res/images/foliage/medium_plant7.png"))
	append(&foliage_textures, rl.LoadTexture("res/images/foliage/plant.png"))
	append(&foliage_textures, rl.LoadTexture("res/images/foliage/plant2.png"))
	append(&foliage_textures, rl.LoadTexture("res/images/foliage/plant3.png"))
	append(&foliage_textures, rl.LoadTexture("res/images/foliage/plant4.png"))
	append(&foliage_textures, rl.LoadTexture("res/images/foliage/plant5.png"))
	append(&foliage_textures, rl.LoadTexture("res/images/foliage/plant6.png"))
	append(&foliage_textures, rl.LoadTexture("res/images/foliage/plant7.png"))

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

	for k in 0 ..< 20 {
		x := start_x + (cnk_sz * rand.float32(gen) * cs)
		y := start_y + (cnk_sz * rand.float32(gen) * cs)

		if !terrain.isLand(x, y) do continue

		f_data := FoliageData {
			plant_type = int(rand.float32(gen) * f32(len(foliage_textures))),
			alpha      = 255,
			time_left  = 0.5,
			is_dying   = false,
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
