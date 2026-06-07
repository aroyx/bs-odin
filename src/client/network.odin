package client

import "core:fmt"
import "src:common"
import enet "vendor:ENet"

connected := false
connecting := false

@(private = "file")
peer: ^enet.Peer = nil

@(private = "file")
client: ^enet.Host = nil

@(private = "file")
net_event: enet.Event = {}

my_id: uintptr = 0

establishConnectionWithServer :: proc() -> int {
	if enet.initialize() != 0 {
		fmt.println("Unable to Initialise enet, Stopping the client")
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
	if !connected || peer == nil {
		return
	}

	if input.x_axis == 0.0 && input.y_axis == 0.0 {
		return
	}

	packet := enet.packet_create(&input, size_of(input), {.UNSEQUENCED})
	enet.peer_send(peer = peer, channelID = 0, packet = packet)
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
			defer enet.packet_destroy(net_event.packet)

			packet_type := (cast(^common.PacketType)net_event.packet.data)^

			if packet_type == .NEW_JOIN {
				new_join := cast(^common.NewJoin)net_event.packet.data
				my_id = new_join.id
			} else if packet_type == .SERVER_OUTPUT {
				server_out := cast(^common.ServerOutput)net_event.packet.data
				render_state = server_out^
			}

			break
		case .DISCONNECT:
			fmt.println("Disconnection succeeded.")
			connected = false
			peer = nil
            render_state = {}
            my_id = 0
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
