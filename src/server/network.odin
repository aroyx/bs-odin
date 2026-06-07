package server

import "src:common"
import "core:fmt"
import enet "vendor:ENet"

server: ^enet.Host

initialiseNetwork :: proc() -> int {
	if enet.initialize() != 0 {
		fmt.println("Unable to Initialise enet, Stopping the server")
		return 1
	}

	address: enet.Address = {
		host = enet.HOST_ANY,
		port = 7777,
	}

	server = enet.host_create(&address, common.MAX_PLAYERS, 2, 0, 0)

	if server == nil {
		fmt.println("Unable to create the server!")
		return 1
	}

	fmt.println("Server Started successfully!")

	return 0
}

stopNetwork :: proc() {
    enet.host_destroy(server)
	enet.deinitialize()
}
