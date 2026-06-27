package client

import "base:runtime"
import "core:fmt"

import "src:client/utils"

import "thirdparty:tracy"
import rl "vendor:raylib"

@(private = "file")
runLoop :: proc "c" () {
	context = runtime.default_context()
	tracy.FrameMark()

	utils.InitTimer()
	defer utils.StopTimer()

	handleNetworkInputs()

    ImGuiProcessEvent()
	if client_state != nil && client_state.on_update != nil {
		client_state.on_update(f32(utils.dt))
	}

	render()
}


main :: proc() {
	if stateInit() != true {
		fmt.println("Unable to do shti")
		return
	}

	// rl.SetConfigFlags({.WINDOW_RESIZABLE, .MSAA_4X_HINT})
	rl.SetConfigFlags({.WINDOW_RESIZABLE, .VSYNC_HINT})
	rl.InitWindow(800, 600, "BS-Odin")
	defer rl.CloseWindow()

    initFont()
    defer deinitFont()

    ImGuiInit()
    defer ImGuiClose()

	if establishConnectionWithServer() != 0 {
		fmt.println("Unable to open start enet")
		return
	}
	defer rewokeConnectionWithServer()

	// WASM
	when ODIN_OS == .JS {

	} else {
		// rl.SetTargetFPS(60) // I can do it myself
		for !global.quit {
			if rl.WindowShouldClose() do global.quit = true
			runLoop()
		}
	}

	// QUIT
	if client_state != nil && client_state.on_exit != nil {
		client_state.on_exit()
	}
}
