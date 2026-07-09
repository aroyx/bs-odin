package client

import "core:fmt"
import "core:math/rand"
import "core:time"

import anim "../animations"

import "core:math/linalg"

@(private = "file")
CharacterSkin :: struct {
	type:  anim.CharacterType,
	parts: [anim.BodyPart]anim.CharacterTier,
}

@(private = "file")
player_skin: CharacterSkin = {
	type = .SKELETON,
}

init_player :: proc() {
	player_skin.parts[.BODY] = .T1
	player_skin.parts[.HEAD] = .T1
	player_skin.parts[.FACE_IDLE] = .T1
	player_skin.parts[.FACE_BLINK] = .T1
	player_skin.parts[.FACE_HURT] = .T1
	player_skin.parts[.RIGHT_ARM] = .T1
	player_skin.parts[.RIGHT_HAND] = .T1
	player_skin.parts[.RIGHT_LEG] = .T1
	player_skin.parts[.LEFT_ARM] = .T1
	player_skin.parts[.LEFT_HAND] = .T1
	player_skin.parts[.LEFT_LEG] = .T1
	player_skin.parts[.WEAPON] = .T1
	player_skin.parts[.SLASH_EFFECT] = .T1
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
blend_dur :: 150 // ms

run_animation :: proc(pos: linalg.Vector2f32, scale: f32) -> [dynamic]anim.DrawCommand {
	animation_elapsed := f32(
		time.duration_milliseconds(time.diff(animation_start_time, time.now())),
	)

	// if animation_elapsed > anim.anim_lookup[curr_animation]

	if animation_elapsed > curr_animation_length {
		switch_animation()
		animation_start_time = time.now()
		animation_elapsed = 0
	}

	curr_commands := anim.calculate_frame(
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

    prev_time := prev_animation_length + blend_elapsed

	prev_commands := anim.calculate_frame(
		&anim.data.entity,
		prev_animation,
		prev_time,
		pos,
		scale,
	)

	blended_commands := blend_commands(prev_commands, curr_commands, t)

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
		next_anims = {.WALKING, .IDLE_BLINKING, .IDLE_BLINKING, .RUNNING, .KICKING, .SLASHING},
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
	.RUNNING = { 	//
		next_anims = {.RUN_SLASHING, .RUN_THROWING, .WALKING, .WALKING},
		min_loops  = 3,
		max_loops  = 5,
	},
	.RUN_SLASHING = { 	//
		next_anims = {.RUNNING},
		min_loops  = 1,
		max_loops  = 1,
	},
	.RUN_THROWING = { 	//
		next_anims = {.RUNNING},
		min_loops  = 1,
		max_loops  = 1,
	},
	.KICKING = { 	//
		next_anims = {.IDLE, .WALKING},
		min_loops  = 1,
		max_loops  = 1,
	},
	.SLASHING = { 	//
		next_anims = {.IDLE},
		min_loops  = 1,
		max_loops  = 1,
	},
	.THROWING = { 	//
		next_anims = {.IDLE},
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
	.JUMP_START = {},
	.JUMP_LOOP = {},
	.FALLING_DOWN = {},
	.THROWING_IN_THE_AIR = {},
	.SLASHING_IN_THE_AIR = {},
	.SLIDING = {},
}

@(private = "file")
switch_animation :: proc() {
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

blend_commands :: proc(a, b: [dynamic]anim.DrawCommand, t: f32) -> [dynamic]anim.DrawCommand {
	blended_cmds := make([dynamic]anim.DrawCommand, 0, len(a)) // hopefully they have the same draw command length :pray:

	for cmd_b in b { 	// DIAGNOSE: There's a chance that the array is in different order, so need to check their part (cmd.part) to be same to blend first!

		blended_cmd := cmd_b
		for cmd_a in a {

			if cmd_a.part != cmd_b.part do continue

			blended_cmd.x = linalg.lerp(cmd_a.x, cmd_b.x, t)
			blended_cmd.y = linalg.lerp(cmd_a.y, cmd_b.y, t)
			blended_cmd.scale_x = linalg.lerp(cmd_a.scale_x, cmd_b.scale_x, t)
			blended_cmd.scale_y = linalg.lerp(cmd_a.scale_y, cmd_b.scale_y, t)
			blended_cmd.angle = angle_lerp_shortest(cmd_a.angle, cmd_b.angle, t)
			// not blended (defaulted to b):
			// pivot_x, pivot_y: f32,
			// alpha:            f32,

			break
		}
		append(&blended_cmds, blended_cmd)
	}

	return blended_cmds
}

angle_lerp_shortest :: proc(a, b, t: f32) -> f32 {
	diff := b - a

	if diff > 180 do diff -= 360
	if diff < -180 do diff += 360

	return a + (diff * t)
}
