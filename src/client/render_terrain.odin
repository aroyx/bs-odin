package client

import "vendor:sdl3"

render_terrain :: proc() {
	if indices == nil do generate_indices()
	if vertices == nil do generate_vertices()

	sdl3.RenderGeometry(
		renderer,
		nil,
		cast([^]sdl3.Vertex)vertices,
		size * size,
		cast([^]i32)indices,
		(size - 1) * (size - 1) * 6,
	)
}

@(private = "file")
vertices: ^[size * size]sdl3.Vertex = nil

@(private = "file")
generate_vertices :: proc() {
	if vertices == nil {
		vertices = new([size * size]sdl3.Vertex)
	}

	// assert(terrain != nil)
	if terrain == nil {
		create_terrain()
	}

	cell_size := 16

	for i in 0 ..< size {
		for j in 0 ..< size {
			vertex: sdl3.Vertex = {}
			// vertex.color = {0.125, 0.609375, 0.5, 1.0}

			switch (terrain[i][j]) {
			// mountain
			case 0.5 ..= 1.0:
				vertex.color = {0.515625, 0.29296875, 0.265625, 1.0}
			// grass
			case -0.5 ..< 0.5:
				vertex.color = {0.125, 0.609375, 0.5, 1.0}
			// water
			case -1.0 ..< -0.5:
				vertex.color = {0.125, 0.609375, 0.90234375, 1.0}
			}

			vertex.position = {f32(i * cell_size), f32(j * cell_size)}
			vertices[i * size + j] = vertex
		}
	}
}

@(private = "file")
indices: ^[(size - 1) * (size - 1) * 6]i32 = nil

@(private = "file")
generate_indices :: proc() {
	if indices == nil {
		indices = new([(size - 1) * (size - 1) * 6]i32)
	}

	index := 0
	for i in 0 ..< size - 1 {
		for j in 0 ..< size - 1 {
			tl := i32(i * size + j)
			tr := i32(i * size + j + 1)
			br := i32((i + 1) * size + j)
			bl := i32((i + 1) * size + j + 1)

			j := i * 4
			k := i32(i)

			indices[index] = tl
			indices[index + 1] = tr
			indices[index + 2] = br

			indices[index + 3] = bl
			indices[index + 4] = tr
			indices[index + 5] = br

			index += 6
		}
	}
}
