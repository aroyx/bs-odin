package client

import "../camera"
import "../physics"
import "../terrain"
import "../utils"
import "core:math"
import "core:time"

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
	on_exit   = on_exit,
	on_update = on_update,
	on_render = on_render,
}

@(private = "file")
lState := LoadingState.INIT

@(private = "file")
on_enter :: proc() {
}

@(private = "file")
on_exit :: proc() {
}

@(private = "file")
on_update :: proc(dt: f32) {
	switch (lState) {

	case .INIT:
		rl.SetExitKey(.KEY_NULL) // whatif they esc prees accidentially while parkouring?
		lState = .CAMERA

	case .CAMERA:
		w := rl.GetScreenWidth()
		h := rl.GetScreenHeight()
		camera.Init(w, h, utils.MAP_SIZE)
		lState = .TERRAIN

	case .TERRAIN:
		terrain.createTerrain()
		lState = .PHYSICS

	case .PHYSICS:
		physics.initPhysics()
		lState = .ENEMIES

	case .ENEMIES:
		generateEntities()
		camera.StartTagAlong(getPlayer().pos, 4.0)
		lState = .DONE

	case .DONE:
		changeState(&playing_state)
	// for network
	// ready: types.ClientReady = {
	// 	type = .CLIENT_READY,
	// }
	// network.Send(&ready, size_of(ready), true)
	}

	time.sleep(500 * time.Millisecond) // to see the loading screen
}

@(private = "file")
on_render :: proc() {
	rl.ClearBackground(rl.LIME)
	win_w, win_h := f32(rl.GetRenderWidth()), f32(rl.GetRenderHeight())

	w := i32(win_w * 0.8)
	x := i32((win_w - f32(w)) * 0.5)
	y := i32(win_h * 0.8)
	h := math.min(20, i32(win_h * 0.2))

	tiny_w: i32 = 10
	progress: f32 = 0.0
	switch (lState) {
	case .INIT:
		tiny_w = 0
		progress = 0.0
	case .CAMERA:
		progress = 0.1
	case .TERRAIN:
		progress = 0.2
	case .PHYSICS:
		progress = 0.5
	case .ENEMIES:
		progress = 0.8
	case .DONE:
		progress = 1.0
	}

	progress_w := i32(progress * f32(w))

	rl.DrawRectangle(x, y, w, h, {73, 1, 41, 255})
	rl.DrawRectangle(x, y, progress_w, h, {216, 91, 63, 255})
	rl.DrawRectangle(progress_w - tiny_w + x, y, tiny_w, h, {253, 218, 136, 255})
	rl.DrawRectangleLines(x, y, w, h, rl.BLACK)
}
