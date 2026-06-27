package terrain

import "core:math"
import "core:math/linalg"
import "core:mem"
import "thirdparty:tracy"
import "vendor:raylib/rlgl"

import "src:client/camera"

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

@(private = "file")
terrain_layers: [4]TerrainLayer = {
	{threshold = -0.8, color = {50, 162, 230, 255}}, // water
	{threshold = -0.3, color = {220, 199, 156, 255}}, // sand
	{threshold = -0.01, color = {51, 204, 73, 255}}, // grass
	{threshold = 0.9, color = {6, 98, 38, 255}}, // dark grass
}

renderTerrain :: proc() {
	tracy.ZoneN("Render Terrain")

	if len(vertices_pos) == 0 || len(vertices_col) == 0 || camera.IsMoving() do generateVertices()

	// render the lowest layer "deep_water" // saved like 1ms
	rekt: rl.Rectangle = {
		height = camera.state.cs * camera.state.vcc,
		width  = camera.state.cs * camera.state.hcc,
		x      = camera.state.x_offset,
		y      = camera.state.y_offset,
	}
	rl.DrawRectangleRec(rekt, {49, 70, 190, 255})

	rl.BeginScissorMode(i32(rekt.x), i32(rekt.y), i32(rekt.width), i32(rekt.height))
	rlgl.DisableBackfaceCulling()
	// rlgl.Begin(rlgl.TRIANGLES)

	if mesh_initialised && terrain_mesh.vaoId != 0 {
		rl.DrawMesh(terrain_mesh, terrain_material, terrain_transform)
	}

	// rlgl.End()
	// rlgl.DrawRenderBatchActive()
	rlgl.EnableBackfaceCulling()
	rl.EndScissorMode()
}

@(private = "file")
vertices_pos: [dynamic]rl.Vector3
@(private = "file")
vertices_col: [dynamic]rl.Color

@(private = "file")
first_time := true

generateVertices :: proc() {
	tracy.ZoneN("Generate Vertices")
	clear(&vertices_pos)
	clear(&vertices_col)

	if (first_time) {
		reserve(&vertices_pos, int(math.ceil(camera.state.hcc * camera.state.vcc * 4)))
		reserve(&vertices_col, int(math.ceil(camera.state.hcc * camera.state.vcc * 4)))
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
	updateMesh()
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
marching_squares :: proc(x, y, threshold: f32, i, j: int, color: rl.Color) {
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
pushTriangle :: proc(a, b, c: linalg.Vector2f32, color: rl.Color) {
	append(
		&vertices_pos,
		rl.Vector3{a.x, a.y, 0.0},
		rl.Vector3{b.x, b.y, 0.0},
		rl.Vector3{c.x, c.y, 0.0},
	)
	append(&vertices_col, color, color, color)
}

@(private = "file")
terrain_mesh: rl.Mesh = {}
@(private = "file")
terrain_material: rl.Material = {}
@(private = "file")
terrain_transform: rl.Matrix = {
	1.0,
	0.0,
	0.0,
	0.0,
	0.0,
	1.0,
	0.0,
	0.0,
	0.0,
	0.0,
	1.0,
	0.0,
	0.0,
	0.0,
	0.0,
	1.0,
}

@(private = "file")
mesh_initialised := false

@(private = "file")
updateMesh :: proc() {
	if mesh_initialised {
		rl.UnloadMesh(terrain_mesh)
        terrain_mesh = {}
	} else {
		mesh_initialised = true
		terrain_material = rl.LoadMaterialDefault()
	}

	terrain_mesh.vertexCount = i32(len(vertices_pos))
	terrain_mesh.triangleCount = i32(len(vertices_pos) / 3)

	v_size := u32(len(vertices_pos) * size_of(rl.Vector3))
	c_size := u32(len(vertices_col) * size_of(rl.Color))

	terrain_mesh.vertices = cast([^]f32)rl.MemAlloc(v_size)
	terrain_mesh.colors = cast([^]u8)rl.MemAlloc(c_size)

	mem.copy(terrain_mesh.vertices, raw_data(vertices_pos), int(v_size))
	mem.copy(terrain_mesh.colors, raw_data(vertices_col), int(c_size))

	rl.UploadMesh(&terrain_mesh, false)
}
