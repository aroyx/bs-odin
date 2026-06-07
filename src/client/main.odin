package client

import "core:fmt"

quit := false

runLoop :: proc() {

	for !quit {
		getDataFromServer()
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
