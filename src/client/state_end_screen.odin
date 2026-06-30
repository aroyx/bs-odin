package client

import "../utils"

import rl "vendor:raylib"

end_screen_state: ClientState = {
	on_render = on_render,
}

@(private = "file")
on_event :: proc() {
	if rl.IsKeyPressed(.R) {
		changeState(&main_menu_state)
	}
}

@(private = "file")
on_render :: proc() {
    rl.ClearBackground({80, 30, 80, 255})
	utils.drawCenteredText("Game End!\nIf you want to start again, press 'R'!", tint = rl.WHITE)
}
