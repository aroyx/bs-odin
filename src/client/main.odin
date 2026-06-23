package client

import "src:client/camera"
import "core:fmt"
import "src:client/utils"
import "thirdparty:tracy"

runLoop :: proc() {
	for !global.quit {
		tracy.FrameMark()

		utils.InitTimer()
		defer utils.StopTimer()

		render()
		handleUserInputs()
		sendInputsToServer()
		handleNetworkInputs()
        camera.cameraUpdate()
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
