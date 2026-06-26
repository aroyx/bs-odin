package client

import rl "vendor:raylib"

main_menu_state: ClientState = {
	on_update = on_update,
	on_render = on_render,
}

@(private = "file")
on_update :: proc(dt: f32) {
	if rl.IsKeyPressed(.Q) {
		global.quit = true
	}
	if rl.IsKeyPressed(.C) {
		changeState(&match_making_state)
		toggleConnection()
	}
}

@(private = "file")
on_render :: proc() {
	rl.ClearBackground({200, 100, 240, 255})
	drawCenteredText("Welcome To BS Brawl Starts!", y_offset = -24)
	drawCenteredText("Press 'C' to connect", y_offset = 0)
	drawCenteredText("Press 'Q' to quit", y_offset = 24)
	drawCenteredText("Hope you enjoy playing!", y_offset = 72)
}
