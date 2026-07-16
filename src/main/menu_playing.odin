package client

import "../playing"
import "../utils"

import "thirdparty:orui"
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

	{orui.container(orui.id(getId()), {width = orui.grow(), height = orui.grow()})
		{orui.container(orui.id(getId()), {width = orui.grow()})}

		if orui.label(
			orui.id(getId()),
			"\u0078",
			{
				width = orui.fixed(40),
				height = orui.fixed(40),
				align = {.Center, .Center},
				font = utils.getIconFont(),
				font_size = 30,
				color = rl.BLACK,
				background_color = CYAN,
				border = getBorder(),
				border_color = rl.BLACK,
				corner_radius = orui.corner(10),
				margin = orui.margin(10),
			},
		) {
			changeState(&end_screen_state)
		}
	}
}
