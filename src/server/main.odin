package server

import "core:math/rand"
import "core:time"
import "src:common"

import "core:fmt"
import enet "vendor:ENet"

main :: proc() {
	if initialiseNetwork() != 0 {
		fmt.println("Unable to Initialise Network")
		return
	}; defer stopNetwork()

	event: enet.Event
	client_id_counter: uintptr = 0

	active_players := make(map[uintptr]common.PlayerState)
	defer delete(active_players)

	for {
		for enet.host_service(server, &event, 0) > 0 {
			switch event.type {
			case enet.EventType.CONNECT:
				{
					id := uintptr(client_id_counter)
					client_id_counter += 1

					fmt.printf("A new client connected with id: %d\n", id)
					event.peer.data = rawptr(id)

					active_players[id] = common.PlayerState {
						id = id,
						x  = f32(rand.int31() % 800),
						y  = f32(rand.int31() % 600),
					}

					newJoin: common.NewJoin = {
						type = .NEW_JOIN,
						id   = id,
					}

					packet := enet.packet_create(&newJoin, size_of(newJoin), {.RELIABLE})
					enet.peer_send(event.peer, 0, packet)
					break
				}
			case enet.EventType.DISCONNECT:
				{
					id := uintptr(event.peer.data)
					fmt.printf("A connection was disconnected with id: %d\n", id)
					event.peer.data = nil
					delete_key(&active_players, id)
					break
				}
			case enet.EventType.RECEIVE:
				{
					defer enet.packet_destroy(event.packet)

					packet_type := cast(^common.PacketType)event.packet.data
					id := uintptr(event.peer.data)

					if packet_type^ != .PLAYER_INPUT {
						break
					}

					// if event.packet.dataLength != size_of(common.PlayerInput) {
					// 	break
					// }

					if !(id in active_players) {
						break
					}

					input := cast(^common.PlayerInput)event.packet.data
					state := &active_players[id]

					speed: f32 = 5.0
					state.x += input.x_axis * speed
					state.y += input.y_axis * speed

					break
				}
			case enet.EventType.NONE:
				{
					fmt.printf("Whar are you upto mate\n")
					break
				}
			}

			if len(active_players) > 0 {
				server_output: common.ServerOutput = {
					type         = .SERVER_OUTPUT,
					player_count = u8(len(active_players)),
				}

				i := 0
				for _, player in active_players {
					server_output.states[i] = player
					i += 1
				}

				packet := enet.packet_create(
					&server_output,
					size_of(server_output),
					{.UNSEQUENCED},
				)
				enet.host_broadcast(server, 0, packet)
			}
		}

		time.sleep(16 * time.Millisecond) // 60fps
	}
}
