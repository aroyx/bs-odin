package client

import "core:math/linalg"
import "thirdparty:imgui"
import "vendor:sdl3"

@(private = "file")
grass: f32 = 0.8

@(private = "file")
water: f32 = -0.6

@(private = "file")
mnt_color: linalg.Vector3f32 = {0.515625, 0.29296875, 0.265625}
@(private = "file")
grass_color: linalg.Vector3f32 = {0.125, 0.609375, 0.5}
@(private = "file")
water_color: linalg.Vector3f32 = {0.125, 0.609375, 0.90234375}

render_terrain :: proc() {
	if indices == nil do generate_indices()
	if vertices == nil do generate_vertices()

	imgui.SliderFloat("Grass", &grass, water, 2.0)
	if (imgui.IsItemDeactivatedAfterEdit()) do generate_vertices()

	imgui.SliderFloat("Water", &water, -2.0, grass)
	if (imgui.IsItemDeactivatedAfterEdit()) do generate_vertices()

	//    imgui.ColorEdit3("Mountain Colour", &mnt_color)
	// if (imgui.IsItemDeactivatedAfterEdit()) do generate_vertices()
	//
	//    imgui.ColorEdit3("Grass Colour", &grass_color)
	// if (imgui.IsItemDeactivatedAfterEdit()) do generate_vertices()
	//
	//    imgui.ColorEdit3("Water Colour", &water_color)
	// if (imgui.IsItemDeactivatedAfterEdit()) do generate_vertices()

    terrain_data_ui()

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
			case grass ..< 255.0: // lets hope the noise is not bigger than 255...
				color = {mnt_color.r, mnt_color.g, mnt_color.b, 1.0}
			// grass
			case water ..< grass:
				color = {grass_color.r, grass_color.g, grass_color.b, 1.0}
			// water
			case -255.0 ..< water:
				color = {water_color.r, water_color.g, water_color.b, 1.0}
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
