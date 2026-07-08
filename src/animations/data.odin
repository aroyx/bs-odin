package animation

BodyPart :: enum u8 {
	BODY, // the torso
	HEAD,
	// face is usually the eyes
	FACE_IDLE,
	FACE_BLINK,
	FACE_HURT,
	RIGHT_ARM,
	RIGHT_HAND,
	RIGHT_LEG,
	LEFT_ARM,
	LEFT_HAND,
	LEFT_LEG,
	WEAPON, // sword.png
	SLASH_EFFECT,
}

CharacterType :: enum u8 {
	SKELETON,
	// GOBLIN,
	// GOLEM
}

CharacterTier :: enum u8 {
	T1,
	// T2,
	// T3,
}

AnimationName :: enum u8 {
    BASE,
	IDLE,
	IDLE_BLINKING,
	KICKING,
	WALKING,
	RUNNING,
	RUN_SLASHING,
	RUN_THROWING,
	SLIDING,
	JUMP_START,
	JUMP_LOOP,
	FALLING_DOWN,
	SLASHING,
	SLASHING_IN_THE_AIR,
	THROWING,
	THROWING_IN_THE_AIR,
	HURT,
	DYING,
}

anim_lookup := [AnimationName]string {
	.BASE                = "Base",
	.IDLE                = "Idle",
	.IDLE_BLINKING       = "Idle Blinking",
	.KICKING             = "Kicking",
	.WALKING             = "Walking",
	.RUNNING             = "Running",
	.RUN_SLASHING        = "Run Slashing",
	.RUN_THROWING        = "Run Throwing",
	.SLIDING             = "Sliding",
	.JUMP_START          = "Jump Start",
	.JUMP_LOOP           = "Jump Loop",
	.FALLING_DOWN        = "Falling Down",
	.SLASHING            = "Slashing",
	.SLASHING_IN_THE_AIR = "Slashing in The Air",
	.THROWING            = "Throwing",
	.THROWING_IN_THE_AIR = "Throwing in The Air",
	.HURT                = "Hurt",
	.DYING               = "Dying",
}

@(private)
part_lookup := [BodyPart]string {
	.BODY         = "Body.png",
	.HEAD         = "Head.png",
	.FACE_IDLE    = "Face 01.png",
	.FACE_BLINK   = "Face 02.png",
	.FACE_HURT    = "Face 03.png",
	.RIGHT_ARM    = "Right Arm.png",
	.RIGHT_HAND   = "Right Hand.png",
	.RIGHT_LEG    = "Right Leg.png",
	.LEFT_ARM     = "Left Arm.png",
	.LEFT_HAND    = "Left Hand.png",
	.LEFT_LEG     = "Left Leg.png",
	.WEAPON       = "Sword.png",
	.SLASH_EFFECT = "SlashFX.png",
}

@(private)
type_lookup := [CharacterType]string {
	.SKELETON = "skeleton",
	// .GOBLIN = "goblin",
	// .GOLEM = "golem",
}

@(private)
tier_lookup := [CharacterTier]string {
	.T1 = "1",
	// .T2 = "2",
	// .T3 = "3",
}
