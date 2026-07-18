package client

import "core:fmt"
import "core:math/rand"
import rl "vendor:raylib"

@(private = "file")
menu_hover_sounds: [6]rl.Sound

@(private = "file")
menu_click_sounds: [6]rl.Sound

@(private)
loadMenuSounds :: proc() {
	for i in 0 ..< len(menu_hover_sounds) {
		path := fmt.ctprintf("res/audio/menu/menu_hover_%d.wav", i + 1)
		menu_hover_sounds[i] = rl.LoadSound(path)
	}

	for i in 0 ..< len(menu_hover_sounds) {
		path := fmt.ctprintf("res/audio/menu/menu_click_%d.wav", i + 1)
		menu_click_sounds[i] = rl.LoadSound(path)
	}
}

@(private)
unloadMenuSounds :: proc() {
	for sound in menu_hover_sounds {
		rl.UnloadSound(sound)
	}
}

@(private)
playMenuHoveredSound :: proc() {
	i := rand.int_max(len(menu_hover_sounds))
	rl.PlaySound(menu_hover_sounds[i])
}

@(private)
playMenuClickedSound :: proc() {
	i := rand.int_max(len(menu_click_sounds))
	rl.PlaySound(menu_click_sounds[i])
}
