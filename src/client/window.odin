package client

import "core:fmt"
import "thirdparty:imgui"
import "thirdparty:imgui/imgui_impl_sdl3"
import "thirdparty:imgui/imgui_impl_sdlrenderer3"
import sdl "vendor:sdl3"

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

	if initFonts() != 0 {
		fmt.println("Failed to initialise fonts!")
		return 1
	}

	imgui.CHECKVERSION()
	imgui.CreateContext()
	io := imgui.GetIO()

	io.ConfigFlags += {.DockingEnable, .NavEnableGamepad}

	imgui.StyleColorsDark()

	imgui_impl_sdl3.InitForSDLRenderer(window, renderer)
	imgui_impl_sdlrenderer3.Init(renderer)

	return 0
}

destroyWindow :: proc() {
	imgui_impl_sdlrenderer3.Shutdown()
	imgui_impl_sdl3.Shutdown()
	imgui.DestroyContext()

	closeFont()
	sdl.DestroyRenderer(renderer)
	sdl.DestroyWindow(window)
}

handleUserInputs :: proc() {
	for (sdl.PollEvent(&event)) {
        imgui_impl_sdl3.ProcessEvent(&event)
		if event.type == .QUIT {
			global.quit = true
		} else if event.type == .KEY_DOWN {
			#partial switch event.key.scancode {
			case .C:
				{
					if global.client_state != .MAIN_MENU && global.client_state != .MATCH_MAKING do break

					if global.client_state == .MAIN_MENU do global.client_state = .MATCH_MAKING
					else if global.client_state == .MATCH_MAKING do global.client_state = .MAIN_MENU

					toggleConnection()
					break
				}
			case .Q:
				{
					if global.client_state == .MAIN_MENU do global.quit = true
					// esle
					// pop-up: "Are You sure?"
					break
				}
			case .R:
				{
					if global.client_state == .END_SCREEN do global.client_state = .MAIN_MENU
					break
				}
			}
		}
	}

	keys := sdl.GetKeyboardState(nil)

	x_axis: f32 = 0
	y_axis: f32 = 0

	if keys[sdl.Scancode.W] || keys[sdl.Scancode.UP] do y_axis = -1
	if keys[sdl.Scancode.S] || keys[sdl.Scancode.DOWN] do y_axis = 1
	if keys[sdl.Scancode.A] || keys[sdl.Scancode.LEFT] do x_axis = -1
	if keys[sdl.Scancode.D] || keys[sdl.Scancode.RIGHT] do x_axis = 1

	global.input.x_axis = x_axis
	global.input.y_axis = y_axis
	global.input.type = .PLAYER_INPUT
}
