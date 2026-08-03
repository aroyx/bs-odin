package ui

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

	init_mouse()
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

setCallBack :: proc(cb: proc(cmd: orui.RenderCommand) -> bool) {
	call_back = cb
}

@(private = "file")
call_back: proc(cmd: orui.RenderCommand) -> bool

render :: proc() {
	render_cmds := orui.end()

	for render_cmd in render_cmds {
		if render_cmd.type == .Custom {

			render_yeah := false

			if call_back != nil {
				render_yeah = call_back(render_cmd)
			}

            if !render_yeah {
                orui.render_command(render_cmd)
            }

		} else {
			orui.render_command(render_cmd)
		}
	}

	ImGuiRender()
	renderMouse()
}

tick :: proc() {
	ImGuiProcessEvent()
}
