package client

import "../utils"

import "thirdparty:orui"

import rl "vendor:raylib"

match_making_state: ClientState = {
	on_update = on_update,
	on_render = on_render,
}

@(private = "file")
on_update :: proc(dt: f32) {
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

	{orui.container(
			orui.id("main_thing"),
			{direction = .TopToBottom, width = orui.grow(), height = orui.grow()},
		)
		{
			orui.container(
				orui.id("upper texts"),
				{
					direction = .TopToBottom,
					width = orui.grow(),
					height = orui.grow(),
					align_main = .Center,
					align_cross = .Center,
				},
			)

			orui.label(orui.id("filler"), "", {height = orui.grow()})

			orui.label(
				orui.id("matchmakign"),
				"Match-Making!",
				{
					font = utils.get_font(.LARGE),
					font_size = utils.get_font_size(.LARGE),
					height = orui.fit(),
					color = rl.BLACK,
				},
			)

			orui.label(
				orui.id("construction"),
				"Server is currently under construction!",
				{
					height = orui.fit(),
					font_size = 24,
					color = rl.BLACK,
					padding = orui.padding(20),
				},
			)
		}
		{
			orui.container(
				orui.id("lower buttons"),
				{
					direction = .LeftToRight,
					width = orui.grow(),
					height = {type = .Percent, value = 0.2, min = 40},
					background_color = rl.BLACK,
				},
			)
		}
	}
}
