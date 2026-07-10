package client

import "core:c"
import "core:fmt"
import "core:math/rand"

import "../animations"
import "../terrain"
import "../ui"
import "../utils"

import "thirdparty:orui"
import rl "vendor:raylib"

@(private)
ui_ctx: ^orui.Context

init :: proc() {
	// rl.SetConfigFlags({.WINDOW_RESIZABLE, .MSAA_4X_HINT})
	rl.SetTraceLogLevel(.WARNING)
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(800, 600, "BS-Odin")

	// utils.loadRayGuiStyleFromMemory(style_genesis_raw)

	utils.initFont()

	ui_ctx = new(orui.Context)
	orui.init(ui_ctx)
	ui_ctx.default_font = utils.getFont(.MEDIUM)^

	ui.ImGuiInit()

	animations.init()

	a: i32 = rand.int31()
	// a = 1667919536
	terrain.setSeed(a)
	fmt.println("seed:", a)

	changeState(&main_menu_state)
	if client_state != nil && client_state.on_enter != nil {
		client_state.on_enter()
	}

	// if establishConnectionWithServer() != 0 {
	// 	fmt.println("Unable to open start enet")
	// 	return
	// }
	// rewokeConnectionWithServer()
}

update :: proc() {
	utils.InitTimer()
	defer utils.StopTimer()

	// handleNetworkInputs()

	ui.ImGuiProcessEvent()

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
	// rewokeConnectionWithServer()

	orui.destroy(ui_ctx)
	animations.close()
	ui.ImGuiClose()
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
