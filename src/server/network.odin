package server

import "core:fmt"
import "core:math/rand"
import enet "vendor:ENet"

import "../types"

server: ^enet.Host
event: enet.Event

initialiseNetwork :: proc() -> int {
	if enet.initialize() != 0 {
		fmt.println("Unable to Initialise enet, Stopping the server")
		return 1
	}

	address: enet.Address = {
		host = enet.HOST_ANY,
		port = global.net.port,
	}

	server = enet.host_create(&address, types.MAX_PLAYERS, 2, 0, 0)

	if server == nil {
		fmt.println("Unable to create the server!")
		return 1
	}
	return 0
}

stopNetwork :: proc() {
	enet.host_destroy(server)
	enet.deinitialize()
}

pollEvents :: proc() {
	for enet.host_service(server, &event, 16) > 0 {
		switch event.type {
		case enet.EventType.CONNECT:
			{
				handleConnect()
				break
			}
		case enet.EventType.DISCONNECT:
			{
				handleDisconnect()
				break
			}
		case enet.EventType.RECEIVE:
			{
				handleRecieve()
				break
			}
		case enet.EventType.NONE:
			{
				fmt.printf("Whar are you upto mate\n")
				break
			}
		}
	}
}

sendDataToClients :: proc() {
	if global.server_state == .COUNTDOWN do updateCountdown()
	else if global.server_state == .MATCH_RUNNING do broadcastData()
}

handleConnect :: proc() {
	id := uintptr(global.client_id_counter)
	global.client_id_counter += 1

	fmt.printf("A new client connected with id: %d\n", id)
	event.peer.data = rawptr(id)

	// do smth about these variables
	map_size: f32 = 129.0
	cell_size: f32 = 10.0

	global.players[id] = types.PlayerState {
		id  = id,
		pos = {rand.float32() * map_size * cell_size, rand.float32() * map_size * cell_size},
	}

	newJoin: types.NewJoin = {
		type = .NEW_JOIN,
		id   = id,
	}

	packet := enet.packet_create(&newJoin, size_of(newJoin), {.RELIABLE})
	enet.peer_send(event.peer, 0, packet)

	if global.server_state == .MATCH_MAKING {
		broadcastPlayerCount()
	}

	if len(global.players) == types.MAX_PLAYERS {
		startCountdown()
	}
}

handleDisconnect :: proc() {
	id := uintptr(event.peer.data)
	fmt.printf("A connection was disconnected with id: %d\n", id)
	event.peer.data = nil
	delete_key(&global.players, id)

	if global.server_state == .MATCH_MAKING {
		broadcastPlayerCount()
	}

	if global.server_state == .COUNTDOWN {
		global.server_state = .MATCH_MAKING
		sendCountDown(0, false)
		broadcastPlayerCount()
	}
}

handleRecieve :: proc() {
	defer enet.packet_destroy(event.packet)

	packet_type := cast(^types.PacketType)event.packet.data
	id := uintptr(event.peer.data)

	if packet_type^ == .PING {
		a: types.Ping = {.PING}

		packet := enet.packet_create(&a, size_of(a), {.RELIABLE})
		enet.peer_send(event.peer, 0, packet)
	}

	if packet_type^ != .PLAYER_INPUT {
		return
	}

	// if event.packet.dataLength != size_of(types.PlayerInput) {
	// 	break
	// }

	if !(id in global.players) {
		return
	}

	input := cast(^types.PlayerInput)event.packet.data
	state := &global.players[id]

	speed: f32 = 5.0
	state.pos.x += input.x_axis * speed
	state.pos.y += input.y_axis * speed
}

broadcastData :: proc() {
	if len(global.players) == types.MAX_PLAYERS {
		server_output: types.ServerOutput = {
			type         = .SERVER_OUTPUT,
			player_count = u8(len(global.players)),
		}

		i := 0
		for _, player in global.players {
			server_output.states[i] = player
			i += 1
		}

		packet := enet.packet_create(&server_output, size_of(server_output), {.UNSEQUENCED})
		enet.host_broadcast(server, 0, packet)
	}
}

broadcastPlayerCount :: proc() {
	match_making_output: types.MatchMakingOutput = {
		type         = .MATCH_MAKING_OUTPUT,
		player_count = u8(len(global.players)),
	}

	packet := enet.packet_create(&match_making_output, size_of(match_making_output), {.RELIABLE})
	enet.host_broadcast(server, 0, packet)
}

sendCountDown :: proc(time: u8, show: bool = true) {
	countdown_output: types.CountDownOutput = {
		type = .COUNTDOWN_OUTPUT,
		time = time,
		show = show,
	}

	packet := enet.packet_create(&countdown_output, size_of(countdown_output), {.RELIABLE})
	enet.host_broadcast(server, 0, packet)
}

sendMatchStartSignal :: proc() {
	match_start: types.MatchStartOutput = {
		type = .MATCH_START,
	}

	packet := enet.packet_create(&match_start, size_of(match_start), {.RELIABLE})
	enet.host_broadcast(server, 0, packet)
}
