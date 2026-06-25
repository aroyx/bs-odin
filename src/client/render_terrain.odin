package client

import "core:math"
import "core:math/linalg"
import "thirdparty:imgui"

import "src:client/camera"

import "vendor:sdl3"

@(private = "file")
TerrainLayer :: struct {
	threshold: f32,
	color:     sdl3.FColor,
}

@(private = "file")
TerrainLayerIndex :: enum u8 {
	WATER,
	SAND,
	GRASS,
	DEEP_GRASS,
}

@(private = "file")
terrain_layers: [4]TerrainLayer = {
	{threshold = -0.8, color = {50 / 255.9, 162 / 255.9, 230 / 255.9, 1.0}}, // water
	{threshold = -0.3, color = {220 / 255.9, 199 / 255.9, 156 / 255.9, 1.0}}, // sand
	{threshold = -0.01, color = {51 / 255.9, 204 / 255.9, 73 / 255.9, 1.0}}, // grass
	{threshold = 0.9, color = {6 / 255.9, 98 / 255.9, 38 / 255.9, 1.0}}, // dark grass
}

renderTerrain :: proc() {
	if len(vertices) == 0 || len(indices) == 0 || camera.isMoving() do generateVertices()

	when IMGUI_ENABLE {
		imgui.Begin("Debug Window")

		imgui.Text("Landmass controls")

		if (imgui.SliderFloat("No Of horizontal Cells", &camera.state.hcc, 0.0, 200.0)) {
			camera.state.hcc = math.round(camera.state.hcc)
			camera.updateVariables()
			generateVertices()
		}

		if (imgui.SliderInt("Seed", &seed, 0, 214748364)) {
			createTerrain()
			generateVertices()
		}

		// imgui.Text("Elevation Thresholds")
		//
		// if imgui.DragFloat("Deep Water", &deep_water.threshold, 0.01, -2.0, water.threshold, "%.3f") do generateVertices()
		// if imgui.DragFloat("Water", &water.threshold, 0.01, deep_water.threshold, sand.threshold, "%.3f") do generateVertices()
		// if imgui.DragFloat("Sand", &sand.threshold, 0.01, water.threshold, grass.threshold, "%.3f") do generateVertices()
		// if imgui.DragFloat("Grass", &grass.threshold, 0.01, sand.threshold, deep_grass.threshold, "%.3f") do generateVertices()
		// if imgui.DragFloat("Deep Grass", &deep_grass.threshold, 0.01, grass.threshold, 2.0, "%.3f") do generateVertices()
		//
		// if (imgui.ColorEdit4("Deep Grass Colour", auto_cast &deep_grass.color)) do generateVertices()
		// if (imgui.ColorEdit4("Grass Colour", auto_cast &grass.color)) do generateVertices()
		// if (imgui.ColorEdit4("Sand Colour", auto_cast &sand.color)) do generateVertices()
		// if (imgui.ColorEdit4("Water Colour", auto_cast &water.color)) do generateVertices()
		// if (imgui.ColorEdit4("Deep Water Colour", auto_cast &deep_water.color)) do generateVertices()

		// if (imgui.SliderInt("Cell Size", auto_cast &cell_size, 8, 128)) do generate_vertices()

		terrainDataUi()

		imgui.End()
	}

	// render the lowest layer "deep_water" // saved like 1ms
	rekt: sdl3.FRect = {
		h = camera.state.cs * camera.state.vcc,
		w = camera.state.cs * camera.state.hcc,
		x = camera.state.x_offset,
		y = camera.state.y_offset,
	}

	sdl3.SetRenderDrawColor(renderer, 49, 70, 190, 255)
	sdl3.RenderFillRect(renderer, &rekt)

	rekt_again: sdl3.Rect = {
		h = i32(rekt.h),
		w = i32(rekt.w),
		x = i32(rekt.x),
		y = i32(rekt.y),
	}
	sdl3.SetRenderClipRect(renderer, &rekt_again)

	sdl3.RenderGeometry(
		renderer,
		nil,
		raw_data(vertices),
		auto_cast len(vertices),
		raw_data(indices),
		auto_cast len(indices),
	)

	sdl3.SetRenderClipRect(renderer, nil)
}

@(private = "file")
vertices: [dynamic]sdl3.Vertex
@(private = "file")
indices: [dynamic]i32 = nil

@(private = "file")
index: i32 = 0

@(private = "file")
first_time := true

generateVertices :: proc() {
	clear(&vertices)
	clear(&indices)
	index = 0

	if (first_time) {
		reserve(&vertices, int(math.ceil(camera.state.hcc * camera.state.vcc * 4)))
		reserve(&indices, int(math.ceil(camera.state.hcc * camera.state.vcc * 6)))
		first_time = false
	}

	// assert(terrain != nil)
	if terrain == nil {
		createTerrain()
	}

	cs := camera.state.cs
	cp := camera.camPos

	camTopLeft: linalg.Vector2f32 = {
		math.clamp(
			cp.x - (cs * camera.state.hcc * 0.5),
			0,
			max(0, cs * (map_size - camera.state.hcc - 1)),
		),
		math.clamp(
			cp.y - (cs * camera.state.vcc * 0.5),
			0,
			max(0, cs * (map_size - camera.state.vcc - 1)),
		),
	}

	start_x := int(camTopLeft.x / cs)
	start_y := int(camTopLeft.y / cs)

	for i in start_x ..< int(camera.state.hcc) + start_x + 1 {
		for j in start_y ..< int(camera.state.vcc) + start_y + 1 {
			if i < 0 || j < 0 || i >= map_size - 1 || j >= map_size - 1 do continue

			x := (f32(i) * cs) + camera.state.x_offset - camTopLeft.x
			y := (f32(j) * cs) + camera.state.y_offset - camTopLeft.y

			tl := terrain[i][j]
			tr := terrain[i + 1][j]
			bl := terrain[i][j + 1]
			br := terrain[i + 1][j + 1]

			min_h := min(tl, tr, bl, br)
			max_h := max(tl, tr, bl, br)

			for k := 0; k < len(terrain_layers); k += 1 {
				// if the following statement is true then there are no, tiles
				// to render in this cel. So stop.
				if max_h <= terrain_layers[k].threshold do break

				if k < len(terrain_layers) - 1 {
					// if the following statement is true then,
                    // this cell will be overshadowed by another tile. So just
                    // skip rendering this one. But do render the following ones
					if min_h >= terrain_layers[k + 1].threshold do continue
				}

				marching_squares(x, y, terrain_layers[k].threshold, i, j, terrain_layers[k].color)
			}
		}
	}
}

@(private = "file")
points: [8]linalg.Vector2f32

@(private = "file")
Points :: enum i32 {
	A,
	B,
	C,
	D,
	C1,
	C2,
	C3,
	C4,
}

@(private = "file")
lookup: [15][]Points = {
	{.D, .C, .C4},
	{.B, .C3, .C},
	{.D, .B, .C4, .C4, .B, .C3},
	{.A, .C2, .B},
	{.D, .A, .C2, .C4, .D, .C2, .C2, .C, .C4, .C2, .B, .C},
	{.C2, .C3, .C, .C, .A, .C2},
	{.A, .C2, .C3, .A, .C3, .C4, .A, .C4, .D},
	{.C1, .A, .D},
	{.C1, .A, .C, .C1, .C, .C4},
	{.C1, .A, .B, .C1, .B, .C3, .C1, .C3, .C, .C1, .C, .D},
	{.C1, .A, .B, .C1, .B, .C3, .C1, .C3, .C4},
	{.C1, .C2, .D, .D, .C2, .B},
	{.B, .C, .C4, .B, .C4, .C1, .B, .C1, .C2},
	{.C, .D, .C1, .C, .C1, .C2, .C, .C2, .C3},
	{.C1, .C2, .C3, .C1, .C3, .C4},
}

@(private = "file")
marching_squares :: proc(x, y, threshold: f32, i, j: int, color: sdl3.FColor) {
	tl := terrain[i][j]
	tr := terrain[i + 1][j]
	bl := terrain[i][j + 1]
	br := terrain[i + 1][j + 1]

	_tl := tl > threshold ? 0b1000 : 0
	_tr := tr > threshold ? 0b0100 : 0
	_bl := bl > threshold ? 0b0001 : 0
	_br := br > threshold ? 0b0010 : 0

	total := _tl | _tr | _bl | _br
	if total == 0 do return

	cs := camera.state.cs

	a: linalg.Vector2f32 = {x + li(tl, tr, threshold) * cs, y}
	b: linalg.Vector2f32 = {x + cs, y + li(tr, br, threshold) * cs}
	c: linalg.Vector2f32 = {x + li(bl, br, threshold) * cs, y + cs}
	d: linalg.Vector2f32 = {x, y + li(tl, bl, threshold) * cs}

	c1: linalg.Vector2f32 = {x, y}
	c2: linalg.Vector2f32 = {x + cs, y}
	c3: linalg.Vector2f32 = {x + cs, y + cs}
	c4: linalg.Vector2f32 = {x, y + cs}

	points = {a, b, c, d, c1, c2, c3, c4}

	shape := lookup[total - 1]
	for k := 0; k < len(shape); k += 3 {
		pushTriangle(points[shape[k]], points[shape[k + 1]], points[shape[k + 2]], color)
	}
}
@(private = "file")
li :: proc(v1, v2, t: f32) -> f32 { 	// linear interpolation
	if math.abs(v2 - v1) < 0.00001 do return 0.5
	return (t - v1) / (v2 - v1)
}

@(private = "file")
pushTriangle :: proc(a, b, c: linalg.Vector2f32, color: sdl3.FColor) {
	append(
		&vertices,
		sdl3.Vertex{position = {a.x, a.y}, color = color},
		sdl3.Vertex{position = {b.x, b.y}, color = color},
		sdl3.Vertex{position = {c.x, c.y}, color = color},
	)

	append(&indices, index, index + 1, index + 2)

	index += 3
}
