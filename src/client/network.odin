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

	if input.x_axis == 0.0 && input.y_axis == 0.0 {
		return
	}

	network.SendDataToServerU(&input, size_of(input))
}

handleNetworkInputs :: proc() {
	tracy.Zone()

	loop: for {
		switch event in network.GetNetworkEvent() {

		case network.connect:
			fmt.println("Connection succeeded.")

		case network.disconnect:
			fmt.println("Disconnection succeeded.")
			render_state = {}

		case network.receive:
			switch packet in event.packet {

			case common.ServerOutput:
				render_state = packet

			case common.MatchMakingOutput:
				render_state.player_count = packet.player_count

			case common.CountDownOutput:
				countdown = packet

			case common.MatchStartOutput:
				client_state = .PLAYING
			}

		case network.none:
			break loop
		}
	}
}

toggleConnection :: proc() {
	if !network.IsConnected() {
		network.ConnectToServer()
	} else do network.DisconnectFromServer()
}
