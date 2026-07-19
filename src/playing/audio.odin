package playing

import "core:math/rand"

import "../audio"

SoundType :: enum u8 {
	PLAYER_IDLE,
	PLAYER_WALK,
	PLAYER_RUN,
	PLAYER_JUMP,
	PLAYER_ATTACK,
	PLAYER_HURT,
	PLAYER_DEAD,
	PLAYER_SHOCKED,
	ENEMY_ROAM,
	ENEMY_CHASE,
	ENEMY_ATTACK,
	ENEMY_HURT,
	ENEMY_DEAD,
}

@(private = "file") // each soundtype can have multiple sound (variations)
sounds: [SoundType][dynamic]audio.Sound

loadSounds :: proc() {
	for s in SoundType {
		sounds[s] = make([dynamic]audio.Sound)
	}

	loadSound(.PLAYER_ATTACK, "res/audio/character/player/attack2.wav")
	loadSound(.PLAYER_DEAD, "res/audio/character/player/death2.wav")
	loadSound(.PLAYER_SHOCKED, "res/audio/character/player/gasp2.wav")
	loadSound(.PLAYER_HURT, "res/audio/character/player/hurt2.wav")
	loadSound(.PLAYER_IDLE, "res/audio/character/player/idle2.wav")
	loadSound(.ENEMY_ROAM, "res/audio/character/enemy/enemy_idle.wav")
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
	index := rand.int_max(len(sounds[type]))

	sound := &sounds[type][index]
	audio.playSound(sound)
}
