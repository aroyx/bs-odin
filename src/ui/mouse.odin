package ui

import "thirdparty:orui"
import rl "vendor:raylib"

MouseState :: enum u8 {
	NORMAL,
	HOVER,
	CLICK,
}

@(private = "file")
hidden := false

@(private = "file")
ms := MouseState.NORMAL

@(private = "file")
ms_img: [MouseState]rl.Texture

@(private)
init_mouse :: proc() {
	rl.HideCursor()
	ms = .NORMAL

	ms_img[.NORMAL] = rl.LoadTexture("res/images/mouse/normal.png")
	ms_img[.CLICK] = rl.LoadTexture("res/images/mouse/click.png")
	ms_img[.HOVER] = rl.LoadTexture("res/images/mouse/hover.png")

	for txt in ms_img {
		rl.SetTextureFilter(txt, .BILINEAR)
	}
}

changeMouseState :: proc(state: MouseState) {
	ms = state
}

hideCursor :: proc() {
	hidden = true
}

showCursor :: proc() {
	hidden = false
}

@(private = "file")
on_smth := false

updateMouseOnInteract :: proc() {
	if orui.active() {
		ms = .CLICK
		on_smth = true
	} else if orui.hovered() {
		ms = .HOVER
		on_smth = true
	}
}

@(private)
renderMouse :: proc() {
	if hidden {
		w, h := rl.GetScreenWidth(), rl.GetScreenHeight()
		rl.SetMousePosition(w / 2, h / 2)
	}

	if !on_smth {
		ms = .NORMAL
	}
	pos := rl.GetMousePosition()
	rl.DrawTextureEx(ms_img[ms], pos, 0.0, 0.5, rl.WHITE)
	on_smth = false
}
