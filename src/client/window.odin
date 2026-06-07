package client

import "core:fmt"
import sdl "vendor:sdl3"

@(private = "file")
window: ^sdl.Window

renderer: ^sdl.Renderer

@(private = "file")
event: sdl.Event

initWindow :: proc() -> int {
	if !sdl.Init({.VIDEO + .JOYSTICK}) {
		fmt.printf("Failed to initialise SDL!\n%s\n", sdl.GetError())
		return 1
	}

	sdl.SetHint(sdl.HINT_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR, "0")
	window = sdl.CreateWindow("bs-odin", 800, 600, {.RESIZABLE})

	if window == nil {
		fmt.printf("Failed to create window!\n%s\n", sdl.GetError())
		return 1
	}

	renderer = sdl.CreateRenderer(window, nil)
	if window == nil {
		fmt.printf("Failed to create Renderer!\n%s\n", sdl.GetError())
		sdl.DestroyWindow(window)
		return 1
	}
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

	keys := sdl.GetKeyboardState(nil)

	x_axis: f32 = 0
	y_axis: f32 = 0

	if keys[sdl.Scancode.W] == true {y_axis = -1}
	if keys[sdl.Scancode.S] == true {y_axis = 1}
	if keys[sdl.Scancode.A] == true {x_axis = -1}
	if keys[sdl.Scancode.D] == true {x_axis = 1}

	input.x_axis = x_axis
	input.y_axis = y_axis
	input.type = .PLAYER_INPUT
}
