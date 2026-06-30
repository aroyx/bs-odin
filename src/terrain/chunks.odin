package terrain

import "../camera"
import "../utils"

import "core:fmt"
import "core:math/linalg"
import "core:mem"

import "thirdparty:imgui"
import "thirdparty:tracy"
import rl "vendor:raylib"

Chunks :: struct {
	mesh:   rl.Mesh,
	bounds: rl.Rectangle,
	baked:  bool,
	is_in:  bool,
}

chunks: [utils.GRID_SIZE][utils.GRID_SIZE]Chunks
mat: rl.Material

@(private = "file")
first_time := true

generateRenderChunks :: proc() {
	tracy.ZoneN("Chunk Generation!")
	cs := camera.state.cs
	mat = rl.LoadMaterialDefault()
	destroyChunks()

    gs := utils.GRID_SIZE
    chunkSize := utils.CHUNK_SIZE
    mps := utils.map_size

	for a in 0 ..< gs { 	// iterate over the chunks
		for b in 0 ..< gs {
			start_x := a * chunkSize
			start_y := b * chunkSize

			clear(&vertices_pos)
			clear(&vertices_col)

			if (first_time) {
				reserve(&vertices_pos, chunkSize * chunkSize * 4)
				reserve(&vertices_col, chunkSize * chunkSize * 4)
				first_time = false
			}

			for i in start_x ..< start_x + chunkSize { 	// iterate over the cells in chunks
				for j in start_y ..< start_y + chunkSize {
					if i < 0 || j < 0 || i >= mps - 1 || j >= mps - 1 do continue

					x := f32(i) * cs
					y := f32(j) * cs

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

						marching_squares(
							x,
							y,
							terrain_layers[k].threshold,
							i,
							j,
							terrain_layers[k].color,
						)
					}
				}
			}

			chunks[a][b].mesh = createMeshFromVertices()
			chunks[a][b].bounds = {
				x      = f32(start_x) * cs,
				y      = f32(start_y) * cs,
				width  = f32(chunkSize) * cs,
				height = f32(chunkSize) * cs,
			}
			chunks[a][b].baked = true
			chunks[a][b].is_in = false
		}
	}
}

destroyChunks :: proc() {
	rl.SetTraceLogLevel(rl.TraceLogLevel.NONE)
	defer rl.SetTraceLogLevel(rl.TraceLogLevel.INFO)

	for a in 0 ..< utils.GRID_SIZE { 	// iterate over the chunks
		for b in 0 ..< utils.GRID_SIZE {
			if chunks[a][b].baked {
				rl.UnloadMesh(chunks[a][b].mesh)
				chunks[a][b].baked = false
			}
		}
	}
}

@(private = "file")
vertices_pos: [dynamic]rl.Vector3
@(private = "file")
vertices_col: [dynamic]rl.Color

@(private)
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
createMeshFromVertices :: proc() -> rl.Mesh {
	if len(vertices_pos) == 0 do return {}

	rl.SetTraceLogLevel(rl.TraceLogLevel.NONE)
	defer rl.SetTraceLogLevel(rl.TraceLogLevel.INFO)

	mesh: rl.Mesh = {}
	mesh.vertexCount = i32(len(vertices_pos))
	mesh.triangleCount = i32(len(vertices_pos) / 3)

	v_size := u32(len(vertices_pos) * size_of(rl.Vector3))
	c_size := u32(len(vertices_col) * size_of(rl.Color))

	mesh.vertices = cast([^]f32)rl.MemAlloc(v_size)
	mesh.colors = cast([^]u8)rl.MemAlloc(c_size)

	mem.copy(mesh.vertices, raw_data(vertices_pos), int(v_size))
	mem.copy(mesh.colors, raw_data(vertices_col), int(c_size))

	rl.UploadMesh(&mesh, false)
	return mesh
}

chunksUI :: proc() {
	imgui.BeginTable("Chunks Render Grid", utils.GRID_SIZE)
	for j in 0 ..< utils.GRID_SIZE {
		imgui.TableNextRow()
		for i in 0 ..< utils.GRID_SIZE {
			imgui.TableNextColumn()
			imgui.PushID(fmt.ctprintf("%d", i * utils.GRID_SIZE + j))
			imgui.Checkbox("##cell", &chunks[i][j].is_in)
			imgui.PopID()
		}
	}
	imgui.EndTable()
}
