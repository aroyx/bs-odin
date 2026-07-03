package client

import "../utils"

import "core:fmt"
import "core:math"
import "core:math/linalg"

import rl "vendor:raylib"

end_screen_state: ClientState = {
	on_update = on_update,
	on_render = on_render,
}

@(private = "file")
on_update :: proc(dt: f32) {
	win_w, win_h := f32(rl.GetRenderWidth()), f32(rl.GetRenderHeight())

	padding: f32 = 80
	gap: f32 = 40
	width := math.max(win_w - gap - padding * 2, 300) * 0.5

	gap = math.min(gap, win_w - width * 2)
	padding = win_w - width * 2 - gap // update padding, should be the initial value if 300 is not max

	height: f32 = 40

	anchor: linalg.Vector2f32 = {padding * 0.5, math.min(win_h * 0.8, win_h - height)}

	bounds: rl.Rectangle = {
		x      = anchor.x,
		y      = anchor.y,
		width  = width,
		height = height,
	}

	if rl.GuiButton(bounds, "Restart?") {
		changeState(&main_menu_state)
	}

	bounds.x += width + gap
	if rl.GuiButton(bounds, "Quit") {
		fmt.println("Thanks for playing till the end!")
		global.quit = true
	}
}

@(private = "file")
on_render :: proc() {
	rl.ClearBackground({80, 30, 80, 255})
	utils.drawCenteredText("Game End!", .LARGE, tint = rl.WHITE, y_offset = -12)
	utils.drawCenteredText(
		"Thank you very much for playing!!",
		tint = rl.WHITE,
		y_offset = 24,
	)
}
