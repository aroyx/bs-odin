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
	ROAR,
    FOOTSTEP,
    BREATHE,
    HEARTBEAT,
    EXPLOSION,
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

	loadSound(.ATTACK_MISS, "res/audio/character/swoosh.wav")
	loadSound(.ATTACK_MISS, "res/audio/character/swoosh2.wav")
	loadSound(.ATTACK_MISS, "res/audio/character/swoosh3.wav")
	loadSound(.ATTACK_MISS, "res/audio/character/swoosh4.wav")
	loadSound(.ATTACK_MISS, "res/audio/character/swoosh5.wav")

	loadSound(.CUT_FOLIAGE, "res/audio/character/swipe.wav")
	loadSound(.CUT_FOLIAGE, "res/audio/character/kick.wav") // trust me with this one

	loadSound(.GASP, "res/audio/character/gasp1.wav")
	loadSound(.GASP, "res/audio/character/gasp2.wav")
	loadSound(.GASP, "res/audio/character/gasp3.wav")

	loadSound(.HURT, "res/audio/character/hurt1.wav")
	loadSound(.HURT, "res/audio/character/hurt2.wav")
	loadSound(.HURT, "res/audio/character/hurt3.wav")
	loadSound(.HURT, "res/audio/character/hurt4.wav")
	loadSound(.HURT, "res/audio/character/hurt5.wav")
	loadSound(.HURT, "res/audio/character/hurt6.wav")
	loadSound(.HURT, "res/audio/character/hurt7.wav")
	loadSound(.HURT, "res/audio/character/hurt8.wav")
	loadSound(.HURT, "res/audio/character/hurt9.wav")
	loadSound(.HURT, "res/audio/character/hurt10.wav")
	loadSound(.HURT, "res/audio/character/hurt11.wav")
	loadSound(.HURT, "res/audio/character/hurt12.wav")
	loadSound(.HURT, "res/audio/character/hurt13.wav")
	loadSound(.HURT, "res/audio/character/hurt14.wav")
	loadSound(.HURT, "res/audio/character/hurt15.wav")

	loadSound(.DYING, "res/audio/character/dying1.wav")
	loadSound(.DYING, "res/audio/character/dying2.wav")
	loadSound(.DYING, "res/audio/character/dying3.wav")
	loadSound(.DYING, "res/audio/character/dying4.wav")

	loadSound(.ROAR, "res/audio/character/roar1.wav")
	loadSound(.ROAR, "res/audio/character/roar2.wav")
	loadSound(.ROAR, "res/audio/character/roar3.wav")
	loadSound(.ROAR, "res/audio/character/roar4.wav")

	loadSound(.FOOTSTEP, "res/audio/character/footstep1.wav")
	loadSound(.FOOTSTEP, "res/audio/character/footstep2.wav")
	loadSound(.FOOTSTEP, "res/audio/character/footstep3.wav")

	loadSound(.BREATHE, "res/audio/character/breathe.wav")

	loadSound(.HEARTBEAT, "res/audio/character/heartbeat.wav")

	loadSound(.EXPLOSION, "res/audio/misc/explosion.wav")
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
