package client

import "core:math"

import "../animations"

import rl "vendor:raylib"

avatar_select_state: ClientState = {
	on_update = on_update,
	on_render = on_render,
}

@(private = "file")
on_update :: proc(dt: f32) {
    rl.GuiButton({500, 500, 30, 30}, "#114#")
    rl.GuiButton({700, 500, 30, 30}, "#115#")
}

@(private = "file")
on_render :: proc() {
	rl.ClearBackground({200, 100, 240, 255})

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
