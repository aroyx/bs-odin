package camera

import "core:math"
import "core:math/ease"
import "core:math/linalg"

import "../utils"

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

init :: proc(w: i32, h: i32, map_size: i32) {
	state.ar = 16.0 / 9.0
	state.hcc = 40
	state.w = auto_cast w
	state.h = auto_cast h

	updateVariables()

	hms: f32 = f32(map_size) / 2
	camPos = {hms * state.cs, hms * state.cs}
}

sizeUpdate :: proc(w: i32, h: i32) {
	state.w = auto_cast w
	state.h = auto_cast h

	updateVariables()
}

updateVariables :: proc() {
	state.vcc = math.ceil(state.hcc / state.ar)
	vcc := state.hcc / state.ar

	a := state.w / state.h
	b := a / state.ar

	if (b >= 1.0) {
		state.cs = state.h / vcc
		state.x_offset = (state.w - (state.cs * state.hcc)) / 2.0
		state.y_offset = 0.0
	} else {
		state.cs = state.w / state.hcc
		state.x_offset = 0.0
		state.y_offset = (state.h - (state.cs * vcc)) / 2.0
	}
}

camPos: linalg.Vector2f32

@(private = "file")
startPos: linalg.Vector2f32

@(private = "file")
targetPos: linalg.Vector2f32

@(private = "file")
elapsed: f32 = 0.0

@(private = "file")
dur: f32 = 0.5 // sec

startTagAlong :: proc(pos: linalg.Vector2f32, pDur: f32 = 0.5) {
    dur = pDur
	elapsed = 0
	startPos = camPos
	targetPos = pos
}

update :: proc() {
	if elapsed >= dur {
		camPos = targetPos
		return
	}

	elapsed += auto_cast utils.dt
	if elapsed > dur do elapsed = dur

	t := elapsed / dur
	// e := ease.exponential_out(t) // dur = 1.5
	e := ease.cubic_out(t) // dur = 0.5

	camPos = startPos + (targetPos - startPos) * e
}

isMoving :: proc() -> bool {
	return elapsed < dur
}
