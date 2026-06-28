package terrain

import "core:math/noise"
import "thirdparty:imgui"

IMGUI_ENABLE :: #config(IMGUI_ENABLE, true)

// these videos helped a lot with making this terrain generator!
// https://youtu.be/J1OdPrO7GD0?t=655 (My favourite!) - "Sculpting Terrain With Math" by Acerola
// https://www.youtube.com/watch?v=cLs3CGNV120 - "How to Procedurally Generate Terrain (in Unity!)" by PangDev

map_size :: 512 + 1
@(private)
terrain: ^[map_size][map_size]f32 = nil // 4096*4 = 16.376Kb woah that's a lot
@(private)
seed: i32 = 86030688

createTerrain :: proc() {
	if terrain == nil {
		terrain = new([map_size][map_size]f32)
	}

	for x in 0 ..< map_size {
		for y in 0 ..< map_size {
			terrain[x][y] = calculateNoise(x, y)
		}
	}
}

@(private)
TerrainGenData :: struct {
	iterations:      int,
	decay:           f32,
	lacunarity:      f32, // a fancy word self similarity. Every road lead to Mandelbrot
	scale:           f32,
	start_amplitude: f32,
	start_frequency: f32,
}

@(private)
terrain_gen_data: TerrainGenData = {
	iterations      = 4,
	decay           = 0.2,
	lacunarity      = 2.0,
	scale           = 0.05,
	start_amplitude = 1.0,
	start_frequency = 1.0,
}

@(private = "file")
calculateNoise :: proc(x: int, y: int) -> f32 {
	height: f32 = 0.0

	amplitude := terrain_gen_data.start_amplitude
	frequency: f32 = terrain_gen_data.start_frequency

	for i in 0 ..< terrain_gen_data.iterations {
		sx := f64(x) * f64(terrain_gen_data.scale * frequency)
		sy := f64(y) * f64(terrain_gen_data.scale * frequency)

		height += noise.noise_2d(i64(seed), {sx, sy}) * amplitude

		amplitude *= terrain_gen_data.decay
		frequency *= terrain_gen_data.lacunarity
	}

	return height
}

@(private)
terrainDataUi :: proc() {
	when IMGUI_ENABLE {
		changed := false

		if (imgui.SliderInt("iterations", auto_cast &terrain_gen_data.iterations, 1, 8)) do changed = true
		if (imgui.SliderFloat("scale", &terrain_gen_data.scale, 0.0, 0.3)) do changed = true
		if (imgui.SliderFloat("decay", &terrain_gen_data.decay, 0.01, 1.0)) do changed = true
		if (imgui.SliderFloat("lacunarity", &terrain_gen_data.lacunarity, 0.0, 5.0)) do changed = true
		if (imgui.SliderFloat("start_amplitude", &terrain_gen_data.start_amplitude, 0.0, 5.0)) do changed = true
		if (imgui.SliderFloat("start_frequency", &terrain_gen_data.start_frequency, 0.0, 5.0)) do changed = true

		if changed {
			generateChunks()
		}
	}
}
