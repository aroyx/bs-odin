package client

import "core:fmt"

import "src:client/utils"

import "thirdparty:tracy"

IMGUI_ENABLE :: #config(IMGUI_ENABLE, false)

runLoop :: proc() {
	for !global.quit {
		tracy.FrameMark()

		utils.InitTimer()
		defer utils.StopTimer()

		handleUserInputs()
		sendInputsToServer()
		handleNetworkInputs()

		if client_state != nil && client_state.on_update != nil {
			client_state.on_update(f32(utils.dt))
		}

		render()
	}

	if client_state != nil && client_state.on_exit != nil {
		client_state.on_exit()
	}
}

main :: proc() {
	if stateInit() != true {
		fmt.println("Unable to do shti")
		return
	}

	if initWindow() != 0 {
		fmt.println("Unable to open Window")
		return
	}
	defer destroyWindow()

	if establishConnectionWithServer() != 0 {
		fmt.println("Unable to open start enet")
		return
	}
	defer rewokeConnectionWithServer()

	runLoop()
}
