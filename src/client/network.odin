package client

import "core:fmt"
import "src:client/network"
import "src:common"
import "thirdparty:tracy"

establishConnectionWithServer :: proc() -> int {
	if !network.InitialiseNetwork() do return 1
	return 0
}

rewokeConnectionWithServer :: proc() {
	network.DestroyNetwork()
}

sendInputsToServer :: proc() {
	tracy.Zone()

	if !network.IsConnected() {
		return
	}

	if global.input.x_axis == 0.0 && global.input.y_axis == 0.0 {
		return
	}

	network.Send(&global.input, size_of(global.input))
}

handleNetworkInputs :: proc() {
	tracy.Zone()

	loop: for {
		switch event in network.GetNetworkEvent() {

		case network.connect:
			fmt.println("Connection succeeded.")

		case network.disconnect:
			fmt.println("Disconnection succeeded.")
			global.render_state = {}

		case network.receive:
			switch packet in event.packet {

			case common.ServerOutput:
				global.render_state = packet

			case common.MatchMakingOutput:
				global.render_state.player_count = packet.player_count

			case common.CountDownOutput:
				global.time.countdown = packet

			case common.MatchStartOutput:
				global.client_state = .PLAYING
			}

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
