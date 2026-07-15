package client

import "core:fmt"

import "../utils"

import "thirdparty:orui"
import rl "vendor:raylib"

end_screen_state: ClientState = {
	on_update = on_update,
	on_render = on_render,
}

@(private = "file")
on_update :: proc(dt: f32) {
	if rl.IsKeyPressed(.ESCAPE) {
		utils.global.quit = true
	}
}

@(private = "file")
on_render :: proc() {
	rl.ClearBackground({80, 30, 80, 255})
	// utils.drawCenteredText("Game End!", .LARGE, tint = rl.WHITE, y_offset = -12)
	// utils.drawCenteredText("Thank you very much for playing!!", tint = rl.WHITE, y_offset = 24)

	{orui.container(
			orui.id("main_thing"),
			{
				direction = .TopToBottom,
				width = orui.grow(),
				height = orui.grow(),
				align_cross = .Center,
			},
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

			orui.label(
				orui.id("matchmakign"),
				"Game End!",
				{
					font = utils.getFont(.LARGE),
					font_size = utils.getFontSize(.LARGE),
					height = orui.fit(),
					color = rl.BLACK,
				},
			)

			orui.label(
				orui.id("construction"),
				"Thank you very much for playing!!",
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
					width = orui.fit(),
					height = {type = .Percent, value = 0.2, min = 40},
					align_main = .Center,
				},
			)

			if menuButton(1, "Restart? :)", {0, 180, 216, 255}) {
				changeState(&main_menu_state)
			}
			if menuButton(2, "Quit :(", {249, 65, 68, 255}) {
				fmt.println("Thanks for playing till the end!")
				utils.global.quit = true
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
			width = orui.grow(),
			height = orui.fit(),
			margin = orui.margin(10, 20),
			padding = orui.padding(20, 10),
			font_size = 20,
			align = {.Center, .Center},
			background_color = orui.animate(
				"bg-color",
				orui.active() ? rl.ColorLerp(col, rl.WHITE, 0.20) : col,
			),
			color = rl.BLACK,
			corner_radius = orui.corner(4),
			border = getBorder(),
			border_color = rl.BLACK,
		},
	)
}
