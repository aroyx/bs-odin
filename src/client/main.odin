package client

import "core:time"
import "core:fmt"

runLoop :: proc() {
	for !quit {
        initTimer()
        defer stopTimer()

		render()
		handleInputs()
		sendDataToServer()
		handleNetworkEvents()
		time.sleep(16 * time.Millisecond)// make new func fpsCapper
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
