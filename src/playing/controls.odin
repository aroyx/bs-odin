package playing

import "../audio"
import "../ui"
import "../utils"

import "core:math/linalg"

import "thirdparty:orui"
import "thirdparty:tracy"
import rl "vendor:raylib"

YELLOW :: rl.Color{254, 217, 183, 255}
WHITE :: rl.Color{253, 252, 220, 255}
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
	rect:      rl.Rectangle,
}

attack_button_data: AtkBtn = {}

joystick_data: rl.Rectangle = {}

@(private)
drawControls :: proc() {
	tracy.ZoneN("Orui Playing")

	// main controls
	orui.container(
		orui.id("ms"),
		{width = orui.grow(), height = orui.grow(), direction = .TopToBottom},
	)

	// top part - pause button
	{orui.container(orui.id("tp"), {height = orui.grow(), width = orui.grow()})
		{orui.container(orui.id("tmp"), {width = orui.grow()})}

		if orui.label(
			orui.id("pisn"),
			"\ue12e",
			{
				width = orui.fixed(80),
				height = orui.fixed(80),
				align = {.Center, .Center},
				font = utils.getIconFont(),
				font_size = 40,
				color = rl.BLACK,
				background_color = CYAN,
				border = getBorder(),
				border_color = rl.BLACK,
				corner_radius = orui.corner(10),
				margin = orui.margin(10),
			},
		) {
			pause_menu = true
			audio.playMenuClickedSound()
		}

		ui.updateMouseOnInteract()
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
}

@(private = "file")
is_joystick_held := false

@(private)
joy_dir := [2]f32{0, 0}

@(private = "file")
jbtn_offset: [2]f32 = {}

@(private = "file")
joy_touching := false

@(private = "file")
drawJoystick :: proc() {
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

		ui.updateMouseOnInteract()
	}

	if joystick_data.width <= 0 do return

	center: [2]f32 = {
		joystick_data.x + (joystick_data.width / 2),
		joystick_data.y + (joystick_data.height / 2),
	}

	touch_pos := center
	touching := false

	for i in 0 ..< rl.GetTouchPointCount() {
		pos := rl.GetTouchPosition(i)

		is_near := joy_touching && linalg.distance(pos, center) < joystick_data.width * 2

		if rl.CheckCollisionPointRec(pos, joystick_data) || is_near {
			touch_pos = pos
			touching = true
			break
		}
	}

	if !touching && rl.IsMouseButtonDown(.LEFT) {
		pos := rl.GetMousePosition()
		is_near := joy_touching && linalg.distance(pos, center) < joystick_data.width * 2
		if rl.CheckCollisionPointRec(pos, joystick_data) || is_near {
			touch_pos = pos
			touching = true
		}
	}

	if touching {
		diff := touch_pos - center
		dist := linalg.length(diff)

		dir := linalg.normalize0(diff)
		max_rad := joystick_data.width / 2

		a_dist := min(dist, max_rad)

		jbtn_offset = dir * a_dist

		joy_dir = dir * (a_dist / max_rad)
	} else {
		joy_dir = {0, 0}
		jbtn_offset = {0, 0}
	}

	joy_touching = touching
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

	ui.updateMouseOnInteract()
	ui_attack = false

	tcnt := rl.GetTouchPointCount()
	if tcnt > 0 {
		for i in 0 ..< tcnt {
			pos := rl.GetTouchPosition(i)
			if rl.CheckCollisionPointRec(pos, attack_button_data.rect) {
				ui_attack = true
				break
			}
		}
	} else {
		pos := rl.GetMousePosition()
		if rl.IsMouseButtonDown(.LEFT) && rl.CheckCollisionPointRec(pos, attack_button_data.rect) {
			ui_attack = true
		}
	}
}

@(private)
call_back :: proc(render_cmd: orui.RenderCommand) -> bool {
	data := render_cmd.data.(orui.RenderCommandDataCustom)

	if data.custom_event == &attack_button_data {
		attack_button_data.rect = data.rectangle

		if attack_button_data.texture.id == 0 do return true

		tex := attack_button_data.texture

		rekt := data.rectangle
		center := [2]f32{rekt.x + (rekt.width / 2), rekt.y + (rekt.height / 2)}

		src: rl.Rectangle = {
			x      = 0,
			y      = 0,
			width  = f32(tex.width),
			height = f32(tex.height),
		}

		scale := (rekt.width - 30) / f32(max(tex.width, tex.height))
		dst := rl.Rectangle {
			x      = center.x,
			y      = center.y,
			width  = src.width * scale,
			height = src.height * scale,
		}

		origin := [2]f32{dst.width / 2, dst.height / 2}

		rl.DrawTexturePro(tex, src, dst, origin, -45, rl.WHITE)

		cool_down := attack_button_data.cool_down
		if cool_down <= 0 do return true

		s_angle: f32 = -90
		e_angle: f32 = cool_down * 360 + s_angle

		rl.DrawRing(center, 0, rekt.width / 2, s_angle, e_angle, 32, rl.ColorAlpha(rl.BLACK, 0.5))

		return true

	} else if data.custom_event == &joystick_data {
		joystick_data = data.rectangle
		return false
	}

	return false
}

@(private = "file")
getBorder :: proc(id: string = "border_width") -> orui.Edges {
	return orui.animate(
		id, // border can be set in one elment once so shouldn't need different ids
		orui.active() ? orui.border(0) : (orui.hovered() ? orui.border(2) : orui.border(4)),
	)
}
