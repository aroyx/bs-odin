package playing

import "core:math/rand"

import "../audio"

SoundType :: enum u8 {
	ATTACK,
	ATTACK_MISS,
	CUT_FOLIAGE,
	GASP,
	HURT,
	DYING,
}

@(private = "file") // each soundtype can have multiple sound (variations)
sounds: [SoundType][dynamic]audio.Sound

loadSounds :: proc() {
	for s in SoundType {
		sounds[s] = make([dynamic]audio.Sound)
	}

	loadSound(.ATTACK, "res/audio/character/punch.wav")
	loadSound(.ATTACK, "res/audio/character/punch_2.wav")
	loadSound(.ATTACK, "res/audio/character/punch_3.wav")
	loadSound(.ATTACK, "res/audio/character/slap.wav")

	loadSound(.ATTACK_MISS, "res/audio/character/swoosh.mp3")
	loadSound(.ATTACK_MISS, "res/audio/character/swoosh2.mp3")
	loadSound(.ATTACK_MISS, "res/audio/character/swoosh3.mp3")
	loadSound(.ATTACK_MISS, "res/audio/character/swoosh4.mp3")
	loadSound(.ATTACK_MISS, "res/audio/character/swoosh5.mp3")

	loadSound(.CUT_FOLIAGE, "res/audio/character/swipe.wav")
	loadSound(.CUT_FOLIAGE, "res/audio/character/kick.wav") // trust me with this one

	loadSound(.GASP, "res/audio/character/gasp1.mp3")
	loadSound(.GASP, "res/audio/character/gasp2.mp3")
	loadSound(.GASP, "res/audio/character/gasp3.mp3")

	loadSound(.HURT, "res/audio/character/hurt1.mp3")
	loadSound(.HURT, "res/audio/character/hurt2.mp3")
	loadSound(.HURT, "res/audio/character/hurt3.mp3")
	loadSound(.HURT, "res/audio/character/hurt4.mp3")
	loadSound(.HURT, "res/audio/character/hurt5.mp3")
	loadSound(.HURT, "res/audio/character/hurt6.mp3")
	loadSound(.HURT, "res/audio/character/hurt7.mp3")
	loadSound(.HURT, "res/audio/character/hurt8.mp3")
	loadSound(.HURT, "res/audio/character/hurt9.mp3")
	loadSound(.HURT, "res/audio/character/hurt10.mp3")
	loadSound(.HURT, "res/audio/character/hurt11.mp3")
	loadSound(.HURT, "res/audio/character/hurt12.mp3")
	loadSound(.HURT, "res/audio/character/hurt13.mp3")
	loadSound(.HURT, "res/audio/character/hurt14.mp3")
	loadSound(.HURT, "res/audio/character/hurt15.mp3")

	loadSound(.DYING, "res/audio/character/dying1.mp3")
	loadSound(.DYING, "res/audio/character/dying2.mp3")
	loadSound(.DYING, "res/audio/character/dying3.mp3")
	loadSound(.DYING, "res/audio/character/dying4.mp3")
}

@(private)
loadSound :: proc(type: SoundType, path: cstring) {
	sound := audio.loadSound(path)
	append(&sounds[type], sound)
}

unloadSounds :: proc() {
	for s in SoundType {
		for sound in sounds[s] {
			audio.unloadSound(sound)
		}
	}

	for s in SoundType {
		delete(sounds[s])
	}
}

@(private)
playSound :: proc(type: SoundType) {
	if len(sounds[type]) <= 0 do return

	index := rand.int_max(len(sounds[type]))

	sound := &sounds[type][index]
	audio.playSound(sound)
}
