package client

// this file has character skin and random animations player in the home/menu screen

import "core:fmt"
import "core:math/rand"
import "core:time"

import anim "../animations"

import "core:math/linalg"

@(private)
CharacterPartGroup :: enum {
	HEAD,
	BODY,
	FACE,
	RIGHT_HAND,
	LEFT_HAND,
	RIGHT_LEG,
	LEFT_LEG,
	WEAPON,
}

@(private = "file")
CharacterSkin :: struct {
	type: [anim.BodyPart]anim.CharacterType,
	tier: [anim.BodyPart]anim.CharacterTier,
}

player_skin: CharacterSkin

initPlayer :: proc() {
	player_skin.tier[.BODY] = .T1
	player_skin.tier[.HEAD] = .T1
	player_skin.tier[.FACE_IDLE] = .T1
	player_skin.tier[.FACE_BLINK] = .T1
	player_skin.tier[.FACE_HURT] = .T1
	player_skin.tier[.RIGHT_ARM] = .T1
	player_skin.tier[.RIGHT_HAND] = .T1
	player_skin.tier[.RIGHT_LEG] = .T1
	player_skin.tier[.LEFT_ARM] = .T1
	player_skin.tier[.LEFT_HAND] = .T1
	player_skin.tier[.LEFT_LEG] = .T1
	player_skin.tier[.WEAPON] = .T1
	player_skin.tier[.SLASH_EFFECT] = .T1

	//

	player_skin.type[.BODY] = .SKELETON
	player_skin.type[.HEAD] = .SKELETON
	player_skin.type[.FACE_IDLE] = .SKELETON
	player_skin.type[.FACE_BLINK] = .SKELETON
	player_skin.type[.FACE_HURT] = .SKELETON
	player_skin.type[.RIGHT_ARM] = .SKELETON
	player_skin.type[.RIGHT_HAND] = .SKELETON
	player_skin.type[.RIGHT_LEG] = .SKELETON
	player_skin.type[.LEFT_ARM] = .SKELETON
	player_skin.type[.LEFT_HAND] = .SKELETON
	player_skin.type[.LEFT_LEG] = .SKELETON
	player_skin.type[.WEAPON] = .SKELETON
	player_skin.type[.SLASH_EFFECT] = .SKELETON
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
		// return .RIGHT_ARM
		return .RIGHT_HAND
	case .RIGHT_LEG:
		return .RIGHT_LEG
	case .LEFT_HAND:
		// return .LEFT_ARM
		return .LEFT_HAND
	case .LEFT_LEG:
		return .LEFT_LEG
	case .WEAPON:
		return .WEAPON
	}

    return .FACE_BLINK
}

// **************************
// PLAYER ANIMATION IN THE MENUs
// **************************

@(private = "file")
curr_animation: anim.AnimationName = .IDLE

@(private = "file")
curr_animation_length: f32 = 2000

@(private = "file")
animation_start_time: time.Time

@(private = "file")
prev_animation: anim.AnimationName

@(private = "file")
prev_animation_length: f32

@(private = "file")
blending := false

@(private = "file")
blend_start_time: time.Time

@(private = "file")
blend_dur :: 250 // ms

runAnimation :: proc(pos: linalg.Vector2f32, scale: f32) -> [dynamic]anim.DrawCommand {
	animation_elapsed := f32(
		time.duration_milliseconds(time.diff(animation_start_time, time.now())),
	)

	// if animation_elapsed > anim.anim_lookup[curr_animation]

	if animation_elapsed > curr_animation_length {
		switchAnimation()
		animation_start_time = time.now()
		animation_elapsed = 0
	}

	curr_commands := anim.calculateFrame(
		&anim.data.entity,
		curr_animation,
		animation_elapsed * 1.0,
		pos,
		scale,
	)

	if !blending {
		return curr_commands
	}

	blend_elapsed := f32(time.duration_milliseconds(time.diff(blend_start_time, time.now())))
	t := blend_elapsed / blend_dur

	if t > 1.0 {
		blending = false
		return curr_commands
	}

	prev_time := prev_animation_length

	prev_commands := anim.calculateFrame(&anim.data.entity, prev_animation, prev_time, pos, scale)

	blended_commands := blendCommands(prev_commands, curr_commands, t)

	if len(curr_commands) > 0 do delete(curr_commands)
	if len(prev_commands) > 0 do delete(prev_commands)

	return blended_commands
}

@(private = "file")
AnimeRule :: struct {
	next_anims:           []anim.AnimationName,
	max_loops, min_loops: u8,
}

@(private = "file")
animation_ruleset: [anim.AnimationName]AnimeRule = {
	.IDLE = { 	//
		next_anims = {.WALKING, .IDLE_BLINKING, .KICKING, .HURT},
		min_loops  = 4,
		max_loops  = 8,
	},
	.IDLE_BLINKING = { 	//
		next_anims = {.IDLE},
		min_loops  = 1,
		max_loops  = 1,
	},
	.WALKING = { 	//
		next_anims = {.IDLE, .IDLE, .RUNNING, .KICKING},
		min_loops  = 1,
		max_loops  = 3,
	},
	.KICKING = { 	//
		next_anims = {.IDLE, .WALKING},
		min_loops  = 1,
		max_loops  = 1,
	},
	.HURT = { 	//
		next_anims = {.IDLE, .DYING},
		min_loops  = 1,
		max_loops  = 1,
	},
	.DYING = { 	//
		next_anims = {.IDLE},
		min_loops  = 1,
		max_loops  = 1,
	},
	// never run
	.BASE = {},
	.RUNNING = {},
	.RUN_SLASHING = {},
	.RUN_THROWING = {},
	.SLASHING = {},
	.THROWING = {},
	.JUMP_START = {},
	.JUMP_LOOP = {},
	.FALLING_DOWN = {},
	.THROWING_IN_THE_AIR = {},
	.SLASHING_IN_THE_AIR = {},
	.SLIDING = {},
}

@(private = "file")
switchAnimation :: proc() {
	rules := animation_ruleset[curr_animation]

	next_anim: anim.AnimationName

	if len(rules.next_anims) == 0 {
		next_anim = .IDLE
	} else {
		index := rand.int_max(len(rules.next_anims))
		next_anim = rules.next_anims[index]
	}

	new_rules := animation_ruleset[next_anim]
	loops: int = 1

	if new_rules.max_loops > new_rules.min_loops {
		range := int(new_rules.max_loops - new_rules.min_loops + 1)
		loops = rand.int_max(range) + int(new_rules.min_loops)
	} else if new_rules.max_loops > 0 {
		loops = int(new_rules.max_loops)
	}

	anim_name := anim.anim_lookup[next_anim]
	if !(anim_name in anim.data.entity.animations) {
		fmt.println("Animation not found! ", anim_name)
		return
	}

	prev_animation = curr_animation
	blending = true
	blend_start_time = time.now()

	curr_animation = next_anim
	anime := &anim.data.entity.animations[anim_name]

	prev_animation_length = curr_animation_length
	curr_animation_length = f32(anime.length) * f32(loops)
}

blendCommands :: proc(a, b: [dynamic]anim.DrawCommand, t: f32) -> [dynamic]anim.DrawCommand {
	blended_cmds := make([dynamic]anim.DrawCommand, 0, len(a)) // hopefully they have the same draw command length :pray:

	for cmd_b in b { 	// DIAGNOSE: There's a chance that the array is in different order, so need to check their part (cmd.part) to be same to blend first!

		blended_cmd := cmd_b
		for cmd_a in a {

			if cmd_a.part != cmd_b.part do continue

			blended_cmd.x = linalg.lerp(cmd_a.x, cmd_b.x, t)
			blended_cmd.y = linalg.lerp(cmd_a.y, cmd_b.y, t)
			blended_cmd.scale_x = linalg.lerp(cmd_a.scale_x, cmd_b.scale_x, t)
			blended_cmd.scale_y = linalg.lerp(cmd_a.scale_y, cmd_b.scale_y, t)
			blended_cmd.angle = angleLerpShortest(cmd_a.angle, cmd_b.angle, t)
			// not blended (defaulted to b):
			// pivot_x, pivot_y: f32,
			// alpha:            f32,

			break
		}
		append(&blended_cmds, blended_cmd)
	}

	return blended_cmds
}

angleLerpShortest :: proc(a, b, t: f32) -> f32 {
	diff := b - a

	if diff > 180 do diff -= 360
	if diff < -180 do diff += 360

	return a + (diff * t)
}
