package client

import "core:c"
import "core:fmt"

import "../client"
import "../ui"
import "../utils"

import rl "vendor:raylib"

init :: proc() {
	if client.stateInit() != true {
		fmt.println("Unable to do shti")
		return
	}

	// rl.SetConfigFlags({.WINDOW_RESIZABLE, .MSAA_4X_HINT})
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(800, 600, "BS-Odin")

	// utils.loadRayGuiStyleFromMemory(style_genesis_raw)

    rl.GuiLoadStyle("res/rgui/style_genesis.rgs")
	rl.GuiSetStyle(.DEFAULT, i32(rl.GuiDefaultProperty.TEXT_SIZE), 32)
    rl.GuiSetStyle(.CHECKBOX, i32(rl.GuiControlProperty.TEXT_COLOR_FOCUSED), transmute(i32)u32(0xDEDEDEFF))

	utils.initFont()

	ui.ImGuiInit()

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

	if client.client_state != nil && client.client_state.on_update != nil {
		client.client_state.on_update(f32(utils.dt))
	}

	client.render()
	free_all(context.temp_allocator)
}

close :: proc() {
	if client.client_state != nil && client.client_state.on_exit != nil {
		client.client_state.on_exit()
	}
	// rewokeConnectionWithServer()
	ui.ImGuiClose()
	utils.deinitFont()
	rl.CloseWindow()
}

shouldRun :: proc() -> bool {
	if client.global.quit {
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
