package client

import "core:c"
import "core:fmt"
import "core:math/rand"

import "../animations"
import "../terrain"
import "../ui"
import "../utils"

import rl "vendor:raylib"

init :: proc() {
	// rl.SetConfigFlags({.WINDOW_RESIZABLE, .MSAA_4X_HINT})
	rl.SetTraceLogLevel(.WARNING)
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(1280, 720, "BS-Odin")

	utils.initFont()
	ui.init()
	animations.init()

	a: i32 = rand.int31()
	// a = 1667919536
	terrain.setSeed(a)
	fmt.println("seed:", a)

	changeState(&main_menu_state)
	if client_state != nil && client_state.on_enter != nil {
		client_state.on_enter()
	}
}

update :: proc() {
	utils.initTimer()
	defer utils.stopTimer()

	ui.tick()

	if client_state != nil && client_state.on_update != nil {
		client_state.on_update(f32(utils.dt))
	}

	render()

	free_all(context.temp_allocator)
}

close :: proc() {
	if client_state != nil && client_state.on_exit != nil {
		client_state.on_exit()
	}

	animations.close()
	ui.close()
	utils.deinitFont()

	rl.CloseWindow()
}

shouldRun :: proc() -> bool {
	if global.quit {
		return false
	}
	when ODIN_OS != .JS {
		if rl.WindowShouldClose() {
			return false
		}
	}
	return true
}

windowSizeChanged :: proc(w, h: int) {
	rl.SetWindowSize(c.int(w), c.int(h))
}
