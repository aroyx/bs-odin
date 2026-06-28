package client

import "core:fmt"

import "../network"
import "../types"

import rl "vendor:raylib"

match_making_state: ClientState = {
	on_update        = on_update,
	on_render        = on_render,
	on_network_event = on_network_event,
}

@(private = "file")
on_update :: proc(dt: f32) {
	if rl.IsKeyPressed(.C) {
		changeState(&main_menu_state)
		toggleConnection()
	}
}

@(private = "file")
on_network_event :: proc(pEvent: network.ReceivedStruct) {
	#partial switch packet in pEvent {
	case types.MatchMakingOutput:
		global.render_state.player_count = packet.player_count
	case types.CountDownOutput:
		global.time.countdown = packet
	case types.MatchStartOutput:
		changeState(&playing_state)
	}
}

@(private = "file")
on_render :: proc() {
	rl.ClearBackground({10, 200, 120, 255})

	// render "Match-Making!" in the center
	drawCenteredText("Match-Making!", y_offset = -60.0)

	// render "Total players: 1/2" in the center slightly lower
	text: cstring = "Unable to connect to any server!\nMaybe the server is down?\n\nPlease Exit and try again later"

	if network.IsConnected() {
		text = fmt.ctprintf(
			"Total Players: %d/%d",
			global.render_state.player_count,
			types.MAX_PLAYERS,
		)
	}

	drawCenteredText(text)

	if global.time.countdown.show {
		// render "Total players: 1/2" in the center slightly lower
		text := fmt.ctprintf("Match Starts in: %ds", global.time.countdown.time)
		drawCenteredText(text, y_offset = 30.0)
	}
}
