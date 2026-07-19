package audio

import rl "vendor:raylib"

TOTAL_ALIASES :: 4
Sound :: struct {
	aliases: [TOTAL_ALIASES]rl.Sound,
	index:   int,
}

loadSound :: proc(path: cstring) -> Sound {
	sound: Sound

	sound.aliases[0] = rl.LoadSound(path)

	for i in 1 ..< TOTAL_ALIASES {
		sound.aliases[i] = rl.LoadSoundAlias(sound.aliases[0])
	}

	sound.index = 0

	return sound
}

unloadSound :: proc(sound: Sound) {
	for i in 1 ..< TOTAL_ALIASES {
		rl.UnloadSoundAlias(sound.aliases[i])
	}

	rl.UnloadSound(sound.aliases[0])
}

playSound :: proc(sound: ^Sound) {
	rl.PlaySound(sound.aliases[sound.index])
	sound.index = (sound.index + 1) % TOTAL_ALIASES
}
