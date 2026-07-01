package main

import "base:runtime"
import "core:fmt"

import "../client"
import "../ui"
import "../utils"

import "thirdparty:tracy"
import rl "vendor:raylib"

@(private = "file")
runLoop :: proc "c" () {
	context = runtime.default_context()
	tracy.FrameMark()

	utils.InitTimer()
	defer utils.StopTimer()

	handleNetworkInputs()

	ui.ImGuiProcessEvent()
	if client.client_state != nil && client.client_state.on_update != nil {
		client.client_state.on_update(f32(utils.dt))
	}

	client.render()

    free_all(context.temp_allocator)
}

main :: proc() {
	if client.stateInit() != true {
		fmt.println("Unable to do shti")
		return
	}

	// rl.SetConfigFlags({.WINDOW_RESIZABLE, .MSAA_4X_HINT})
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(800, 600, "BS-Odin")
	defer rl.CloseWindow()

	utils.initFont()
	defer utils.deinitFont()

	ui.ImGuiInit()
	defer ui.ImGuiClose()

	if establishConnectionWithServer() != 0 {
		fmt.println("Unable to open start enet")
		return
	}
	defer rewokeConnectionWithServer()

	// WASM
	when ODIN_OS == .JS {

	} else {
		// rl.SetTargetFPS(60) // I can do it myself
		for !client.global.quit {
			if rl.WindowShouldClose() do client.global.quit = true
			runLoop()
		}
	}

	// QUIT
	if client.client_state != nil && client.client_state.on_exit != nil {
		client.client_state.on_exit()
	}
}
