package client

import "core:math"
import "core:math/linalg"
import "src:client/camera"
import "thirdparty:imgui"
import "vendor:sdl3"

@(private = "file")
deep_grass: f32 = 0.9

@(private = "file")
grass: f32 = -0.08

@(private = "file")
water: f32 = -0.3

@(private = "file")
deep_water: f32 = -0.9

@(private = "file")
dgrass_color: linalg.Vector3f32 = {6 / 255.9, 98 / 255.9, 38 / 255.9}
@(private = "file")
grass_color: linalg.Vector3f32 = {51 / 255.9, 204 / 255.9, 73 / 255.9}
@(private = "file")
sand_color: linalg.Vector3f32 = {220 / 255.9, 199 / 255.9, 156 / 255.9}
@(private = "file")
water_color: linalg.Vector3f32 = {50 / 255.9, 162 / 255.9, 230 / 255.9}
@(private = "file")
dwater_color: linalg.Vector3f32 = {49 / 255.9, 70 / 255.9, 190 / 255.9}

render_terrain :: proc() {
	if len(indices) == 0 do generate_indices()
	if len(vertices) == 0 do generate_vertices()

	imgui.Text("Landmass controls")

	if (imgui.SliderFloat("No Of horizontal Cells", &camera.state.hcc, 0.0, 200.0)) {
		camera.state.hcc = math.round(camera.state.hcc)
		camera.updateVariables()
		generate_vertices()
		generate_indices()
	}

	if (imgui.DragFloatRange2("Grasses", &grass, &deep_grass, 0.02, water, 2.0, "Grass: %.3f", "Deep Grass: %.3f")) do generate_vertices()
	if (imgui.DragFloatRange2("Waters", &deep_water, &water, 0.02, -2.0, grass, "Deep Water: %.3f", "Water: %.3f")) do generate_vertices()

	if (imgui.ColorEdit3("Deep Grass Colour", &dgrass_color)) do generate_vertices()
	if (imgui.ColorEdit3("Grass Colour", &grass_color)) do generate_vertices()
	if (imgui.ColorEdit3("Sand Colour", &sand_color)) do generate_vertices()
	if (imgui.ColorEdit3("Water Colour", &water_color)) do generate_vertices()
	if (imgui.ColorEdit3("Deep Water Colour", &dwater_color)) do generate_vertices()

	// if (imgui.SliderInt("Cell Size", auto_cast &cell_size, 8, 128)) do generate_vertices()

	terrain_data_ui()

	sdl3.RenderGeometry(
		renderer,
		nil,
		raw_data(vertices),
		auto_cast len(vertices),
		raw_data(indices),
		auto_cast len(indices),
	)
}

@(private = "file")
vertices: [dynamic]sdl3.Vertex

@(private = "file")
vfirst_time := true

generate_vertices :: proc() {
	clear(&vertices)

	if (vfirst_time) {
		reserve(&vertices, int(math.ceil(camera.state.hcc * camera.state.vcc * 4)))
		vfirst_time = false
	}

	// assert(terrain != nil)
	if terrain == nil {
		create_terrain()
	}

	cs := camera.state.cs

	for i in 0 ..< int(camera.state.hcc) {
		for j in 0 ..< int(camera.state.vcc) {
			color: sdl3.FColor = {}

			if i >= map_size || j >= map_size do continue
			switch (terrain[i][j]) {
			// lets hope the noise is in range [-255, 255]
			case deep_grass ..= 255.0:
				color = get_color(dgrass_color)

			case grass ..< deep_grass:
				color = get_color(grass_color)

			case water ..< grass:
				color = get_color(sand_color)

			case deep_water ..< water:
				color = get_color(water_color)

			case -255.0 ..< deep_water:
				color = get_color(dwater_color)
			}

			index := (i * map_size + j) * 4
			x := (f32(i) * cs) + camera.state.x_offset
			y := (f32(j) * cs) + camera.state.y_offset

			tl: sdl3.Vertex = {
				position = {x, y},
				color    = color,
			}

			tr: sdl3.Vertex = {
				position = {x + cs, y},
				color    = color,
			}

			br: sdl3.Vertex = {
				position = {x + cs, y + cs},
				color    = color,
			}

			bl: sdl3.Vertex = {
				position = {x, y + cs},
				color    = color,
			}

			append(&vertices, tl, tr, br, bl)
		}
	}
}

@(private = "file")
get_color :: proc(vec: linalg.Vector3f32) -> sdl3.FColor {
	return {vec.x, vec.y, vec.z, 1.0}
}

@(private = "file")
indices: [dynamic]i32 = nil

@(private = "file")
ifirst_time := true

@(private = "file")
generate_indices :: proc() {
	clear(&indices)

	if (ifirst_time) {
		reserve(&indices, int(math.ceil(camera.state.hcc * camera.state.vcc * 6)))
		ifirst_time = false
	}

	index: i32 = 0
	for i in 0 ..< int(camera.state.hcc) {
		for j in 0 ..< int(camera.state.vcc) {
			if i >= map_size || j >= map_size do continue

			tl: i32 = index * 4
			tr := tl + 1
			br := tl + 2
			bl := tl + 3

			index += 1

			append(&indices, tl, tr, br, br, bl, tl)
		}
	}
}
