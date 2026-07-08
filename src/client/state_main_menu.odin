package client

import "core:fmt"
import "core:math"
import "core:math/linalg"

import "../animations"

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

	// change this if you add new buttons!!! This is used to calculate the anchor position!!!
	buttons_count: f32 = 4.0

	// this math is easy, but I bet I won't know what is going on the very next day.
	win_w, win_h := f32(rl.GetRenderWidth()), f32(rl.GetRenderHeight())

	gap: f32 = 50.0
	height: f32 = 40.0
	min_width: f32 = 200

	anchor: linalg.Vector2f32 = {
		math.min(win_w * 0.65, win_w - min_width),
		(win_h - gap * (buttons_count - 1) - height) * 0.5,
	}

	bounds: rl.Rectangle = {
		x      = anchor.x,
		y      = anchor.y,
		width  = math.max(win_w * 0.3, min_width),
		height = height,
	}

	mouse := rl.GetMousePosition()

	// the bg rect
	grow: i32 = 20

	rl.DrawRectangle(
		i32(anchor.x) - grow,
		i32(anchor.y) - grow,
		i32(bounds.width) + grow * 2,
		i32(gap * (buttons_count - 1) + height) + grow * 2,
		{181, 234, 192, 61},
	)

	if rl.GuiButton(bounds, "Start :)") {
		changeState(&match_making_state)
	}

	bounds.y += gap
	if rl.GuiButton(bounds, "Options :|") {
		changeState(&options_state)
	}

	bounds.y += gap
	if rl.GuiButton(bounds, "Avatar :D") {
		fmt.println("Yay!3")
		// changeState(&character_customisation_state)
	}

	bounds.y += gap
	if rl.GuiButton(bounds, "Quit :(") {
		global.quit = true
	}

	rl.GuiDisableTooltip()
}

@(private = "file")
on_render :: proc() {
	rl.ClearBackground({200, 100, 240, 255})

	type := animations.CharacterType.SKELETON
	tier := animations.CharacterTier.T1

	win_w, win_h := f32(rl.GetRenderWidth()), f32(rl.GetRenderHeight())
	tex_w, tex_h: f32 = 230, 500 // approx

	available_w := math.min(win_w * 0.65, win_w - 200)
	available_h := math.min(win_h * 0.6, 400)

	scale := math.min(available_w / tex_w, available_h / tex_h)

    x := available_w * scale * 0.5
    y := tex_h * scale + (win_h - available_h * scale) * 0.5

	draw_commands := run_animation({x, y}, scale)
	defer delete(draw_commands)

	for cmd in draw_commands {
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
