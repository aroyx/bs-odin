package client

import "../utils"
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
	utils.drawCenteredText("Welcome To BS Brawl Starts!", y_offset = -24)
	utils.drawCenteredText("Press 'C' to connect", y_offset = 0)
	utils.drawCenteredText("Press 'Q' to quit", y_offset = 24)
	utils.drawCenteredText("Hope you enjoy playing!", y_offset = 72)
}
