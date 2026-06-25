package client

import "vendor:sdl3"

end_screen_state: ClientState = {
	on_event  = on_event,
	on_render = on_render,
}

@(private = "file")
on_event :: proc(event: ^sdl3.Event) {
	if event.type == .KEY_DOWN {
		if event.key.scancode == .R {
            changeState(&main_menu_state)
		}
	}
}

@(private = "file")
on_render :: proc() {
	sdl3.SetRenderDrawColor(renderer, 80, 30, 80, 255)
	sdl3.RenderClear(renderer)

	drawCenteredText(end_screen_text)
}
