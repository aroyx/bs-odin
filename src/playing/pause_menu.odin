package playing

import "../audio"
import "../ui"
import "../utils"

import "thirdparty:orui"
import rl "vendor:raylib"

@(private)
local_global: utils.GlobalState = {}

@(private = "file")
show_save_diag := false

@(private)
showPauseMenu :: proc() {
	rl.ClearBackground(rl.SKYBLUE)

	orui.container(
		orui.id("main container"), //
		{
			direction = .TopToBottom,
			align_main = .Center,
			align_cross = .Center,
			height = orui.grow(),
			width = orui.grow(),
		},
	)

	if show_save_diag {
		showSaveDiagloge()
		return
	}

	orui.container(
		orui.id("menu container"), //
		{
			direction  = .TopToBottom,
			align_main = .Center, //
			height     = orui.percent(0.75),
			width      = orui.percent(0.85),
		},
	)

	{
		orui.container(
			orui.id("checkboxes container"),
			{
				width = orui.grow(),
				height = orui.grow(),
				direction = .TopToBottom,
				border = {top = 4, left = 4, right = 4},
				border_color = rl.BLACK,
				background_color = CYAN,
				gap = 10,
				padding = orui.padding(20, 20),
				scroll = orui.scroll(.Vertical),
				clip = {type = .Intersect, rectangle = {}},
			},
		)

		displayMenuShow()
	}

	bottomButtons()
}

@(private = "file")
displayMenuShow :: proc() {
	uiCheckbox("l+1", "Show FPS", &local_global.options.show_fps)
	uiCheckbox("c+1", "Mobile Navigation", &local_global.options.on_mobile)
}

@(private = "file")
uiCheckbox :: proc(id: string, text: string, var: ^bool) {
	orui.container(
		orui.id(id),
		{
			direction = .LeftToRight,
			gap = 10,
			width = orui.grow(),
			height = orui.fixed(50),
			background_color = orui.transition(
				"hover",
				orui.hovered(),
				rl.Color{193, 211, 254, 255},
				rl.Color{171, 196, 255, 255},
			),
			padding = orui.padding(20, 00),
			corner_radius = orui.corner(10),
			align_content = .Center,
			align_cross = .Center,
		},
	)

	ui.updateMouseOnInteract()

	if orui.clicked(id) {
		var^ = !var^
		audio.playMenuClickedSound()
	}

	{
		orui.container(
			orui.id(id, 49),
			{
				width = orui.fixed(32),
				height = orui.fixed(32),
				border = orui.border(3),
				corner_radius = orui.corner(16),
				border_color = rl.BLACK,
				block = .False,
				align_content = .Center,
				align_cross = .Center,
				background_color = orui.animate("width_anim", var^ ? CYAN : rl.WHITE),
			},
		)
	}

	orui.label(
		orui.id(id, 2),
		text,
		{
			width = orui.grow(),
			height = orui.grow(),
			color = rl.BLACK,
			font_size = 20,
			block = .False,
			align = {.End, .Center},
		},
	)
}

bottomButtons :: proc() {
	orui.container(
		orui.id("bottom buttons"),
		{
			width = orui.grow(),
			height = orui.fit(),
			background_color = BLUE,
			direction = .LeftToRight,
			gap = 20,
			corner_radius = {bottom_left = 10, bottom_right = 10},
			border = orui.border(4),
			border_color = rl.BLACK,
			padding = orui.padding(10),
		},
	)

	if bottomButtonsFn("save button", "\ue14d", " Save", YELLOW) {
		utils.global = local_global
		audio.playMenuClickedSound()
	}

	if bottomButtonsFn("resume", "\ue13c", " Resume", CYAN) {
		if utils.global != local_global {
			show_save_diag = true
		} else {
			pause_menu = false
		}

		audio.playMenuClickedSound()
	}

	if bottomButtonsFn("quit button", "\u0078", " Quit", RED) {
		utils.global = local_global
		playing_end = true
		audio.playMenuClickedSound()
	}
}

@(private = "file")
bottomButtonsFn :: proc(id: string, icon: string, text: string, col: rl.Color) -> bool {
	return iconWithText(
		id,
		icon,
		text,
		{
			width = orui.grow(),
			height = orui.grow(),
			font_size = 20,
			color = rl.BLACK,
			background_color = col,
			align = {.Center, .Center},
			padding = orui.padding(5),
			corner_radius = orui.corner(10),
			border = orui.border(4),
			border_color = rl.BLACK,
		},
	)
}

@(private)
iconWithText :: proc(id: string, icon: string, text: string, config: orui.ElementConfig) -> bool {
	ctn_config := config
	ctn_config.direction = .LeftToRight
	ctn_config.align_content = .Center
	ctn_config.align_main = .Center
	ctn_config.gap = 10

	orui.container(orui.id(id, 1), ctn_config)

	ui.updateMouseOnInteract()

	orui.label(
		orui.id(id, 2),
		icon,
		{
			width = orui.fixed(config.font_size),
			height = orui.grow(),
			font = utils.getIconFont(),
			font_size = config.font_size + 4,
			color = rl.BLACK,
			align = {.Center, .Center},
			block = .False,
		},
	)

	text_config := config
	text_config.background_color = rl.BLANK
	text_config.width = orui.fit()
	text_config.border_color = rl.BLACK
	text_config.border = {}
	text_config.corner_radius = {}
	text_config.block = .False

	orui.label(orui.id(id, 3), text, text_config)

	return orui.clicked(orui.to_id(id, 1))
}

@(private = "file")
showSaveDiagloge :: proc() {
	orui.container(
		orui.id("save dialogue"),
		{
			width = {type = .Percent, value = 0.6, min = 300},
			height = {type = .Percent, value = 0.5, min = 300},
			direction = .TopToBottom,
			border_color = rl.BLACK,
			border = orui.border(4),
			corner_radius = orui.corner(10),
			background_color = BLUE,
		},
	)

	br: f32 = 10
	{
		orui.container(
			orui.id("upper texts"),
			{
				width = orui.grow(),
				height = orui.grow(),
				direction = .TopToBottom,
				align_content = .Center,
				align_main = .Center,
				gap = 10,
				border = {bottom = 4},
				border_color = rl.BLACK,
			},
		)

		orui.label(
			orui.id("titletext"),
			"Unsaved Changes",
			{
				width = orui.grow(),
				font_size = utils.getFontSize(.MEDIUM),
				font = utils.getFont(.MEDIUM),
				color = rl.BLACK,
				align = {.Center, .Center},
			},
		)

		orui.label(
			orui.id("messageu:text"),
			"You have unsaved changes,\ndo you want to discard them?",
			{font_size = 18, width = orui.grow(), color = rl.BLACK, align = {.Center, .Center}},
		)
	}

	{
		orui.container(
			orui.id("Lower buttons"),
			{width = orui.grow(), height = orui.fixed(60), gap = 10, padding = orui.padding(5)},
		)

		if diaglogueButton("discard btn", "\ue18e", "Discard", RED) {
			pause_menu = false
			show_save_diag = false
			audio.playMenuClickedSound()
		}

		if diaglogueButton("save btn", "\ue14d", "Save", CYAN) {
			utils.global = local_global
			pause_menu = false
			show_save_diag = false
			audio.playMenuClickedSound()
		}

		if diaglogueButton("cancel", "\u0078", "Cancel", WHITE) {
			show_save_diag = false
			audio.playMenuClickedSound()
		}
	}
}

diaglogueButton :: proc(
	id: string,
	icon: string,
	text: string,
	col: rl.Color = rl.LIGHTGRAY,
) -> bool {
	return iconWithText(
		id,
		icon,
		text,
		{
			width = orui.grow(),
			height = orui.grow(),
			font_size = 20,
			align = {.Center, .Center},
			corner_radius = orui.corner(10),
			color = rl.BLACK,
			background_color = col,
			border = orui.border(4),
			border_color = rl.BLACK,
		},
	)
}
