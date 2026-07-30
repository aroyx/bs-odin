package playing

import anim "../animations"
import "../utils"

import "thirdparty:orui"
import "thirdparty:tracy"
import rl "vendor:raylib"

BLUE :: rl.Color{0, 129, 167, 255}
RED :: rl.Color{240, 113, 103, 255}
CYAN :: rl.Color{0, 210, 210, 255}

@(private)
ui_attack := false
@(private)
ui_run := false

@(private)
drawControls :: proc() -> bool {
	tracy.ZoneN("Orui Playing")

	// main controls
	orui.container(
		orui.id("ms"),
		{width = orui.grow(), height = orui.grow(), direction = .TopToBottom},
	)

	// top part - exit button
	{orui.container(orui.id("tp"), {height = orui.grow(), width = orui.grow()})
		{orui.container(orui.id("tmp"), {width = orui.grow()})}

		if orui.label(
			orui.id("xicn"),
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
			return true
		}
	}

	// bottom part - control buttons
	{
		orui.container(
			orui.id("bp"),
			{direction = .LeftToRight, width = orui.grow(), height = orui.fit()},
		)

		// bottom left
		{orui.container(orui.id("bl"), {width = orui.grow(), height = orui.fit()})
			if utils.global.options.on_mobile { 	// draw joystick
				drawJoystick()
			}
		}

		// bottom right
		{orui.container(
				orui.id("br"),
				{height = orui.fit(), width = orui.fit(), align_cross = .Center},
			)
			drawAttackButton()
		}

	}

	return false
}

@(private = "file")
drawJoystick :: proc() {

}

@(private = "file")
drawAttackButton :: proc() {
	orui.container(
		orui.id("atk_btn"),
		{
			width = orui.fixed(100),
			height = orui.fixed(100),
			corner_radius = orui.corner(50),
			background_color = orui.animate(
				"bg_atk",
				ui_attack ? rl.ColorAlpha(RED, 0.95) : rl.ColorAlpha(RED, 0.7),
			),
            border= orui.border(4),
            border_color = RED,
			padding = orui.padding(10),
			margin = {bottom = 80, right = 80},
		},
	)

	img := new(rl.Texture, allocator = context.temp_allocator)
	img^ = anim.getPartTex(player_skin.type[.WEAPON], player_skin.tier[.WEAPON], .WEAPON)

	orui.image(
		orui.id("atk_img"),
		img,
		{
			width = orui.grow(),
			height = orui.grow(),
			texture_fit = .Contain,
			align = {.Center, .Center},
		},
	)

	ui_attack = orui.clicked() || orui.active()
}

@(private = "file")
getBorder :: proc(id: string = "border_width") -> orui.Edges {
	return orui.animate(
		id, // border can be set in one elment once so shouldn't need different ids
		orui.active() ? orui.border(0) : (orui.hovered() ? orui.border(2) : orui.border(4)),
	)
}
