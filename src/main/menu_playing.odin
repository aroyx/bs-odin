package client

import "../playing"

import rl "vendor:raylib"

playing_state: ClientState = {
	on_enter  = on_enter,
	on_exit   = on_exit,
	on_update = on_update,
	on_render = on_render,
}

@(private = "file")
on_enter :: proc() {
	playing.enter()
}

@(private = "file")
on_exit :: proc() {
	playing.exit()
}

@(private = "file")
on_update :: proc(dt: f32) {
	clearId()
	playing.update(dt)
}

@(private = "file")
on_render :: proc() {
	rl.ClearBackground({2, 5, 17, 255})

	playing.render()
	if playing.renderUI() {
		changeState(&end_screen_state)
	}
}
