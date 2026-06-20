package client

import "thirdparty:imgui"
import "vendor:sdl3"

@(private = "file")
grass: f32 = 0.8

@(private = "file")
water: f32 = -0.6

render_terrain :: proc() {
	if indices == nil do generate_indices()
	if vertices == nil do generate_vertices()

	imgui.SliderFloat("Grass", &grass, water, 0.99)
	if (imgui.IsItemDeactivatedAfterEdit()) do generate_vertices()

	imgui.SliderFloat("Water", &water, -1.0, grass)
	if (imgui.IsItemDeactivatedAfterEdit()) do generate_vertices()

	sdl3.RenderGeometry(
		renderer,
		nil,
		cast([^]sdl3.Vertex)vertices,
		size * size * 4,
		cast([^]i32)indices,
		size * size * 6,
	)
}

@(private = "file")
vertices: ^[size * size * 4]sdl3.Vertex = nil

@(private = "file")
generate_vertices :: proc() {
	if vertices == nil {
		vertices = new([size * size * 4]sdl3.Vertex)
	}

	// assert(terrain != nil)
	if terrain == nil {
		create_terrain()
	}

	cell_size := 16

	for i in 0 ..< size {
		for j in 0 ..< size {
			color: sdl3.FColor = {}
			// vertex.color = {0.125, 0.609375, 0.5, 1.0}

			switch (terrain[i][j]) {
			// mountain
			case grass ..= 1.0:
				color = {0.515625, 0.29296875, 0.265625, 1.0}
			// grass
			case water ..< grass:
				color = {0.125, 0.609375, 0.5, 1.0}
			// water
			case -1.0 ..< water:
				color = {0.125, 0.609375, 0.90234375, 1.0}
			}

			index := (i * size + j) * 4
			x := f32(i * cell_size)
			y := f32(j * cell_size)
			cs := f32(cell_size)

			vertices[index] = { 	// tl
				position = {x, y},
				color    = color,
			}

			vertices[index + 1] = { 	// tr
				position = {x + cs, y},
				color    = color,
			}

			vertices[index + 2] = { 	// br
				position = {x + cs, y + cs},
				color    = color,
			}

			vertices[index + 3] = { 	// bl
				position = {x, y + cs},
				color    = color,
			}
		}
	}
}

@(private = "file")
indices: ^[size * size * 6]i32 = nil

@(private = "file")
generate_indices :: proc() {
	if indices == nil {
		indices = new([size * size * 6]i32)
	}

	index := 0
	for i in 0 ..< size {
		for j in 0 ..< size {
			tl := i32(i * size + j) * 4
			tr := tl + 1
			br := tl + 2
			bl := tl + 3

			indices[index] = tl
			indices[index + 1] = tr
			indices[index + 2] = br

			indices[index + 3] = br
			indices[index + 4] = bl
			indices[index + 5] = tl

			index += 6
		}
	}
}
