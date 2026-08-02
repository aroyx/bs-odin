package playing

import anim "../animations"

CharacterPartGroup :: enum u8 {
	HEAD,
	BODY,
	FACE,
	HAND,
	LEG,
	WEAPON,
}

playerSkinRandomize :: proc() {
	randomSkin(&player_skin)
}

setPartType :: proc {
	setPartTypePlayer,
	setPartTypeSkin,
}

setPartTier :: proc {
	setPartTierPlayer,
	setPartTierSkin,
}

setPartTypePlayer :: proc(group: CharacterPartGroup, type: anim.CharacterType) {
	switch group {
	case .BODY:
		player_skin.type[.BODY] = type
	case .HEAD:
		player_skin.type[.HEAD] = type
	case .FACE:
		player_skin.type[.FACE_IDLE] = type
		player_skin.type[.FACE_BLINK] = type
		player_skin.type[.FACE_HURT] = type
	case .HAND:
		player_skin.type[.RIGHT_ARM] = type
		player_skin.type[.RIGHT_HAND] = type
		player_skin.type[.LEFT_ARM] = type
		player_skin.type[.LEFT_HAND] = type
	case .LEG:
		player_skin.type[.RIGHT_LEG] = type
		player_skin.type[.LEFT_LEG] = type
	case .WEAPON:
		player_skin.type[.WEAPON] = type
		player_skin.type[.SLASH_EFFECT] = type
	}
}

setPartTypeSkin :: proc(
	group: CharacterPartGroup,
	type: anim.CharacterType,
	skin: ^CharacterSkin,
) {
	switch group {
	case .BODY:
		skin.type[.BODY] = type
	case .HEAD:
		skin.type[.HEAD] = type
	case .FACE:
		skin.type[.FACE_IDLE] = type
		skin.type[.FACE_BLINK] = type
		skin.type[.FACE_HURT] = type
	case .HAND:
		skin.type[.RIGHT_ARM] = type
		skin.type[.RIGHT_HAND] = type
		skin.type[.LEFT_ARM] = type
		skin.type[.LEFT_HAND] = type
	case .LEG:
		skin.type[.RIGHT_LEG] = type
		skin.type[.LEFT_LEG] = type
	case .WEAPON:
		skin.type[.WEAPON] = type
		skin.type[.SLASH_EFFECT] = type
	}
}

setPartTierPlayer :: proc(group: CharacterPartGroup, tier: anim.CharacterTier) {
	switch group {
	case .BODY:
		player_skin.tier[.BODY] = tier
	case .HEAD:
		player_skin.tier[.HEAD] = tier
	case .FACE:
		player_skin.tier[.FACE_IDLE] = tier
		player_skin.tier[.FACE_BLINK] = tier
		player_skin.tier[.FACE_HURT] = tier
	case .HAND:
		player_skin.tier[.RIGHT_ARM] = tier
		player_skin.tier[.RIGHT_HAND] = tier
		player_skin.tier[.LEFT_ARM] = tier
		player_skin.tier[.LEFT_HAND] = tier
	case .LEG:
		player_skin.tier[.RIGHT_LEG] = tier
		player_skin.tier[.LEFT_LEG] = tier
	case .WEAPON:
		player_skin.tier[.WEAPON] = tier
		player_skin.tier[.SLASH_EFFECT] = tier
	}
}

setPartTierSkin :: proc(
	group: CharacterPartGroup,
	tier: anim.CharacterTier,
	skin: ^CharacterSkin,
) {
	switch group {
	case .BODY:
		skin.tier[.BODY] = tier
	case .HEAD:
		skin.tier[.HEAD] = tier
	case .FACE:
		skin.tier[.FACE_IDLE] = tier
		skin.tier[.FACE_BLINK] = tier
		skin.tier[.FACE_HURT] = tier
	case .HAND:
		skin.tier[.RIGHT_ARM] = tier
		skin.tier[.RIGHT_HAND] = tier
		skin.tier[.LEFT_ARM] = tier
		skin.tier[.LEFT_HAND] = tier
	case .LEG:
		skin.tier[.RIGHT_LEG] = tier
		skin.tier[.LEFT_LEG] = tier
	case .WEAPON:
		skin.tier[.WEAPON] = tier
		skin.tier[.SLASH_EFFECT] = tier
	}
}

setSet :: proc(type: anim.CharacterType, tier: anim.CharacterTier) {
	for group in CharacterPartGroup {
		setPartType(group, type)
		setPartTier(group, tier)
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
	case .HAND:
		return .LEFT_ARM
	// return .RIGHT_HAND
	// return .LEFT_ARM
	// return .LEFT_HAND
	case .LEG:
		return .LEFT_LEG
	// return .RIGHT_LEG
	case .WEAPON:
		return .WEAPON
	}

	return .FACE_BLINK
}
