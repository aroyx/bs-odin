package terrain

import "core:math"
import "core:math/linalg"

import "src:client/camera"

import "thirdparty:imgui"
import "thirdparty:tracy"

import rl "vendor:raylib"

@(private = "file")
TerrainLayer :: struct {
	threshold: f32,
	color:     rl.Color,
}

@(private = "file")
TerrainLayerIndex :: enum u8 {
	WATER,
	SAND,
	GRASS,
	DEEP_GRASS,
}

@(private)
terrain_layers: [4]TerrainLayer = {
	{threshold = -0.8, color = {50, 162, 230, 255}}, // water
	{threshold = -0.3, color = {220, 199, 156, 255}}, // sand
	{threshold = -0.01, color = {51, 204, 73, 255}}, // grass
	{threshold = 0.9, color = {6, 98, 38, 255}}, // dark grass
}

renderTerrain :: proc() {
	tracy.ZoneN("Render Terrain")

	evalUI()

	// render the lowest layer "deep_water"
	rekt: rl.Rectangle = {
		height = camera.state.cs * camera.state.vcc,
		width  = camera.state.cs * camera.state.hcc,
		x      = camera.state.x_offset,
		y      = camera.state.y_offset,
	}

	cs := camera.state.cs
	cp := camera.camPos

	camTopLeft: linalg.Vector2f32 = {
		math.clamp(cp.x - (cs * camera.state.hcc * 0.5), 0, cs * (CELL_SIZE - camera.state.hcc)),
		math.clamp(cp.y - (cs * camera.state.vcc * 0.5), 0, cs * (CELL_SIZE - camera.state.vcc)),
	}

	rl.DrawRectangleRec(rekt, {49, 70, 190, 255})
	rl.BeginScissorMode(i32(rekt.x), i32(rekt.y), i32(rekt.width), i32(rekt.height))

	cam_bounds: rl.Rectangle = {
		x      = camTopLeft.x,
		y      = camTopLeft.y,
		width  = (camera.state.hcc * camera.state.cs),
		height = (camera.state.vcc * camera.state.cs),
	}

	transform := rl.MatrixTranslate(
		camera.state.x_offset - camTopLeft.x,
		camera.state.y_offset - camTopLeft.y,
		0.0,
	)

	for i in 0 ..< GRID_SIZE {
		for j in 0 ..< GRID_SIZE {
			chunk := chunks[i][j]
			if !chunk.baked || chunk.mesh.vaoId == 0 do continue

			if rl.CheckCollisionRecs(chunk.bounds, cam_bounds) {
				rl.DrawMesh(chunk.mesh, mat, transform)
				chunks[i][j].is_in = true
			} else do chunks[i][j].is_in = false
		}
	}

	rl.EndScissorMode()
}

evalUI :: proc() {
	when IMGUI_ENABLE {
		if (imgui.Begin("Debug Window")) {

			imgui.Text("Landmass controls")

			if (imgui.SliderFloat("No Of horizontal Cells", &camera.state.hcc, 0.0, 200.0)) {
				camera.state.hcc = math.round(camera.state.hcc)
				camera.UpdateVariables()
				generateChunks()
			}

			if (imgui.SliderInt("Seed", &seed, 0, 214748364)) {
				generateChunks()
			}

			// imgui.Text("Elevation Thresholds")

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
			//
			// if (imgui.SliderInt("Cell Size", auto_cast &cell_size, 8, 128)) do generate_vertices()

			terrainDataUi()
			chunksUI()

		}
		imgui.End()
	}
}
