package client

import "core:fmt"

import "../utils"
import "../ui"

import "thirdparty:tracy"
import rl "vendor:raylib"

render :: proc() {
	tracy.ZoneN("Render Everything")

	ui.ImGuiNewFrame()
	rl.BeginDrawing()
	{
		tracy.ZoneN("Render State")
		if client_state != nil && client_state.on_render != nil {
			client_state.on_render()
		}
	}

	renderFps()

    ui.ImGuiRender()
	rl.EndDrawing()
}

@(private = "file")
cfps := 60.0 // cumulative fps
@(private = "file")
cft := 16.0
@(private = "file")
alpha :: 1.0 / 10.0

renderFps :: proc() {
	if !global.time.show_fps do return

	cfps = cfps + alpha * (utils.fps - cfps) // exponential moving avg
	cft = cft + alpha * (utils.frame_time - cft) // exponential moving avg

	// cfps = cfps + (fps - cfps) / counter // moving avg, hard to detech changes when counter gets too big
	// counter += 1

	text := fmt.ctprintf("FPS: %d\nFrame Time: %fms", u32(cfps), cft)
	w, h := getTextSize("FPS: 100\nFrame Time: 16.999ms", .MEDIUM)

	rekt: rl.Rectangle = {
		height = h + 16,
		width  = w + 16,
		x      = 0,
		y      = 0,
	}

	rl.DrawRectangleRec(rekt, {220, 200, 200, 200})

	drawText(text, .MEDIUM, {8, 8}, rl.BLACK)
}
