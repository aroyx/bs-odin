package server

import "core:fmt"

main :: proc() {
	if initialiseNetwork() != 0 {
		fmt.println("Unable to Initialise Network")
		return
	}; defer stopNetwork()

	if defaultState() != true {
		fmt.println("Unable to Initialise the server state")
		return
	}; defer destroyState()

	fmt.println("Server Started successfully on port: ", global.net.port)

	for {
		pollEvents()
        sendDataToClients()
	}
}
