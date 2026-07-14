package character

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
}

randomSkin :: proc(skin: ^CharacterSkin) {
	for part in anim.BodyPart {
		type := anim.CharacterType(rand.int_max(len(anim.CharacterType)))
		tier := anim.CharacterTier(rand.int_max(len(anim.CharacterTier)))

		skin.type[part] = type
		skin.tier[part] = tier
	}
}

drawAnimate :: proc(player: ^Entity, camTopLeft: linalg.Vector2f32) {
	if player.animation.current_animation_length < 0 {
		return
	}

	anim_time := math.mod(
		f32(
			time.duration_milliseconds(
				time.diff(player.animation.animation_start_time, time.now()),
			),
		),
		player.animation.current_animation_length,
	)

	cs := camera.state.cs
	tex_w, tex_h: f32 = 230, 500

	draw_x := player.pos.x - camTopLeft.x + camera.state.x_offset
	draw_y := player.pos.y - camTopLeft.y + camera.state.y_offset + (cs * 0.67)

	scale := cs / tex_w

	context.allocator = context.temp_allocator

	draw_cmds := anim.calculateFrame(
		player.animation.current_animation,
		anim_time,
		{draw_x, draw_y},
		scale,
	)

	for cmd in draw_cmds {
		type := player.skin.type[cmd.part]
		tier := player.skin.tier[cmd.part]

		tex := anim.getPartTex(type, tier, cmd.part)

		source: rl.Rectangle = {
			x      = 0,
			y      = 0,
			width  = f32(tex.width),
			height = f32(tex.height),
		}

		dest: rl.Rectangle = {
			x      = cmd.x,
			y      = cmd.y,
			width  = f32(tex.width) * cmd.scale_x,
			height = f32(tex.height) * cmd.scale_y,
		}

		color: rl.Color = {255, 255, 255, u8(cmd.alpha * 255)}
		rl.DrawTexturePro(tex, source, dest, {}, cmd.angle, color)
	}
}

changeAnimation :: proc(player: ^Entity, anime: anim.AnimationName) {
	if player.animation.current_animation == anime do return

	anim_name := anim.anim_lookup[anime]
	if !(anim_name in anim.data.entity.animations) {
		fmt.println("Animation not found! ", anim_name)
		return
	}

	anim_data := &anim.data.entity.animations[anim_name]

	player.animation.animation_start_time = time.now()
	player.animation.current_animation = anime
	player.animation.current_animation_length = f32(anim_data.length)
}
