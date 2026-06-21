package camera

import "core:math"

CameraState :: struct {
	ar:       f32, // aspect ratio
	cs:       f32, // cell size
	w:        f32,
	h:        f32,
	hcc:      f32, // horizontal cell count // no of cells in the horizontal, vertical is calculated in the fly
	vcc:      f32, // vertical cell count
	x_offset: f32,
	y_offset: f32,
}

state: CameraState = {}

init :: proc(w: i32, h: i32) {
	state.ar = 16.0 / 9.0
	state.hcc = 80
	state.w = auto_cast w
	state.h = auto_cast h

	updateVariables()
}

cameraUpdate :: proc(w: i32, h: i32) {
	state.w = auto_cast w
	state.h = auto_cast h

	updateVariables()
}

updateVariables :: proc() {
	state.vcc = math.ceil(state.hcc / state.ar)
	vcc := state.hcc / state.ar

	a := state.w / state.h
	b := a / state.ar

	if (b == 1.0) {
		state.cs = state.w / state.hcc
		state.x_offset = 0.0
		state.y_offset = 0.0
	} else if (b > 1.0) {
		state.cs = state.h / vcc
		state.x_offset = (state.w - (state.cs * state.hcc)) / 2.0
		state.y_offset = 0.0
	} else {
		state.cs = state.w / state.hcc
		state.x_offset = 0.0
		state.y_offset = (state.h - (state.cs * vcc)) / 2.0
	}
}
