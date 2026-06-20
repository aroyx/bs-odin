package client

import "thirdparty:imgui"
import "thirdparty:imgui/imgui_impl_sdl3"
import "thirdparty:imgui/imgui_impl_sdlrenderer3"

import "core:fmt"
import "src:client/network"
import "src:common"
import "thirdparty:tracy"
import sdl "vendor:sdl3"
import "vendor:sdl3/ttf"

show_demo_window := true

render :: proc() {
	tracy.Zone()

	defer sdl.RenderPresent(renderer)

	imgui_impl_sdl3.NewFrame()
	imgui_impl_sdl3.NewFrame()
	imgui.NewFrame()

	defer imgui_impl_sdlrenderer3.RenderDrawData(imgui.GetDrawData(), renderer)
	defer imgui.Render()

	imgui.Begin("Data")
	defer imgui.End()

	{
		tracy.ZoneN("Render Screen")
		switch global.client_state {
		case .MAIN_MENU:
			render_main_menu()
			break
		case .MATCH_MAKING:
			render_match_making()
			break
		case .PLAYING:
			render_playing()
			break
		case .END_SCREEN:
			render_end_screen()
			break
		}
	}

	render_fps()
}

render_main_menu :: proc() {
	sdl.SetRenderDrawColor(renderer, 200, 100, 240, 255)
	sdl.RenderClear(renderer)

	draw_centered_text(welcome_text)
}

render_match_making :: proc() {
	sdl.SetRenderDrawColor(renderer, 10, 200, 120, 255)
	sdl.RenderClear(renderer)

	// render "Match-Making!" in the center
	draw_centered_text(match_making_text, y_offset = -60.0)

	// render "Total players: 1/2" in the center slightly lower
	text: cstring = "Unable to connect to any server!\nMaybe the server is down?\n\nPlease Exit and try again later"

	if network.IsConnected() {
		text = fmt.ctprintf(
			"Total Players: %d/%d",
			global.render_state.player_count,
			common.MAX_PLAYERS,
		)
	}

	players_text := ttf.CreateText(engine, font, text, 0)
	ttf.SetTextColor(players_text, 255, 255, 255, 255)

	draw_centered_text(players_text)

	ttf.DestroyText(players_text)

	if global.time.countdown.show {
		// render "Total players: 1/2" in the center slightly lower
		text := fmt.ctprintf("Match Starts in: %ds", global.time.countdown.time)
		cnt_text := ttf.CreateText(engine, font, text, 0)
		ttf.SetTextColor(cnt_text, 255, 255, 255, 255)
		draw_centered_text(cnt_text, y_offset = 30.0)
		ttf.DestroyText(cnt_text)
	}
}

render_playing :: proc() {
	sdl.SetRenderDrawColor(renderer, 0, 0, 0, 255) // black
	sdl.RenderClear(renderer)

	render_terrain()

	green: sdl.Color
	green.r = 0
	green.g = 255
	green.b = 0
	green.a = 255

	blue: sdl.Color
	blue.r = 0
	blue.g = 0
	blue.b = 255
	blue.a = 255

	for i in 0 ..< global.render_state.player_count {
		player := global.render_state.states[i]
		rect: sdl.FRect

		dim :: 30
		rect.h = dim
		rect.w = dim
		rect.x = player.x - (dim * 0.5)
		rect.y = player.y - (dim * 0.5)

		sdl.SetRenderDrawColor(
			renderer,
			0,
			u8((player.x / 800.0) * 255.0),
			u8((player.y / 600.0) * 255.0),
			0,
		)

		sdl.RenderFillRect(renderer, &rect)
	}
}

render_end_screen :: proc() {
	sdl.SetRenderDrawColor(renderer, 80, 30, 80, 255)
	sdl.RenderClear(renderer)

	draw_centered_text(end_screen_text)
}

@(private = "file")
cfps := 60.0 // cumulative fps
@(private = "file")
cft := 16.0
@(private = "file")
alpha :: 2.0 / (20.0 + 1.0)

render_fps :: proc() {
	tracy.Zone()
	if !global.time.show_fps do return

	cfps = cfps + alpha * (global.time.fps - cfps) // exponential moving avg
	cft = cft + alpha * (global.time.frame_time - cft) // exponential moving avg

	// cfps = cfps + (fps - cfps) / counter // moving avg, hard to detech changes when counter gets too big
	// counter += 1

	ttf.SetFontWrapAlignment(font, .LEFT)

	text := fmt.ctprintf("FPS: %d\nFrame Time: %fms", u32(cfps), cft)
	fps_text := ttf.CreateText(engine, font, text, 0)
	ttf.SetTextColor(fps_text, 10, 10, 10, 255)
	ttf.DrawRendererText(fps_text, 0, 0)
	ttf.DestroyText(fps_text)

	ttf.SetFontWrapAlignment(font, .CENTER)
}

draw_centered_text :: proc(text: ^ttf.Text, x_offset: f32 = 0.0, y_offset: f32 = 0.0) {
	tracy.Zone()
	if text == nil do return

	w, h, tw, th: i32
	sdl.GetWindowSize(window, &w, &h)
	ttf.GetTextSize(text, &tw, &th)

	x := (f32(w - tw) * 0.5) + x_offset
	y := (f32(h - th) * 0.5) + y_offset

	ttf.DrawRendererText(text, x, y)
}
