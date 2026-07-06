package client

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
cstr: [len(MenuState)]cstring = {"Display", "Game", "Misc"}

@(private = "file")
active_bar: u8 = 0

@(private = "file")
scroll_pos: rl.Vector2 = {}

@(private = "file")
view_zone: rl.Rectangle = {}

a, b, c, d, e := false, false, false, false, false

@(private = "file")
show_save_diag := false

@(private = "file")
on_render :: proc() {
	rl.ClearBackground(rl.SKYBLUE)

	if show_save_diag {
		showSaveDiagloge()
		return
	}

	win_w, win_h := f32(rl.GetRenderWidth()), f32(rl.GetRenderHeight())

	// rl.GuiTabBar({100, 100, 400, 50}, &cstr[0], 4, &i) // doesn't work as good, Imma make my own

	tab_bounds: rl.Rectangle = {
		x      = win_w * 0.2,
		y      = win_h * 0.15,
		width  = win_w * 0.6,
		height = 70,
	}

	rl.DrawRectangleRec(tab_bounds, {41, 44, 51, 255})
	tabBar(
		tab_bounds,
		&cstr[0],
		count = len(MenuState),
		active = &active_bar,
		gap = 20,
		vpadding = 10,
		hpadding = 10,
	)
	menu = auto_cast active_bar

	panel_bounds: rl.Rectangle = {
		x      = win_w * 0.2,
		y      = tab_bounds.y + tab_bounds.height,
		width  = win_w * 0.6,
		height = min(win_h * 0.7, win_h - tab_bounds.y - tab_bounds.height - 20) - 70,
	}

	panel_content: rl.Rectangle = {
		x      = 0,
		y      = 0,
		width  = panel_bounds.width - 20,
		height = panel_bounds.height * 3,
	}

	rl.GuiScrollPanel(panel_bounds, "", panel_content, &scroll_pos, &view_zone)

	rl.BeginScissorMode(
		i32(view_zone.x),
		i32(view_zone.y),
		i32(view_zone.width),
		i32(view_zone.height),
	)

	bounds := rl.Rectangle {
		x      = panel_bounds.x + scroll_pos.x + 20,
		y      = panel_bounds.y + scroll_pos.y + 30,
		width  = 20,
		height = 20,
	}

	switch (menu) {
	case .DISPLAY:
		display_menu_show(&bounds)
	case .GAME:
		game_menu_show(&bounds)
	case .MISC:
		misc_menu_show(&bounds)
	}

	rl.EndScissorMode()

	button_bounds: rl.Rectangle = {
		x      = panel_bounds.x,
		y      = panel_bounds.y + panel_bounds.height,
		width  = panel_bounds.width * 0.5,
		height = 40,
	}

	if rl.GuiButton(button_bounds, "#118# Back") {
		if global != local_global {
			show_save_diag = true
		} else {
			changeState(&main_menu_state)
		}
	}

	button_bounds.x += button_bounds.width
	if rl.GuiButton(button_bounds, "#2# Save") {
		global = local_global
	}
}

@(private = "file")
display_menu_show :: proc(bounds: ^rl.Rectangle) {
	bounds := bounds^
	rl.GuiCheckBox(bounds, "Show FPS", &local_global.options.show_fps)

	bounds.y += bounds.width * 2
	rl.GuiCheckBox(bounds, "Mobile Navigation", &local_global.options.on_mobile)

	bounds.y += bounds.width * 2
	rl.GuiCheckBox(bounds, "This doesn't work :)", &e)

	bounds.y += bounds.width * 2
	rl.GuiCheckBox(bounds, "Don't press this :O", &b)
}
@(private = "file")
game_menu_show :: proc(bounds: ^rl.Rectangle) {
	bounds := bounds^
	rl.GuiCheckBox(bounds, "Tails", &a)

	bounds.y += bounds.width * 2
	rl.GuiCheckBox(bounds, "Head", &b)

	bounds.y += bounds.width * 2
	rl.GuiCheckBox(bounds, "Makes a ", &c)

	bounds.y += bounds.width * 2
	rl.GuiCheckBox(bounds, "vector together", &d)

	bounds.y += bounds.width * 2
	rl.GuiCheckBox(bounds, "These's nothign to look here", &e)
}

@(private = "file")
misc_menu_show :: proc(bounds: ^rl.Rectangle) {
	bounds := bounds^
	rl.GuiCheckBox(bounds, "God", &e)

	bounds.y += bounds.width * 2
	rl.GuiCheckBox(bounds, "please forbdid a child", &d)

	bounds.y += bounds.width * 2
	rl.GuiCheckBox(bounds, "a child who has", &b)

	bounds.y += bounds.width * 2
	rl.GuiCheckBox(bounds, "Too much fun", &a)

}

@(private = "file")
tabBar :: proc(
	bounds: rl.Rectangle,
	names: [^]cstring,
	count: i32,
	active: ^u8,
	vpadding: f32 = 0,
	hpadding: f32 = 0,
	gap: f32 = 0,
) {
	count := f32(count)

	width_cell := (bounds.width - (gap * (count - 1)) - (hpadding * 2)) / count

	button_bounds := rl.Rectangle {
		x      = bounds.x + hpadding,
		y      = bounds.y + vpadding,
		width  = width_cell,
		height = bounds.height - vpadding * 2,
	}

	for i in 0 ..< i32(count) {
		if i == i32(active^) {
			rl.GuiSetState(auto_cast rl.GuiState.STATE_PRESSED)
		} else {
			rl.GuiSetState(auto_cast rl.GuiState.STATE_NORMAL)
		}
		if rl.GuiButton(button_bounds, names[i]) {
			active^ = auto_cast i
		}
		button_bounds.x += width_cell + gap
	}
	rl.GuiSetState(auto_cast rl.GuiState.STATE_NORMAL)
}

showSaveDiagloge :: proc() {
	win_w, win_h := f32(rl.GetRenderWidth()), f32(rl.GetRenderHeight())
	bounds: rl.Rectangle = {
		x      = win_w * 0.2,
		width  = win_w * 0.6,
		y      = win_h * 0.3,
		height = win_h * 0.4,
	}

	res := rl.GuiMessageBox(
		bounds,
		"Unsaved Changes",
		"You have unsaved changes,\ndo you want to discard them?",
		"#143# Discard;#2# Save;#113# Cancel",
	)

	switch (res) {
	case 1:
		// discard
		changeState(&main_menu_state)
		show_save_diag = false
	case 2:
		// save
		global = local_global
		changeState(&main_menu_state)
		show_save_diag = false
	case 3, 0:
		// cancel/close window
		show_save_diag = false
	}
}
