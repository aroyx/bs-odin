package client

import "base:runtime"
import "core:fmt"

import "src:client/utils"

import "thirdparty:tracy"
import "vendor:sdl3"

IMGUI_ENABLE :: #config(IMGUI_ENABLE, true)

@(private = "file")
init :: proc "c" (appstate: ^rawptr, argc: i32, argv: [^]cstring) -> sdl3.AppResult {
	context = runtime.default_context()
	if stateInit() != true {
		fmt.println("Unable to do shti")
		return .FAILURE
	}

	if initWindow() != 0 {
		fmt.println("Unable to open Window")
		return .FAILURE
	}

	if establishConnectionWithServer() != 0 {
		fmt.println("Unable to open start enet")
		return .FAILURE
	}

	return .CONTINUE
}

@(private = "file")
iterate :: proc "c" (appstate: rawptr) -> sdl3.AppResult {
	context = runtime.default_context()
	tracy.FrameMark()
	if global.quit == true do return .SUCCESS

	utils.InitTimer()
	defer utils.StopTimer()

	sendInputsToServer()
	handleNetworkInputs()

	if client_state != nil && client_state.on_update != nil {
		client_state.on_update(f32(utils.dt))
	}

	render()

	return .CONTINUE
}

@(private = "file")
event :: proc "c" (appstate: rawptr, event: ^sdl3.Event) -> sdl3.AppResult {
	context = runtime.default_context()
	handleUserInputs(event)
	return .CONTINUE
}

@(private = "file")
quit :: proc "c" (appstate: rawptr, result: sdl3.AppResult) {
	context = runtime.default_context()

	if client_state != nil && client_state.on_exit != nil {
		client_state.on_exit()
	}

	rewokeConnectionWithServer()
	destroyWindow()
}

main :: proc() {
	sdl3.EnterAppMainCallbacks(0, nil, init, iterate, event, quit)
}
