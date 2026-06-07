package client

import "src:common"
import sdl "vendor:sdl3"

render_state: common.ServerOutput = {}

render :: proc() {
	sdl.SetRenderDrawColor(renderer, 200, 100, 240, 255)
	sdl.RenderClear(renderer)

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

	for i in 0 ..< render_state.player_count {
		player := render_state.states[i]
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

	sdl.RenderPresent(renderer)
	sdl.Delay(16) // make new func fpsCapper
}
