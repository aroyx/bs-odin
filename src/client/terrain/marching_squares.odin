package terrain

import "src:client/camera"

import "core:math"
import "core:math/linalg"

import rl "vendor:raylib"

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

// I HAND WROTE THIS FOR PEAK UNDERSTANDING!! BUT BUT BUT!!! MY RENDERING ORDER
// IS IN CLOCKWISE WINDING ORDER INSTEAD OF ANTI-CLOCKWISE THAT MOST RENDERING
// APIS USE
// But fortunately I can just push the triangles in reverse order :)

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

    // clockwise
	// shape := lookup[total - 1]
	// for k := 0; k < len(shape); k += 3 {
	// 	pushTriangle(points[shape[k]], points[shape[k + 1]], points[shape[k + 2]], color)
	// }

    // anti-clockwise (allegedly)
	shape := lookup[total - 1]
	for k := 0; k < len(shape); k += 3 {
		pushTriangle(points[shape[k + 2]], points[shape[k + 1]], points[shape[k]], color)
	}
}

@(private = "file")
li :: proc(v1, v2, t: f32) -> f32 { 	// linear interpolation
	if math.abs(v2 - v1) < 0.00001 do return 0.5
	return (t - v1) / (v2 - v1)
}
