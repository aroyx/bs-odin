package client

import "core:fmt"
import "thirdparty:tracy"

runLoop :: proc() {
	for !quit {
        tracy.FrameMark()

		initTimer()
		defer stopTimer()

		render()
		handleUserInputs()
		sendInputsToServer()
		handleNetworkInputs()
	}
}

main :: proc() {
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
