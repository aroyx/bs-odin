package client

import "core:fmt"
import "thirdparty:tracy"

runLoop :: proc() {
	for !quit {
        defer tracy.FrameMark()

		initTimer()
		defer stopTimer()

		render()
		handleInputs()
		sendDataToServer()
		handleNetworkEvents()
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
