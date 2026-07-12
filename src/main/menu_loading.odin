package client

import "../camera"
import "../physics"
import "../terrain"
import "../utils"
import "core:math"

import rl "vendor:raylib"
LoadingState :: enum u8 {
	INIT,
	CAMERA,
	TERRAIN,
	PHYSICS,
	ENEMIES,
	DONE,
}

loading_state: ClientState = {
	on_enter  = on_enter,
	on_update = on_update,
	on_render = on_render,
}

@(private = "file")
lState := LoadingState.INIT

@(private = "file")
on_enter :: proc() {
	lState = .INIT
}

@(private = "file")
on_update :: proc(dt: f32) {
	switch (lState) {

	case .INIT:
		lState = .CAMERA

	case .CAMERA:
		w := rl.GetRenderWidth()
		h := rl.GetRenderHeight()
		camera.init(w, h, utils.MAP_SIZE)
		lState = .TERRAIN

	case .TERRAIN:
		terrain.createTerrain()
		lState = .PHYSICS

	case .PHYSICS:
		physics.initPhysics()
		lState = .ENEMIES

	case .ENEMIES:
		generateEntities()
		camera.startTagAlong(getPlayer().pos, 4.0)
		lState = .DONE

	case .DONE:
		changeState(&playing_state)
	}
}

@(private = "file")
on_render :: proc() {
	rl.ClearBackground({174, 226, 255, 255})
	win_w, win_h := f32(rl.GetRenderWidth()), f32(rl.GetRenderHeight())

	w := i32(win_w * 0.8)
	x := i32((win_w - f32(w)) * 0.5)
	y := i32(win_h * 0.8)
	h := math.min(20, i32(win_h * 0.2))

	text: cstring

	tiny_w: i32 = 10
	progress: f32 = 0.0
	switch (lState) {
	case .INIT:
		text = "Initialising stuff...the brick is working hard!"
		tiny_w = 0
		progress = 0.0
	case .CAMERA:
		text = "Lights, camera...loading and Action!"
		progress = 0.1
	case .TERRAIN:
		text = "Like the god I am, I create thy land"
		progress = 0.2
	case .PHYSICS:
		text = "Newton go brr... initialising physics"
		progress = 0.5
	case .ENEMIES:
		text = "To create balance, we need both evil and good"
		progress = 0.8
	case .DONE:
		text = "We legit don now :)"
		progress = 1.0
	}

	progress_w := i32(progress * f32(w))

	rl.DrawRectangle(x, y, w, h, {73, 1, 41, 255})
	rl.DrawRectangle(x, y, progress_w, h, {216, 91, 63, 255})
	rl.DrawRectangle(progress_w - tiny_w + x, y, tiny_w, h, {253, 218, 136, 255})
	rl.DrawRectangleLines(x, y, w, h, rl.BLACK)

	a, b := utils.getTextSize(text, .MEDIUM)
	tx: f32 = (win_w - a) * 0.5
	ty := f32(y + h) + 10
	utils.drawText(text, .MEDIUM, {tx, ty}, rl.BLACK)
}
