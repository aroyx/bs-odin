package client

import "vendor:sdl3"

main_menu_state: ClientState = {
	on_event  = on_event,
	on_render = on_render,
}

@(private = "file")
on_event :: proc(event: ^sdl3.Event) {
	if event.type == .KEY_DOWN {
		if event.key.scancode == .C {
            changeState(&match_making_state)
			toggleConnection()
		}
		if event.key.scancode == .Q {
            global.quit = true
        }
	}
}

@(private = "file")
on_render :: proc() {
	sdl3.SetRenderDrawColor(renderer, 200, 100, 240, 255)
	sdl3.RenderClear(renderer)

	drawCenteredText(welcome_text)
}
