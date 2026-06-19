package client

import "core:math/noise"

size :: 64
terrain: ^[size][size]f32 = nil // 4096*4 = 16.376Kb woah that's a lot
seed: i64 = 12301293847

create_terrain :: proc() {
	if terrain == nil {
		terrain = new([size][size]f32)
	}

	for y in 0 ..< size {
		for x in 0 ..< size {
			terrain[x][y] = noise.noise_2d(seed, {f64(x), f64(y)})
		}
	}
}

