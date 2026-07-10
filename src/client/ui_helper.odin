package client

import "../utils"
import "thirdparty:orui"
import rl "vendor:raylib"

@(private)
getBorder :: proc() -> orui.Edges {
	return orui.animate(
		"border_width", // border can be set in one elment once so shouldn't need different ids
		orui.active() ? orui.border(0) : (orui.hovered() ? orui.border(2) : orui.border(4)),
	)
}

@(private)
icon_with_text :: proc(
	id: string,
	icon: string,
	text: string,
	config: orui.ElementConfig,
) -> bool {
	ctn_config := config
	ctn_config.direction = .LeftToRight
	ctn_config.align_content = .Center
	ctn_config.align_main = .Center
	ctn_config.gap = 10

	orui.container(orui.id(id, 1), ctn_config)

	orui.label(
		orui.id(id, 2),
		icon,
		{
			width = orui.fixed(config.font_size),
			height = orui.grow(),
			font = utils.get_icon_font(),
			font_size = config.font_size + 4,
			color = rl.BLACK,
			align = {.Center, .Center},
			block = .False,
		},
	)

	text_config := config
	text_config.background_color = rl.BLANK
	text_config.width = orui.fit()
	text_config.border_color = rl.BLACK
	text_config.border = {}
	text_config.corner_radius = {}
    text_config.block = .False

	orui.label(orui.id(id, 3), text, text_config)

	return orui.clicked(orui.to_id(id, 1))
}

// colors
@(private)
BLUE :: rl.Color{0, 129, 167, 255}
CYAN :: rl.Color{0, 210, 210, 255}
WHITE :: rl.Color{253, 252, 220, 255}
YELLOW :: rl.Color{254, 217, 183, 255}
RED :: rl.Color{240, 113, 103, 255}
