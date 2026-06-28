package server

import enet "vendor:ENet"

import "../types"

sendDataToClients :: proc() {
	if global.server_state == .COUNTDOWN do updateCountdown()
	else if global.server_state == .MATCH_RUNNING do broadcastData()
}

broadcastData :: proc() {
	if len(global.players) == types.MAX_PLAYERS {
		server_output: types.ServerOutput = {
			type         = .SERVER_OUTPUT,
			player_count = u8(len(global.players)),
		}

		i := 0
		for _, player in global.players {
			server_output.states[i] = {
				id  = player.id,
				pos = player.pos,
			}
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

broadcastLoading :: proc() {
	loading_output: types.Loading = {
		type = .LOADING,
		seed = global.seed,
	}

	packet := enet.packet_create(&loading_output, size_of(loading_output), {.RELIABLE})
	enet.host_broadcast(server, 0, packet)
}

broadcastCountDown :: proc(time: u8, show: bool = true) {
	countdown_output: types.CountDownOutput = {
		type = .COUNTDOWN_OUTPUT,
		time = time,
		show = show,
	}

	packet := enet.packet_create(&countdown_output, size_of(countdown_output), {.RELIABLE})
	enet.host_broadcast(server, 0, packet)
}

broadcastMatchStart :: proc() {
	match_start: types.MatchStartOutput = {
		type = .MATCH_START,
	}

	packet := enet.packet_create(&match_start, size_of(match_start), {.RELIABLE})
	enet.host_broadcast(server, 0, packet)
}
