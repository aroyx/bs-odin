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
	rl.InitWindow(800, 600, "BS-Odin")

	// utils.loadRayGuiStyleFromMemory(style_genesis_raw)

	rl.GuiLoadStyle("res/rgui/style_genesis.rgs")
	rl.GuiSetStyle(.DEFAULT, i32(rl.GuiDefaultProperty.TEXT_SIZE), 32)
	rl.GuiSetStyle(
		.CHECKBOX,
		i32(rl.GuiControlProperty.TEXT_COLOR_FOCUSED),
		transmute(i32)u32(0xDEDEDEFF),
	)

	utils.initFont()
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
