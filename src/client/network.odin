package client

import "core:fmt"

import "../camera"
import "../network"

@(private)
establishConnectionWithServer :: proc() -> int {
	if !network.InitialiseNetwork() do return 1
	return 0
}

@(private)
rewokeConnectionWithServer :: proc() {
	network.DestroyNetwork()
}

@(private)
sendInputsToServer :: proc() {
	if !network.IsConnected() {
		return
	}

	if global.input.x_axis == 0.0 && global.input.y_axis == 0.0 {
		return
	}

	camera.StartTagAlong(gPlayer.pos)
	network.Send(&global.input, size_of(global.input))
}

handleNetworkInputs :: proc() {
	loop: for {
		switch event in network.GetNetworkEvent() {
		case network.connect:
			fmt.println("Connection succeeded.")

		case network.disconnect:
			fmt.println("Disconnection succeeded.")
			global.render_state = {}

		case network.receive:
			// todo: prevent copy of massive data
			client_state.on_network_event(event.packet)

		case network.none:
			break loop
		}
	}
}

toggleConnection :: proc() {
	if !network.IsConnected() {
		network.Connect(global.net.host, global.net.port)
	} else do network.Disconnect()
}
