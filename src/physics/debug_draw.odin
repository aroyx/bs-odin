package physics

import "base:runtime"
import "core:math"
import "core:math/linalg"

import "../camera"
import "../utils"

import "thirdparty:tracy"
import "vendor:box2d"
import rl "vendor:raylib"

drawPhysics :: proc() {
	tracy.ZoneN("Box2d Debug Draw")

	if camera.state.cs <= 0 { 	// camera is not initialised
		debug_draw_config.useDrawingBounds = false
		box2d.World_Draw(phyWorld, &debug_draw_config)
		return
	}

	cp := camera.camPos / camera.state.cs
	cs := camera.state.cs
	mps := f32(utils.MAP_SIZE)

	left := math.clamp(cp.x - (camera.state.hcc * 0.5), 0, mps - camera.state.hcc)
	top := math.clamp(cp.y - (camera.state.vcc * 0.5), 0, mps - camera.state.vcc)
	right := left + camera.state.hcc
	bottom := top + camera.state.vcc

	debug_draw_config.drawingBounds = {
		lowerBound = {left, top},
		upperBound = {right, bottom},
	}

	debug_draw_config.useDrawingBounds = true

	camTopLeft: linalg.Vector2f32 = {
		math.clamp(
			camera.camPos.x - (cs * camera.state.hcc * 0.5),
			0,
			cs * (utils.MAP_SIZE - camera.state.hcc),
		),
		math.clamp(
			camera.camPos.y - (cs * camera.state.vcc * 0.5),
			0,
			cs * (utils.MAP_SIZE - camera.state.vcc),
		),
	}

	// 2. Set target to TopLeft, and offset to your letterbox padding
	cam: rl.Camera2D = {
		target   = camTopLeft,
		offset   = {camera.state.x_offset, camera.state.y_offset},
		rotation = 0,
		zoom     = 1.0,
	}

	rl.BeginMode2D(cam)
	box2d.World_Draw(phyWorld, &debug_draw_config)
	rl.EndMode2D()
}

@(private = "file")
debug_draw_config: box2d.DebugDraw

@(private)
initDebugDraw :: proc() {
	debug_draw_config = box2d.DefaultDebugDraw()

	// functions
	debug_draw_config.DrawPolygonFcn = DrawPolygonFcn
	debug_draw_config.DrawSolidPolygonFcn = DrawSolidPolygonFcn
	debug_draw_config.DrawCircleFcn = DrawCircleFcn
	debug_draw_config.DrawSolidCircleFcn = DrawSolidCircleFcn
	debug_draw_config.DrawSolidCapsuleFcn = DrawSolidCapsuleFcn
	debug_draw_config.DrawSegmentFcn = DrawSegmentFcn
	debug_draw_config.DrawTransformFcn = DrawTransformFcn
	debug_draw_config.DrawPointFcn = DrawPointFcn
	debug_draw_config.DrawStringFcn = DrawStringFcn

	// bound
	// debug_draw_config.drawingBounds = {}
	// debug_draw_config.useDrawingBounds = true

	// toggles
	debug_draw_config.drawShapes = true
	// debug_draw_config.drawJoints = true
	// debug_draw_config.drawJointExtras = true
	// debug_draw_config.drawBounds = true
	// debug_draw_config.drawMass = true
	// debug_draw_config.drawBodyNames = true
	debug_draw_config.drawContacts = true
	// debug_draw_config.drawGraphColors = true
	// debug_draw_config.drawContactNormals = true
	// debug_draw_config.drawContactImpulses = true
	// debug_draw_config.drawContactFeatures = true
	// debug_draw_config.drawFrictionImpulses = true
	debug_draw_config.drawIslands = true
}

@(private = "file")
hexToCol :: proc(pCol: box2d.HexColor) -> rl.Color {
	col := u32(pCol)
	r := u8((col >> 16) & 0xFF)
	g := u8((col >> 8) & 0xFF)
	b := u8((col) & 0xFF)
	return {r, g, b, 150}
}

@(private = "file")
DrawPolygonFcn :: proc "c" (
	vertices: [^][2]f32,
	vertexCount: i32,
	color: box2d.HexColor,
	ctx: rawptr,
) {
	context = runtime.default_context()
	context.allocator = context.temp_allocator

	col := hexToCol(color)

	if vertexCount <= 0 do return

	// to wrap around the poly this array is vertexCount + 1 in length
	sVertices := make([][2]f32, vertexCount + 1)

	scale := (camera.state.cs > 0) ? camera.state.cs : 10.0

	for i in 0 ..< vertexCount {
		// sVertices[i] = {vertices[i].x * scale, -vertices[i].y * scale}
		sVertices[i] = {vertices[i].x * scale, vertices[i].y * scale}
	}

	sVertices[vertexCount] = sVertices[0]

	rl.DrawLineStrip(cast([^]rl.Vector2)raw_data(sVertices), vertexCount + 1, col)
}

@(private = "file")
DrawSolidPolygonFcn :: proc "c" (
	transform: box2d.Transform,
	vertices: [^][2]f32,
	vertexCount: i32,
	radius: f32,
	colr: box2d.HexColor,
	ctx: rawptr,
) {
	context = runtime.default_context()
	context.allocator = context.temp_allocator

	col := hexToCol(colr)

	if vertexCount <= 2 do return

	sVertices := make([][2]f32, vertexCount + 1)

	scale := (camera.state.cs > 0) ? camera.state.cs : 10.0

	for i in 0 ..< vertexCount {
		world_point := box2d.TransformPoint(transform, vertices[i])
		// sVertices[i] = {world_point.x * scale, -world_point.y * scale}
		sVertices[i] = {world_point.x * scale, world_point.y * scale}
	}

	rl.DrawTriangleFan(cast([^]rl.Vector2)raw_data(sVertices), vertexCount, col)

	sVertices[vertexCount] = sVertices[0]
	r := radius * scale

	if r > 0.0 {
		for i in 0 ..< vertexCount {
			rl.DrawCircleV(sVertices[i], r, col)
			rl.DrawLineEx(sVertices[i], sVertices[i + 1], r * 2.0, col)
		}
	} else {
		rl.DrawLineStrip(cast([^]rl.Vector2)raw_data(sVertices), vertexCount + 1, col)
	}
}

@(private = "file")
DrawCircleFcn :: proc "c" (center: [2]f32, radius: f32, color: box2d.HexColor, ctx: rawptr) {
	context = runtime.default_context()
	col := hexToCol(color)
	scale := (camera.state.cs > 0) ? camera.state.cs : 10.0

	rl.DrawCircleLinesV(center * scale, radius * scale, col)
}

@(private = "file")
DrawSolidCircleFcn :: proc "c" (
	transform: box2d.Transform,
	radius: f32,
	color: box2d.HexColor,
	ctx: rawptr,
) {
	context = runtime.default_context()
	col := hexToCol(color)
	scale := (camera.state.cs > 0) ? camera.state.cs : 10.0

	pos := rl.Vector2{transform.p.x * scale, transform.p.y * scale}
	rl.DrawCircleV(pos, radius * scale, col)
}

@(private = "file")
DrawStringFcn :: proc "c" (p: [2]f32, s: cstring, color: box2d.HexColor, ctx: rawptr) {
	context = runtime.default_context()
	col := hexToCol(color)
	scale := (camera.state.cs > 0) ? camera.state.cs : 10.0

	utils.drawText(s, .SMALL, {p.x * scale, p.y * scale}, col)
}

@(private = "file")
DrawSolidCapsuleFcn :: proc "c" (p1, p2: [2]f32, radius: f32, color: box2d.HexColor, ctx: rawptr) {
	context = runtime.default_context()
	col := hexToCol(color)
	scale := (camera.state.cs > 0) ? camera.state.cs : 10.0

	r := radius * scale

	w1 := rl.Vector2{p1.x * scale, p1.y * scale}
	w2 := rl.Vector2{p2.x * scale, p2.y * scale}

	rl.DrawLineEx(w1, w2, r * 2.0, col)
	rl.DrawCircleV(w1, r, col)
	rl.DrawCircleV(w2, r, col)
}

@(private = "file")
DrawSegmentFcn :: proc "c" (p1, p2: [2]f32, color: box2d.HexColor, ctx: rawptr) {
	context = runtime.default_context()
	col := hexToCol(color)
	scale := (camera.state.cs > 0) ? camera.state.cs : 10.0

	w1 := rl.Vector2{p1.x * scale, p1.y * scale}
	w2 := rl.Vector2{p2.x * scale, p2.y * scale}

	rl.DrawLineV(w1, w2, col)
}

@(private = "file")
DrawTransformFcn :: proc "c" (transform: box2d.Transform, ctx: rawptr) {
	context = runtime.default_context()
	scale := (camera.state.cs > 0) ? camera.state.cs : 10.0

	axis_length: f32 = 2.5
	p1 := transform.p

	p2_x := [2]f32{p1.x + (transform.q.c * axis_length), p1.y + (transform.q.s * axis_length)}
	p2_y := [2]f32{p1.x + (-transform.q.s * axis_length), p1.y + (transform.q.c * axis_length)}

	origin := rl.Vector2{p1.x * scale, p1.y * scale}
	end_x := rl.Vector2{p2_x.x * scale, p2_x.y * scale}
	end_y := rl.Vector2{p2_y.x * scale, p2_y.y * scale}

	rl.DrawLineEx(origin, end_x, 2.0, rl.RED)
	rl.DrawLineEx(origin, end_y, 2.0, rl.GREEN)

}

@(private = "file")
DrawPointFcn :: proc "c" (p: [2]f32, size: f32, color: box2d.HexColor, ctx: rawptr) {
	context = runtime.default_context()
	col := hexToCol(color)
	scale := (camera.state.cs > 0) ? camera.state.cs : 10.0

	np: [2]f32 = {p.x * scale, p.y * scale}

	rl.DrawRectangleV(np, {4, 4}, col)
}
