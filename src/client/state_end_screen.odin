package client

import "../utils"
import "core:fmt"

import rl "vendor:raylib"

end_screen_state: ClientState = {
	on_update = on_update,
	on_render = on_render,
}

@(private = "file")
on_update :: proc(dt: f32) {
	if rl.IsKeyPressed(.R) {
		changeState(&main_menu_state)
	} else if rl.IsKeyPressed(.Q) {
		fmt.println("Thanks for playing till the end!")
		global.quit = true
	}
}

@(private = "file")
on_render :: proc() {
	rl.ClearBackground({80, 30, 80, 255})
	utils.drawCenteredText("Game End!", tint = rl.WHITE, y_offset = -12)
	utils.drawCenteredText(
		"If you want to start again, press 'R'!",
		tint = rl.WHITE,
		y_offset = 12,
	)

	utils.drawCenteredText(
		"To quit press 'Q' again!",
		size = .LARGE,
		tint = rl.WHITE,
		y_offset = 48,
	)
}
