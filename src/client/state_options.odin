package client

import "thirdparty:orui"

import "../utils"

import rl "vendor:raylib"

options_state: ClientState = {
	on_enter  = on_enter,
	on_render = on_render,
}

@(private = "file")
local_global: GlobalState = {}

@(private = "file")
on_enter :: proc() {
	local_global = global
}

@(private = "file")
MenuState :: enum u8 {
	DISPLAY = 0,
	GAME    = 1,
	MISC    = 2,
}

@(private = "file")
menu := MenuState.DISPLAY

@(private = "file")
cstr: [len(MenuState)]string = {"Display", "Game", "Misc"}

@(private = "file")
active_bar: u8 = 0

@(private = "file")
scroll_pos: rl.Vector2 = {}

@(private = "file")
view_zone: rl.Rectangle = {}

@(private = "file")
a, b, c, d, e := false, false, false, false, false

@(private = "file")
show_save_diag := false

@(private = "file")
on_render :: proc() {
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

	tabBar(cstr[:], active = &active_bar)

	{
		orui.container(
			orui.id("buttons container"),
			{
				width = orui.grow(),
				height = orui.grow(),
				direction = .TopToBottom,
				border = {left = 4, right = 4},
				border_color = rl.BLACK,
				background_color = {131, 197, 190, 255},
			},
		)

		menu = auto_cast active_bar

		switch (menu) {
		case .DISPLAY:
			display_menu_show()
		case .GAME:
			game_menu_show()
		case .MISC:
			misc_menu_show()
		}
	}
	bottom_buttons()
}

@(private = "file")
display_menu_show :: proc() {
	// bounds := bounds^
	// rl.GuiCheckBox(bounds, "Show FPS", &local_global.options.show_fps)
	//
	// bounds.y += bounds.width * 2
	// rl.GuiCheckBox(bounds, "Mobile Navigation", &local_global.options.on_mobile)
	//
	// bounds.y += bounds.width * 2
	// rl.GuiCheckBox(bounds, "This doesn't work :)", &e)
	//
	// bounds.y += bounds.width * 2
	// rl.GuiCheckBox(bounds, "Don't press this :O", &b)
}
@(private = "file")
game_menu_show :: proc() {
	// bounds := bounds^
	// rl.GuiCheckBox(bounds, "Tails", &a)
	//
	// bounds.y += bounds.width * 2
	// rl.GuiCheckBox(bounds, "Head", &b)
	//
	// bounds.y += bounds.width * 2
	// rl.GuiCheckBox(bounds, "Makes a ", &c)
	//
	// bounds.y += bounds.width * 2
	// rl.GuiCheckBox(bounds, "vector together", &d)
	//
	// bounds.y += bounds.width * 2
	// rl.GuiCheckBox(bounds, "These's nothign to look here", &e)
}

@(private = "file")
misc_menu_show :: proc() {
	// bounds := bounds^
	// rl.GuiCheckBox(bounds, "God", &e)
	//
	// bounds.y += bounds.width * 2
	// rl.GuiCheckBox(bounds, "please forbdid a child", &d)
	//
	// bounds.y += bounds.width * 2
	// rl.GuiCheckBox(bounds, "a child who has", &b)
	//
	// bounds.y += bounds.width * 2
	// rl.GuiCheckBox(bounds, "Too much fun", &a)
}

@(private = "file")
ui_checkbox :: proc() {

}

@(private = "file")
tabBar :: proc(names: []string, active: ^u8) {
	orui.container(
		orui.id("tabbar container"),
		{
			direction = .LeftToRight,
			width = orui.grow(),
			height = orui.fixed(70),
			background_color = {34, 84, 122, 255},
			gap = 20,
			padding = orui.padding(10),
			corner_radius = {top_left = 10, top_right = 10},
			border = orui.border(4),
			border_color = rl.BLACK,
		},
	)

	for name, i in names {
		col: rl.Color = (active^ == u8(i)) ? {128, 237, 153, 255} : {129, 195, 215, 255}
		if orui.label(
			orui.id("tab buttosn", i),
			name,
			{
				color = rl.BLACK,
				align = {.Center, .Center},
				font_size = 20,
				width = orui.grow(),
				height = orui.grow(),
				background_color = orui.animate("bg-col", col, 0.3),
				corner_radius = orui.corner(4),
				border_color = rl.BLACK,
				border = getBorder(),
			},
		) {
			active^ = u8(i)
		}
	}
}

bottom_buttons :: proc() {
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

	if bottom_buttons_fn("back button", "\ue06e", "Back", RED) {
		if global != local_global {
			show_save_diag = true
		} else {
			changeState(&main_menu_state)
		}
	}

	if bottom_buttons_fn("save button", "\ue14d", " Save", CYAN) {
		global = local_global
	}
}

@(private = "file")
bottom_buttons_fn :: proc(id: string, icon: string, text: string, col: rl.Color) -> bool {
	return icon_with_text(
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
				font_size = utils.get_font_size(.MEDIUM),
				font = utils.get_font(.MEDIUM),
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

		if diaglogue_button("discard btn", "\ue18e", "Discard", RED) {
			changeState(&main_menu_state)
			show_save_diag = false
		}

		if diaglogue_button("save btn", "\ue14d", "Save", CYAN) {
			global = local_global
			changeState(&main_menu_state)
			show_save_diag = false
		}

		if diaglogue_button("cancel", "\u0078", "Cancel", WHITE) {
			show_save_diag = false
		}
	}
}

diaglogue_button :: proc(
	id: string,
	icon: string,
	text: string,
	col: rl.Color = rl.LIGHTGRAY,
) -> bool {
	return icon_with_text(
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
