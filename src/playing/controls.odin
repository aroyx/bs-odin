package playing

import "../utils"
import "core:fmt"
import "core:math/linalg"

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

AtkBtn :: struct {
	texture:   rl.Texture,
	cool_down: f32,
}

attack_button_data: AtkBtn = {}

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
is_joystick_held := false

@(private)
joy_dir := [2]f32{0, 0}

joystick_data: rl.Rectangle = {}

@(private = "file")
jbtn_offset: [2]f32 = {}

@(private = "file")
joy_touching := false

@(private = "file")
drawJoystick :: proc() {
	if rl.IsMouseButtonReleased(.LEFT) {
		joy_touching = false
	}

	{orui.container(
			orui.id("joystick"),
			{
				position = {type = .Relative, value = {0, 0}},
				width = orui.fixed(200),
				height = orui.fixed(200),
				corner_radius = orui.corner(100),
				background_color = rl.ColorAlpha(BLUE, 0.6),
				border = orui.border(6),
				border_color = rl.ColorAlpha(BLUE, 0.9),
				margin = {bottom = 80, left = 80},
				custom_event = &joystick_data,
			},
		)

		if orui.active() {
			joy_touching = true
		}

		orui.container(
			orui.id("jbtn"),
			{
				position = {type = .Absolute, value = orui.animate("jbtnst", jbtn_offset, 0.075)},
				placement = {anchor = {0.5, 0.5}, origin = {0.5, 0.5}},
				width = orui.fixed(100),
				height = orui.fixed(100),
				corner_radius = orui.corner(50),
				background_color = rl.ColorAlpha(BLUE, 0.8),
				border = orui.border(10),
				border_color = BLUE,
				capture = .False,
				block = .False,
			},
		)
	}

	if joystick_data.width <= 0 do return

	center: [2]f32 = {
		joystick_data.x + (joystick_data.width / 2),
		joystick_data.y + (joystick_data.height / 2),
	}

	if joy_touching { 	// the joystick was touched using mouse pointer
		pos := rl.GetMousePosition()

		diff := pos - center
		dist := linalg.length(diff)

		dir := linalg.normalize0(diff)
		max_rad := joystick_data.width / 2

		a_dist := min(dist, max_rad)

		jbtn_offset = dir * a_dist

		joy_dir = dir * (a_dist / max_rad)

		return
	} else {
		joy_dir = {0, 0}
		jbtn_offset = {0, 0}
	}

	// for touch screens
	for i in 0 ..< rl.GetTouchPointCount() {
		pos := rl.GetTouchPosition(i)

		if rl.CheckCollisionPointRec(pos, joystick_data) {
			joy_touching = true
		}
	}

	// fmt.println(joystick_data)
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
			border = orui.border(4),
			border_color = RED,
			padding = orui.padding(10),
			margin = {bottom = 80, right = 80},
			custom_event = &attack_button_data,
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
