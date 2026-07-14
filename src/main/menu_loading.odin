package client

import "../camera"
import "../physics"
import "../terrain"
import "../utils"

import "thirdparty:orui"
import rl "vendor:raylib"

LoadingState :: enum u8 {
	INIT,
	CAMERA,
	TERRAIN,
	PHYSICS,
	ENEMIES,
	DONE,
}

loading_state: ClientState = {
	on_enter  = on_enter,
	on_update = on_update,
	on_render = on_render,
}

@(private = "file")
lState := LoadingState.INIT

@(private = "file")
on_enter :: proc() {
	lState = .INIT
}

@(private = "file")
on_update :: proc(dt: f32) {

	if rl.IsWindowResized() {
		w := rl.GetRenderWidth()
		h := rl.GetRenderHeight()
		camera.sizeUpdate(w, h)
	}

	switch (lState) {

	case .INIT:
		lState = .CAMERA

	case .CAMERA:
		w := rl.GetRenderWidth()
		h := rl.GetRenderHeight()
		camera.init(w, h, utils.MAP_SIZE)
		lState = .TERRAIN

	case .TERRAIN:
	terrain.createTerrain()
	lState = .PHYSICS

	case .PHYSICS:
		physics.initPhysics()
		lState = .ENEMIES

	case .ENEMIES:
		generateEntities()
		camera.startTagAlong(getPlayer().pos, 4.0)
		lState = .DONE

	case .DONE:
		changeState(&playing_state)
	}

	clearId()
}

@(private = "file")
on_render :: proc() {
	rl.ClearBackground({174, 226, 255, 255})

	loading_text: string
	progress: f32 = 0.0

	switch (lState) {
	case .INIT:
		loading_text = "Initialising stuff...the brick is working hard!"
		progress = 0.0
	case .CAMERA:
		loading_text = "Lights, camera...loading and Action!"
		progress = 0.1
	case .TERRAIN:
		loading_text = "Like the god I am, I create thy land"
		progress = 0.2
	case .PHYSICS:
		loading_text = "Newton go brr... initialising physics"
		progress = 0.5
	case .ENEMIES:
		loading_text = "To create balance, we need both evil and good"
		progress = 0.8
	case .DONE:
		loading_text = "We legit don now :)"
		progress = 1.0
	}

	{orui.container(
			orui.id(getId()), // main container
			{
				direction = .TopToBottom,
				width = orui.grow(),
				height = orui.grow(),
				align_main = .Center,
			},
		)

		{orui.container(orui.id(getId()), {height = orui.grow()})} 	// padding container

		{orui.container(
				orui.id(getId()), // loading main container
				{
					width = orui.grow(),
					height = {type = .Percent, value = 0.2, max = 80},
					// background_color = rl.BLACK,
					margin = orui.margin(0, 100),
					align_main = .Center,
					align_content = .Center,
					align_cross = .Center,
					direction = .TopToBottom,
				},
			)

			// loading bar - background (blue)
			{orui.container(
					orui.id(getId()),
					{
						width = {type = .Percent, value = 0.8},
						height = orui.grow(),
						background_color = BLUE,
						border = orui.border(4),
						corner_radius = orui.corner(10),
						border_color = rl.BLACK,
						direction = .LeftToRight,
						gap = -10,
					},
				)

				// loading bar - inside (red)
				{orui.container(
						orui.id(getId()),
						{
							height = orui.grow(),
							width = {type = .Percent, value = progress},
							background_color = RED,
							corner_radius = orui.corner(5),
						},
					)
				}

				// loading bar - end (white)
				{orui.container(
						orui.id(getId()),
						{width = orui.fixed(20), height = orui.grow(), background_color = WHITE},
					)}

			}

			orui.label(
				orui.id(getId()),
				loading_text,
				{
					font_size = 24,
					width = orui.fit(),
					height = orui.grow(),
					color = rl.BLACK,
					align = {.Center, .Center},
				},
			)
		}
	}
}
