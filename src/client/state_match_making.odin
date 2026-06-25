package client

import "core:fmt"

import "src:client/network"
import "src:common"

import "vendor:sdl3"
import "vendor:sdl3/ttf"

match_making_state: ClientState = {
	on_event         = on_event,
	on_render        = on_render,
	on_network_event = on_network_event,
}

@(private = "file")
on_event :: proc(event: ^sdl3.Event) {
	if event.type == .KEY_DOWN {
		if event.key.scancode == .C {
			changeState(&main_menu_state)
			toggleConnection()
		}
	}
}

@(private = "file")
on_network_event :: proc(pEvent: network.ReceivedStruct) {
	#partial switch packet in pEvent {
	case common.MatchMakingOutput:
		global.render_state.player_count = packet.player_count
	case common.CountDownOutput:
		global.time.countdown = packet
	case common.MatchStartOutput:
		changeState(&playing_state)
	}
}

@(private = "file")
on_render :: proc() {
	sdl3.SetRenderDrawColor(renderer, 10, 200, 120, 255)
	sdl3.RenderClear(renderer)

	// render "Match-Making!" in the center
	drawCenteredText(match_making_text, y_offset = -60.0)

	// render "Total players: 1/2" in the center slightly lower
	text: cstring = "Unable to connect to any server!\nMaybe the server is down?\n\nPlease Exit and try again later"

	if network.IsConnected() {
		text = fmt.ctprintf(
			"Total Players: %d/%d",
			global.render_state.player_count,
			common.MAX_PLAYERS,
		)
	}

	players_text := ttf.CreateText(engine, font, text, 0)
	ttf.SetTextColor(players_text, 255, 255, 255, 255)

	drawCenteredText(players_text)

	ttf.DestroyText(players_text)

	if global.time.countdown.show {
		// render "Total players: 1/2" in the center slightly lower
		text := fmt.ctprintf("Match Starts in: %ds", global.time.countdown.time)
		cnt_text := ttf.CreateText(engine, font, text, 0)
		ttf.SetTextColor(cnt_text, 255, 255, 255, 255)
		drawCenteredText(cnt_text, y_offset = 30.0)
		ttf.DestroyText(cnt_text)
	}
}
