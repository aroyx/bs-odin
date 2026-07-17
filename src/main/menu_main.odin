package client

import "../utils"
import "../playing"

import "thirdparty:orui"
import rl "vendor:raylib"

main_menu_state: ClientState = {
	on_enter  = on_enter,
	on_update = on_update,
	on_render = on_render,
}

@(private = "file")
inited_player := false

@(private = "file")
on_enter :: proc() {
	rl.SetExitKey(.KEY_NULL)
	if !inited_player {
		playing.playerSkinRandomize()
		inited_player = true
	}
}

@(private = "file")
on_update :: proc(dt: f32) {
	if rl.IsKeyPressed(.Q) || rl.IsKeyPressed(.ESCAPE) {
		utils.global.quit = true
	}

    updateAnimPlayer()
}

@(private = "file")
on_render :: proc() {
	rl.ClearBackground({177, 221, 194, 255})

    drawAnimPlayer()

	{orui.container(
			orui.id("main_container"),
			{
				direction = .LeftToRight,
				width     = orui.grow(),
				height    = orui.grow(), //
			},
		)
		{
			orui.container(
				orui.id("left_part"),
				{ 	// character drawn
					width  = orui.grow(),
					height = orui.grow(),
					// background_color = {255,255,255,100},
				},
			)
		}
		{
			orui.container(
				orui.id("right_buttons"),
				{
					width = {type = .Percent, value = 0.35, min = 250},
					height = orui.grow(),
					margin = orui.margin(20, 0),
					direction = .TopToBottom,
					align_main = .Center,
					align_cross = .Center,
				},
			)
			{
				orui.container(
					orui.id("buttons_collection"),
					{
						direction = .TopToBottom,
						gap = 10,
						padding = orui.padding(20),
						corner_radius = orui.corner(8),
						background_color = BLUE,
						border_color = rl.BLACK,
						border = orui.border(4),
					},
				)
				{
					if menuButton(1, "Start :)", CYAN) {
						changeState(&match_making_state)
					}
					if menuButton(2, "Options :|", WHITE) {
						changeState(&options_state)
					}
					if menuButton(3, "Avatar :D", YELLOW) {
						changeState(&avatar_select_state)
					}
					if menuButton(4, "Quit :(", RED) {
						utils.global.quit = true
					}
				}
			}
		}
	}
}

@(private = "file")
menuButton :: proc(id: int, text: string, col: rl.Color = rl.DARKGRAY) -> bool {
	return orui.label(
		orui.id(id), //
		text,
		{
			width = orui.fixed(200),
			height = orui.fixed(40),
			font_size = 20,
			align = {.Center, .Center},
			background_color = orui.animate(
				"bg-color",
				orui.active() ? rl.ColorLerp(col, rl.WHITE, 0.35) : col,
			),
			color = rl.BLACK,
			corner_radius = orui.corner(4),
			border = getBorder(),
			border_color = rl.BLACK,
		},
	)
}
