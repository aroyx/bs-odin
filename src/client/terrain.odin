package client

import "core:math/noise"
import "thirdparty:imgui"

// these videos helped a lot with making this terrain generator!
// https://youtu.be/J1OdPrO7GD0?t=655 (My favourite!) - "Sculpting Terrain With Math" by Acerola
// https://www.youtube.com/watch?v=cLs3CGNV120 - "How to Procedurally Generate Terrain (in Unity!)" by PangDev

size :: 64
terrain: ^[size][size]f32 = nil // 4096*4 = 16.376Kb woah that's a lot
seed: i64 = 12301293847

create_terrain :: proc() {
	if terrain == nil {
		terrain = new([size][size]f32)
	}

	for x in 0 ..< size {
		for y in 0 ..< size {
			terrain[x][y] = calculate_noise(x, y)
		}
	}
}

TerrainData :: struct {
	iterations:      int,
	decay:           f32,
	lacunarity:      f32, // a fancy word self similarity. Every road lead to Mandelbrot
	scale:           f32,
	start_amplitude: f32,
	start_frequency: f32,
}

terrain_data: TerrainData = {
	iterations      = 4,
	decay           = 0.2,
	lacunarity      = 2.0,
	scale           = 0.05,
	start_amplitude = 1.0,
	start_frequency = 1.0,
}

@(private = "file")
calculate_noise :: proc(x: int, y: int) -> f32 {
	height: f32 = 0.0

	amplitude := terrain_data.start_amplitude
	frequency: f32 = terrain_data.start_frequency

	for i in 0 ..< terrain_data.iterations {
		sx := f64(x) * f64(terrain_data.scale * frequency)
		sy := f64(y) * f64(terrain_data.scale * frequency)

		height += noise.noise_2d(seed, {sx, sy}) * amplitude

		amplitude *= terrain_data.decay
		frequency *= terrain_data.lacunarity
	}

	return height
}

terrain_data_ui :: proc() {
	changed := false

	imgui.SliderInt("iterations", auto_cast &terrain_data.iterations, 1, 8)
	if (imgui.IsItemDeactivatedAfterEdit()) do changed = true

	imgui.SliderFloat("scale", &terrain_data.scale, 0.0, 0.3)
	if (imgui.IsItemDeactivatedAfterEdit()) do changed = true

	imgui.SliderFloat("decay", &terrain_data.decay, 0.01, 1.0)
	if (imgui.IsItemDeactivatedAfterEdit()) do changed = true

	imgui.SliderFloat("lacunarity", &terrain_data.lacunarity, 0.0, 5.0)
	if (imgui.IsItemDeactivatedAfterEdit()) do changed = true

	imgui.SliderFloat("start_amplitude", &terrain_data.start_amplitude, 0.0, 5.0)
	if (imgui.IsItemDeactivatedAfterEdit()) do changed = true

	imgui.SliderFloat("start_frequency", &terrain_data.start_frequency, 0.0, 5.0)
	if (imgui.IsItemDeactivatedAfterEdit()) do changed = true

	if changed {
		create_terrain()
        generate_vertices()
	}
}
