package client

import sdl "vendor:sdl3"

render :: proc() {
	sdl.SetRenderDrawColor(renderer, 200, 100, 240, 255)
	sdl.RenderClear(renderer)
	sdl.RenderPresent(renderer)
	sdl.Delay(16) // make new func fpsCapper
}
