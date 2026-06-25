package client

import "core:fmt"

import "src:client/utils"

import "thirdparty:tracy"
import "vendor:sdl3"
import "vendor:sdl3/ttf"

show_demo_window := true

render :: proc() {
	tracy.Zone()

	ImGuiNewFrame()
	{
		tracy.ZoneN("Render Screen")
		if client_state != nil && client_state.on_render != nil {
			client_state.on_render()
		}
	}

	renderFps()
	ImGuiRender()

	sdl3.RenderPresent(renderer)
}

@(private = "file")
cfps := 60.0 // cumulative fps
@(private = "file")
cft := 16.0
@(private = "file")
alpha :: 1.0 / 10.0

renderFps :: proc() {
	tracy.Zone()
	if !global.time.show_fps do return

	cfps = cfps + alpha * (utils.fps - cfps) // exponential moving avg
	cft = cft + alpha * (utils.frame_time - cft) // exponential moving avg

	// cfps = cfps + (fps - cfps) / counter // moving avg, hard to detech changes when counter gets too big
	// counter += 1

	ttf.SetFontWrapAlignment(font, .LEFT)

	text := fmt.ctprintf("FPS: %d\nFrame Time: %fms", u32(cfps), cft)
	fps_text := ttf.CreateText(engine, font, text, 0)

	w, h: i32
	ttf.GetTextSize(fps_text, &w, &h)

	rekt: sdl3.FRect = {
		h = f32(h) + 16,
		w = f32(w) + 16,
		x = 0,
		y = 0,
	}

	sdl3.SetRenderDrawColor(renderer, 220, 200, 200, 200)
	sdl3.RenderFillRect(renderer, &rekt)

	ttf.SetTextColor(fps_text, 10, 10, 10, 255)
	ttf.DrawRendererText(fps_text, 8, 8)
	ttf.DestroyText(fps_text)

	ttf.SetFontWrapAlignment(font, .CENTER)
}

drawCenteredText :: proc(text: ^ttf.Text, x_offset: f32 = 0.0, y_offset: f32 = 0.0) {
	tracy.Zone()
	if text == nil do return

	w, h, tw, th: i32
	sdl3.GetWindowSize(window, &w, &h)
	ttf.GetTextSize(text, &tw, &th)

	x := (f32(w - tw) * 0.5) + x_offset
	y := (f32(h - th) * 0.5) + y_offset

	ttf.DrawRendererText(text, x, y)
}
