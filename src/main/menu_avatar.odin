package client

import "core:fmt"
import "core:reflect"
import "core:strings"

import anim "../animations"
import "../playing"
import "../utils"

import "thirdparty:orui"
import rl "vendor:raylib"

avatar_select_state: ClientState = {
	on_update = on_update,
	on_render = on_render,
}

@(private = "file")
on_update :: proc(dt: f32) {
	clearId()
	if rl.IsKeyPressed(.ESCAPE) {
		changeState(&main_menu_state)
	}

	updateAnimPlayer()
}

@(private = "file")
on_render :: proc() {
	rl.ClearBackground(BLUE)

	drawAnimPlayer()

	orui.container(
		orui.id("main_container"),
		{
			direction   = .LeftToRight,
			width       = orui.grow(),
			height      = orui.grow(), //
			align_cross = .Center,
		},
	)
	{
		orui.container(
			orui.id(getId()),
			{ 	// character drawn
				width  = orui.grow(),
				height = orui.grow(),
			},
		)
	}
	orui.container(
		orui.id(getId()),
		{
			width = {type = .Percent, value = 0.55, min = 400, max = 600},
			height = {type = .Percent, value = 0.85, min = 250, max = 650},
			margin = orui.margin(20, 0),
			background_color = CYAN,
			border = orui.border(10),
			corner_radius = orui.corner(10),
			border_color = rl.BLACK,
			direction = .TopToBottom,
		},
	)

	{orui.container(
			orui.id(getId()),
			{
				width = orui.grow(),
				height = orui.grow(),
				align_main = .Center,
				align_cross = .Center,
				direction = .TopToBottom,
				padding = orui.padding(20),
				gap = 10,
				scroll = orui.scroll(.Vertical),
				clip = {.Intersect, {}},
			},
		)

		for type in playing.CharacterPartGroup {
			uiTypeSelector(type)
		}
	}

	{orui.container(
			orui.id(getId()),
			{width = orui.grow(), height = orui.fixed(50), background_color = BLUE},
		)

		if iconWithText(
			"back_button",
			"\ue06e",
			"Back",
			{
				width = orui.grow(),
				height = orui.grow(),
				font_size = 20,
				color = rl.BLACK,
				background_color = YELLOW,
				align = {.Center, .Center},
				padding = orui.padding(5),
				border = {top = 4},
				border_color = rl.BLACK,
			},
		) {
			changeState(&main_menu_state)
		}
	}
}

uiTypeSelector :: proc(group: playing.CharacterPartGroup) {
	displayName(group)

	orui.container(
		orui.id(getId()),
		{
			width       = orui.grow(),
			height      = orui.fixed(150),
			direction   = .LeftToRight,
			// background_color = BLUE,
			align_cross = .Center,
			padding     = orui.padding(20, 0),
		},
	)

	part := playing.getPartFromGroup(group)
	curr_type := playing.player_skin.type[part]
	curr_tier := playing.player_skin.tier[part]

	num_types := len(anim.CharacterType)
	num_tiers := len(anim.CharacterTier)

	total_options := num_types * num_tiers

	current_index := (int(curr_type) * num_tiers) + int(curr_tier)

	// left chevron
	if orui.label(
		orui.id(getId()),
		"\ue06e",
		{
			width = orui.fixed(40),
			height = orui.fixed(40),
			font = utils.getIconFont(),
			font_size = 30,
			color = rl.BLACK,
			background_color = WHITE,
			align = {.Center, .Center},
			border = getBorder(fmt.tprintf("border_left_%d", getId())),
			border_color = rl.BLACK,
			corner_radius = orui.corner(20),
		},
	) {
		new_index := (current_index - 1 + total_options) % total_options

		playing.setPartType(group, anim.CharacterType(new_index / num_tiers))
		playing.setPartTier(group, anim.CharacterTier(new_index % num_tiers))

		if group == .WEAPON {
			forceChangeAnimation(.SLASHING)
		}
	}

	{
		current_index := (int(curr_type) * num_tiers) + int(curr_tier)
		prev_index := (current_index - 1 + total_options) % total_options
		next_index := (current_index + 1) % total_options

		curr_tex := anim.getPartTex(
			anim.CharacterType(current_index / num_tiers),
			anim.CharacterTier(current_index % num_tiers),
			part,
		)

		prev_tex := anim.getPartTex(
			anim.CharacterType(prev_index / num_tiers),
			anim.CharacterTier(prev_index % num_tiers),
			part,
		)

		next_tex := anim.getPartTex(
			anim.CharacterType(next_index / num_tiers),
			anim.CharacterTier(next_index % num_tiers),
			part,
		)

		displayPartImages(prev_tex, curr_tex, next_tex)
	}

	// right chevron
	if orui.label(
		orui.id(getId()),
		"\ue06f",
		{
			width = orui.fixed(40),
			height = orui.fixed(40),
			font = utils.getIconFont(),
			font_size = 30,
			color = rl.BLACK,
			background_color = WHITE,
			align = {.Center, .Center},
			border = getBorder(fmt.tprintf("border_right_%d", getId())),
			border_color = rl.BLACK,
			corner_radius = orui.corner(20),
		},
	) {
		new_index := (current_index + 1) % total_options

		playing.setPartType(group, anim.CharacterType(new_index / num_tiers))
		playing.setPartTier(group, anim.CharacterTier(new_index % num_tiers))

		if group == .WEAPON {
			forceChangeAnimation(.SLASHING)
		}
	}
}

displayName :: proc(group: playing.CharacterPartGroup) {
	name_part_str, ok := reflect.enum_name_from_value(group)
	if !ok do return

	if strings.contains(name_part_str, "_") {
		name_str, ok2 := strings.replace(
			name_part_str,
			"_",
			" ",
			3,
			allocator = context.temp_allocator,
		)
		if !ok2 do return

		name_part_str = name_str
	}

	orui.label(
		orui.id(getId()),
		name_part_str,
		{
			font_size = 24,
			width = orui.grow(),
			height = orui.fit(),
			padding = orui.padding(5),
			color = rl.BLACK,
			align = {.Center, .Center},
			border = orui.border(4),
			border_color = rl.BLACK,
			corner_radius = orui.corner(4),
			background_color = RED,
		},
	)
}

displayPartImages :: proc(prev_tex, curr_tex, next_tex: rl.Texture) {
	orui.container(
		orui.id(getId()),
		{
			width = orui.grow(),
			height = orui.grow(),
			direction = .LeftToRight,
			gap = 10,
			align_cross = .Center,
			align_main = .Center,
			padding = orui.padding(10, 0),
		},
	)

	textures := make([]rl.Texture, 3, allocator = context.temp_allocator)
	textures[0] = prev_tex
	textures[1] = curr_tex
	textures[2] = next_tex

	for i in 0 ..< 3 {
		selected := i == 1

		size := selected ? 120 : 100
		alpha: u8 = selected ? 255 : 200
		weight: f32 = selected ? 1.5 : 1.0
		percent_y: f32 = selected ? 0.9 : 0.7

		orui.image(
			orui.id(getId()),
			&textures[i],
			{
				width = orui.grow(weight),
				height = {type = .Percent, value = percent_y},
				background_color = selected ? WHITE : rl.LIGHTGRAY,
				border = orui.border(4),
				corner_radius = orui.corner(10),
				border_color = selected ? rl.GOLD : rl.GRAY,
				texture_fit = .Contain,
				align = {.Center, .Center},
				color = {255, 255, 255, alpha},
			},
		)
	}
}
