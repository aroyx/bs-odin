package client

import "core:fmt"
import enet "vendor:ENet"

connected := false
connecting := false

@(private = "file")
peer: ^enet.Peer = nil

@(private = "file")
client: ^enet.Host = nil

@(private = "file")
net_event: enet.Event = {}

establishConnectionWithServer :: proc() -> int {
	if enet.initialize() != 0 {
		fmt.println("Unable to Initialize enet, Stopping the client")
		return 1
	}


	client = enet.host_create(nil, 1, 2, 0, 0)

	if client == nil {
		fmt.println("Unable to create the client thingy!")
		return 1
	}
	return 0
}

rewokeConnectionWithServer :: proc() {
	if connected {
		enet.peer_reset(peer)
	}
	enet.host_destroy(client)
	enet.deinitialize()
}

getDataFromServer :: proc() {

}

sendDataToServer :: proc() {
}

handleNetworkEvents :: proc() {
	for enet.host_service(client, &net_event, 0) > 0 {
		#partial switch (net_event.type) {
		case .CONNECT:
			fmt.println("Connection succeeded.")
			connected = true
			connecting = false
			break
		case .RECEIVE:
			enet.packet_destroy(net_event.packet)
			break
		case .DISCONNECT:
			fmt.println("Disconnection succeeded.")
			connected = false
			break
		}
	}
}

toggleConnection :: proc() {
	if !connected && !connecting {
		address: enet.Address = {}
		enet.address_set_host(&address, "127.0.0.1")
		address.port = 7777

		peer = enet.host_connect(client, &address, 2, 0)
		if peer == nil {
			fmt.println("No available peers for initiating an ENet connection.")
			return
		}

		connecting = true
	}

	if connected {
		enet.peer_disconnect(peer, 0)
	}
}
