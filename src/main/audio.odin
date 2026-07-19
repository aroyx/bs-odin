package client

import "core:fmt"
import "core:math/rand"

import "../audio"

import rl "vendor:raylib"

@(private = "file")
menu_hover_sounds: [6]audio.Sound

@(private = "file")
menu_click_sounds: [6]audio.Sound

bgm: rl.Music

@(private)
loadMenuSounds :: proc() {
	for i in 0 ..< len(menu_hover_sounds) {
		path := fmt.ctprintf("res/audio/menu/menu_hover_%d.wav", i + 1)
		menu_hover_sounds[i] = audio.loadSound(path)
	}

	for i in 0 ..< len(menu_hover_sounds) {
		path := fmt.ctprintf("res/audio/menu/menu_click_%d.wav", i + 1)
		menu_click_sounds[i] = audio.loadSound(path)
	}

    bgm = rl.LoadMusicStream("res/audio/bgm/country.mp3")
    rl.PlayMusicStream(bgm)
}

@(private)
unloadMenuSounds :: proc() {
	for sound in menu_hover_sounds {
		audio.unloadSound(sound)
	}
    rl.UnloadMusicStream(bgm)
}

@(private)
playMenuHoveredSound :: proc() {
	i := rand.int_max(len(menu_hover_sounds))
	audio.playSound(&menu_hover_sounds[i])
}

@(private)
playMenuClickedSound :: proc() {
	i := rand.int_max(len(menu_click_sounds))
	audio.playSound(&menu_click_sounds[i])
}
