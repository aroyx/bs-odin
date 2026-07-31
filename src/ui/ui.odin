package ui

import "../playing"
import "../utils"

import "thirdparty:orui"
import rl "vendor:raylib"

@(private)
ui_ctx: ^orui.Context

init :: proc() {
	ImGuiInit()

	ui_ctx = new(orui.Context)
	orui.init(ui_ctx)
	ui_ctx.default_font = utils.getFont(.MEDIUM)^
}

close :: proc() {
	ImGuiClose()

	orui.destroy(ui_ctx)
}

start :: proc() {
	ImGuiNewFrame()

	win_w, win_h := f32(rl.GetRenderWidth()), f32(rl.GetRenderHeight())
	orui.begin(ui_ctx, win_w, win_h, f32(utils.dt))
}

render :: proc() {
	render_cmds := orui.end()

	for render_cmd in render_cmds {
		if render_cmd.type == .Custom {
			data := render_cmd.data.(orui.RenderCommandDataCustom)

			if data.custom_event == &playing.attack_button_data {
                playing.attack_button_data.rect = data.rectangle

				if playing.attack_button_data.texture.id == 0 do continue

				tex := playing.attack_button_data.texture

				rekt := data.rectangle
				center := [2]f32{rekt.x + (rekt.width / 2), rekt.y + (rekt.height / 2)}

				src: rl.Rectangle = {
					x      = 0,
					y      = 0,
					width  = f32(tex.width),
					height = f32(tex.height),
				}

				scale := (rekt.width - 30) / f32(max(tex.width, tex.height))
				dst := rl.Rectangle {
					x      = center.x,
					y      = center.y,
					width  = src.width * scale,
					height = src.height * scale,
				}

				origin := [2]f32{dst.width / 2, dst.height / 2}

				rl.DrawTexturePro(tex, src, dst, origin, -45, rl.WHITE)

				cool_down := playing.attack_button_data.cool_down
				if cool_down <= 0 do continue

				s_angle: f32 = -90
				e_angle: f32 = cool_down * 360 + s_angle

				rl.DrawRing(
					center,
					0,
					rekt.width / 2,
					s_angle,
					e_angle,
					32,
					rl.ColorAlpha(rl.BLACK, 0.5),
				)
			} else if data.custom_event == &playing.joystick_data {
				playing.joystick_data = data.rectangle
                orui.render_command(render_cmd)
			}
		} else {
			orui.render_command(render_cmd)
		}
	}

	ImGuiRender()
}

tick :: proc() {
	ImGuiProcessEvent()
}
