package client

import sdl "vendor:sdl3"

@(private = "file")
window: ^sdl.Window

renderer: ^sdl.Renderer

@(private = "file")
event: sdl.Event

initWindow :: proc() -> int {
	window = sdl.CreateWindow("bs-odin", 800, 600, {.RESIZABLE})
	sdl.SetHint(sdl.HINT_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR, "0")

	renderer = sdl.CreateRenderer(window, nil)
	return 0
}

destroyWindow :: proc() {
	sdl.DestroyRenderer(renderer)
	sdl.DestroyWindow(window)
}

handleInputs :: proc() {
	for (sdl.PollEvent(&event)) {
		if event.type == .QUIT {
			quit = true
			break
		} else if event.type == .KEY_DOWN && event.key.scancode == .C {
			toggleConnection()
		}
	}
}
