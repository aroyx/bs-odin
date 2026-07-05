package main

import "core:fmt"

import "../client/"

@(private)
establishConnectionWithServer :: proc() -> int {
	if !InitialiseNetwork() do return 1
	return 0
}

@(private)
rewokeConnectionWithServer :: proc() {
	DestroyNetwork()
}

@(private)
sendInputsToServer :: proc() {
	if !IsConnected() {
		return
	}

	if client.input.x_axis == 0.0 && client.input.y_axis == 0.0 {
		return
	}

	Send(&client.input, size_of(client.input))
}

handleNetworkInputs :: proc() {
	loop: for {
		switch event in GetNetworkEvent() {
		case connect:
			fmt.println("Connection succeeded.")

		case disconnect:
			fmt.println("Disconnection succeeded.")
			// client.global.render_state = {}

		case receive:
			// todo: prevent copy of massive data
			// client.client_state.on_network_event(event.packet)

		case none:
			break loop
		}
	}
}

toggleConnection :: proc() {
	if !IsConnected() {
		// Connect(client.global.net.host, client.global.net.port)
	} else do Disconnect()
}
