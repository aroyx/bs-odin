package playing

import anim "../animations"
import "../camera"

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"
import "core:time"

import rl "vendor:raylib"

CharacterSkin :: struct {
	type: [anim.BodyPart]anim.CharacterType,
	tier: [anim.BodyPart]anim.CharacterTier,
}

AnimationState :: struct {
	current_animation:        anim.AnimationName,
	current_animation_length: f32,
	animation_start_time:     time.Time,
	flip_x:                   f32,
}

randomSkin :: proc(skin: ^CharacterSkin) {
	for part in anim.BodyPart {
		type := anim.CharacterType(rand.int_max(len(anim.CharacterType)))
		tier := anim.CharacterTier(rand.int_max(len(anim.CharacterTier)))

		skin.type[part] = type
		skin.tier[part] = tier
	}
}

drawAnimate :: proc(
	anim_state: ^AnimationState,
	skin: ^CharacterSkin,
	pos: linalg.Vector2f32,
	camTopLeft: linalg.Vector2f32,
) {
	if anim_state.current_animation_length < 0 {
		return
	}

	lapsed: f32 = auto_cast time.duration_milliseconds(
		time.diff(anim_state.animation_start_time, time.now()),
	)

	anim_time: f32

	if anim_state.current_animation == .DYING {
		anim_time = math.min(lapsed, anim_state.current_animation_length - 1)
	} else {
		anim_time = math.mod(lapsed, anim_state.current_animation_length)
	}

	cs := camera.state.cs
	tex_w, tex_h: f32 = 230, 500

	draw_x := pos.x - camTopLeft.x + camera.state.x_offset
	draw_y := pos.y - camTopLeft.y + camera.state.y_offset + (cs * 0.25)

	scale := cs / tex_w

	context.allocator = context.temp_allocator

	draw_cmds := anim.calculateFrame(
		anim_state.current_animation,
		anim_time,
		{draw_x, draw_y},
		scale,
	)

	for cmd in draw_cmds {
		type := skin.type[cmd.part]
		tier := skin.tier[cmd.part]

		tex := anim.getPartTex(type, tier, cmd.part)

		source: rl.Rectangle = {
			x      = 0,
			y      = 0,
			width  = f32(tex.width) * anim_state.flip_x,
			height = f32(tex.height),
		}

		dest: rl.Rectangle = {
			x      = draw_x + ((cmd.x - draw_x) * anim_state.flip_x),
			y      = cmd.y,
			width  = f32(tex.width) * cmd.scale_x,
			height = f32(tex.height) * cmd.scale_y,
		}

		origin_x: f32 = anim_state.flip_x > 0 ? 0 : dest.width

		color: rl.Color = {255, 255, 255, u8(cmd.alpha * 255)}
		rl.DrawTexturePro(tex, source, dest, {origin_x, 0}, cmd.angle * anim_state.flip_x, color)
	}
}

changeAnimation :: proc(anim_state: ^AnimationState, anime: anim.AnimationName) {
	if anim_state.current_animation == anime do return

	anim_name := anim.anim_lookup[anime]
	if !(anim_name in anim.data.entity.animations) {
		fmt.println("Animation not found! ", anim_name)
		return
	}

	anim_data := &anim.data.entity.animations[anim_name]

	anim_state.animation_start_time = time.now()
	anim_state.current_animation = anime
	anim_state.current_animation_length = f32(anim_data.length)
}
