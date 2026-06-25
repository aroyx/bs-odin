package client

import "core:fmt"

import "src:client/network"

import "vendor:sdl3"

window: ^sdl3.Window
renderer: ^sdl3.Renderer

@(private = "file")
event: sdl3.Event

initWindow :: proc() -> int {
	if !sdl3.Init({.VIDEO + .JOYSTICK}) {
		fmt.printf("Failed to initialise SDL!\n%s\n", sdl3.GetError())
		return 1
	}

	sdl3.SetHint(sdl3.HINT_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR, "0")
	window = sdl3.CreateWindow("bs-odin", 800, 600, {.RESIZABLE})

	if window == nil {
		fmt.printf("Failed to create window!\n%s\n", sdl3.GetError())
		return 1
	}

	renderer = sdl3.CreateRenderer(window, nil)
	if window == nil {
		fmt.printf("Failed to create Renderer!\n%s\n", sdl3.GetError())
		sdl3.DestroyWindow(window)
		return 1
	}
	sdl3.SetRenderDrawBlendMode(renderer, {.BLEND})

	if initFonts() != 0 {
		fmt.println("Failed to initialise fonts!")
		return 1
	}

	ImGuiInit()

	return 0
}

destroyWindow :: proc() {
	ImGuiClose()

	closeFont()
	sdl3.DestroyRenderer(renderer)
	sdl3.DestroyWindow(window)
}

handleUserInputs :: proc() {
	for (sdl3.PollEvent(&event)) {
		ImGuiProcessEvent(&event)

		if event.type == .QUIT {
			global.quit = true
		} else if event.type == .KEY_DOWN && event.key.scancode == .P {
			network.Ping()
		}

		if client_state != nil && client_state.on_event != nil {
			client_state.on_event(&event)
		}
	}
}
