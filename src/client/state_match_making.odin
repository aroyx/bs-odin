package client

import "../utils"
import "core:math"
import "core:math/linalg"

import rl "vendor:raylib"

match_making_state: ClientState = {
	on_update = on_update,
	on_render = on_render,
}

@(private = "file")
on_update :: proc(dt: f32) {
	win_w, win_h := f32(rl.GetRenderWidth()), f32(rl.GetRenderHeight())

	padding: f32 = 80
	gap: f32 = 40
	width := math.max(win_w - gap - padding * 2, 300) * 0.5

    gap = math.min(gap, win_w - width * 2)
	padding = win_w - width * 2 - gap // update padding, should be the initial value if 300 is not max

	height: f32 = 40

	anchor: linalg.Vector2f32 = {
		padding * 0.5,
		math.min(win_h * 0.8, win_h - height),
	}

	bounds: rl.Rectangle = {
		x      = anchor.x,
		y      = anchor.y,
		width  = width,
		height = height,
	}

	if rl.GuiButton(bounds, "Continue :)") {
		changeState(&loading_state)
	}

	bounds.x += width + gap
	if rl.GuiButton(bounds, "Cancel :(") {
		changeState(&main_menu_state)
	}
}

// @(private = "file")
// on_network_event :: proc(pEvent: network.ReceivedStruct) {
// 	#partial switch packet in pEvent {
// 	case types.MatchMakingOutput:
// 		global.render_state.player_count = packet.player_count
// 	case types.CountDownOutput:
// 		global.time.countdown = packet
// 	case types.Loading:
//         terrain.setSeed(packet.seed)
// 		changeState(&playing_state)
// 	}
// }

@(private = "file")
on_render :: proc() {
	rl.ClearBackground({10, 200, 120, 255})

	// render "Match-Making!" in the center
	utils.drawCenteredText("Match-Making!", .LARGE, y_offset = -60.0)

	// render "Total players: 1/2" in the center slightly lower
	// text: cstring = "Unable to connect to any server!\nMaybe the server is down?\n\nPlease Exit and try again later"

	// if network.IsConnected() {
	// 	text = fmt.ctprintf(
	// 		"Total Players: %d/%d",
	// 		global.render_state.player_count,
	// 		types.MAX_PLAYERS,
	//  	)
	// }

	utils.drawCenteredText("Server is currently under construction!", y_offset = -12)
	// utils.drawCenteredText("Press 'O' to play offline!", y_offset = 12)

	// if global.time.countdown.show {
	// 	// render "Total players: 1/2" in the center slightly lower
	// 	text := fmt.ctprintf("Match Starts in: %ds", global.time.countdown.time)
	// 	utils.drawCenteredText(text, y_offset = 30.0)
	// }
}
