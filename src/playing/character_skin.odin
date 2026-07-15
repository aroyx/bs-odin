package playing

import anim "../animations"

CharacterPartGroup :: enum u8 {
	HEAD,
	BODY,
	FACE,
	RIGHT_HAND,
	LEFT_HAND,
	RIGHT_LEG,
	LEFT_LEG,
	WEAPON,
}

initPlayer :: proc() {
	randomSkin(&player_skin)
}

setPartType :: proc(group: CharacterPartGroup, type: anim.CharacterType) {
	switch group {
	case .BODY:
		player_skin.type[.BODY] = type
	case .HEAD:
		player_skin.type[.HEAD] = type
	case .FACE:
		player_skin.type[.FACE_IDLE] = type
		player_skin.type[.FACE_BLINK] = type
		player_skin.type[.FACE_HURT] = type
	case .RIGHT_HAND:
		player_skin.type[.RIGHT_ARM] = type
		player_skin.type[.RIGHT_HAND] = type
	case .RIGHT_LEG:
		player_skin.type[.RIGHT_LEG] = type
	case .LEFT_HAND:
		player_skin.type[.LEFT_ARM] = type
		player_skin.type[.LEFT_HAND] = type
	case .LEFT_LEG:
		player_skin.type[.LEFT_LEG] = type
	case .WEAPON:
		player_skin.type[.WEAPON] = type
		player_skin.type[.SLASH_EFFECT] = type
	}
}

setPartTier :: proc(group: CharacterPartGroup, tier: anim.CharacterTier) {
	switch group {
	case .BODY:
		player_skin.tier[.BODY] = tier
	case .HEAD:
		player_skin.tier[.HEAD] = tier
	case .FACE:
		player_skin.tier[.FACE_IDLE] = tier
		player_skin.tier[.FACE_BLINK] = tier
		player_skin.tier[.FACE_HURT] = tier
	case .RIGHT_HAND:
		player_skin.tier[.RIGHT_ARM] = tier
		player_skin.tier[.RIGHT_HAND] = tier
	case .RIGHT_LEG:
		player_skin.tier[.RIGHT_LEG] = tier
	case .LEFT_HAND:
		player_skin.tier[.LEFT_ARM] = tier
		player_skin.tier[.LEFT_HAND] = tier
	case .LEFT_LEG:
		player_skin.tier[.LEFT_LEG] = tier
	case .WEAPON:
		player_skin.tier[.WEAPON] = tier
		player_skin.tier[.SLASH_EFFECT] = tier
	}
}

getPartFromGroup :: proc(group: CharacterPartGroup) -> anim.BodyPart {
	switch group {
	case .BODY:
		return .BODY
	case .HEAD:
		return .HEAD
	case .FACE:
		return .FACE_IDLE
	// return .FACE_BLINK
	// return .FACE_HURT
	case .RIGHT_HAND:
		return .RIGHT_ARM
	// return .RIGHT_HAND
	case .RIGHT_LEG:
		return .RIGHT_LEG
	case .LEFT_HAND:
		return .LEFT_ARM
	// return .LEFT_HAND
	case .LEFT_LEG:
		return .LEFT_LEG
	case .WEAPON:
		return .WEAPON
	}

	return .FACE_BLINK
}
