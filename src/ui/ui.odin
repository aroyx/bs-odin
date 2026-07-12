package ui

import rl "vendor:raylib"
import "thirdparty:orui"
import "../utils"

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
		orui.render_command(render_cmd)
	}

	ImGuiRender()
}

tick :: proc() {
    ImGuiProcessEvent()
}
