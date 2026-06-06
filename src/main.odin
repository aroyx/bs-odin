package main

import "vendor:sdl3"

main :: proc() {
	window: ^sdl3.Window = sdl3.CreateWindow("HMH-Odin", 800, 600, {.RESIZABLE})
	sdl3.SetHint(sdl3.HINT_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR, "0")

	defer sdl3.DestroyWindow(window)

	renderer := sdl3.CreateRenderer(window, nil)
	defer sdl3.DestroyRenderer(renderer)

	quit: bool = false
	event: sdl3.Event

	alu := 1024 * 1024 * 1024

	for !quit {
		sdl3.SetRenderDrawColor(renderer, 200, 100, 240, 255)
		sdl3.RenderClear(renderer)

		for (sdl3.PollEvent(&event)) {
			if event.type == .QUIT {
				quit = true
				break
			}
		}

		sdl3.RenderPresent(renderer)
		sdl3.Delay(16)
		alu += 1
	}
}
