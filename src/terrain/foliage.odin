package terrain

import "core:math/noise"

foliage: [100][100][2]f32 // 0.08Mb

init_foliage :: proc() {
	for i in 0 ..< 100 {
		for j in 0 ..< 100 {
			foliage[i][j] = calculateNoise2D(i, j)
		}
	}
}

@(private = "file")
calculateNoise2D :: proc(x: int, y: int) -> [2]f32 {
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
