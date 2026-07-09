package client

import "core:math"

import "../animations"

import "thirdparty:orui"
import rl "vendor:raylib"

main_menu_state: ClientState = {
	on_enter  = on_enter,
	on_update = on_update,
	on_render = on_render,
}

@(private = "file")
on_enter :: proc() {
	init_player()
}

@(private = "file")
on_update :: proc(dt: f32) {
	if rl.IsKeyPressed(.Q) {
		global.quit = true
	}
}

@(private = "file")
on_render :: proc() {
	rl.ClearBackground({177, 221, 194, 255})

	win_w, win_h := f32(rl.GetRenderWidth()), f32(rl.GetRenderHeight())
	tex_w, tex_h: f32 = 230, 500 // approx

	available_w := math.min(win_w * 0.65, win_w - 200)
	available_h := math.min(win_h * 0.6, 400)

	scale := math.min(available_w / tex_w, available_h / tex_h)

	x := available_w * scale * 0.5
	y := tex_h * scale + (win_h - available_h * scale) * 0.5

	if scale > 0.2 { 	// too small to even try to draw anymore
		draw_commands := run_animation({x, y}, scale)
		defer delete(draw_commands)

		for cmd in draw_commands {
			type := player_skin.type
			tier := player_skin.parts[cmd.part]

			tex := animations.getPartTex(type, tier, cmd.part)

			source: rl.Rectangle = {
				x      = 0,
				y      = 0,
				width  = f32(tex.width),
				height = f32(tex.height),
			}

			dest: rl.Rectangle = {
				x      = cmd.x,
				y      = cmd.y,
				width  = f32(tex.width) * cmd.scale_x,
				height = f32(tex.height) * cmd.scale_y,
			}

			color: rl.Color = {255, 255, 255, u8(cmd.alpha * 255)}
			rl.DrawTexturePro(tex, source, dest, {}, cmd.angle, color)
		}
	}

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
						background_color = {0, 129, 167, 255},
					},
				)
				{
					if menu_button(1, "Start :)", {0, 175, 185, 255}) {
						changeState(&match_making_state)
					}
					if menu_button(2, "Options :|", {253, 252, 220, 255}) {
						changeState(&options_state)
					}
					if menu_button(3, "Avatar :D", {254, 217, 183, 255}) {
						changeState(&avatar_select_state)
					}
					if menu_button(4, "Quit :(", {240, 113, 103, 255}) {
						global.quit = true
					}
				}
			}
		}
	}
}

@(private = "file")
menu_button :: proc(id: int, text: string, col: rl.Color = rl.DARKGRAY) -> bool {
	return orui.label(
		orui.id(id), //
		text,
		{
			width = orui.fixed(200),
			height = orui.fixed(40),
			font_size = 20,
			align = {.Center, .Center},
			background_color = orui.animate(
				"bg-active",
				orui.active() ? col : (orui.hovered() ? rl.ColorLerp(col, rl.BLACK, 0.05) : rl.ColorLerp(col, rl.BLACK, 0.1)),
			),
			color = rl.BLACK,
			corner_radius = orui.corner(4),
		},
	)
}
