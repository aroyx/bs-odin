package orui

import rl "vendor:raylib"

RenderCommand :: struct {
	type: RenderCommandType,
	source: ^Element,
	data: RenderCommandData,
}

RenderCommandType :: enum {
	None,
	Rectangle,
	Border,
	Text,
	Image,
	ScissorStart,
	ScissorEnd,
	Custom,
}

RenderCommandData :: union {
	RenderCommandDataRectangle,
	RenderCommandDataBorder,
	RenderCommandDataText,
	RenderCommandDataImage,
	RenderCommandDataScissorStart,
	RenderCommandDataScissorEnd,
	RenderCommandDataCustom,
}

RenderCommandDataRectangle :: struct {
	position:      rl.Vector2,
	size:          rl.Vector2,
	border:        Edges,
	color:         rl.Color,
	corner_radius: Corners,
}

RenderCommandDataBorder :: struct {
	position:      rl.Vector2,
	size:          rl.Vector2,
	border:        Edges,
	color:         rl.Color,
	corner_radius: Corners,
}

RenderCommandDataText :: struct {
	position:       rl.Vector2,
	text:           string,
	color:          rl.Color,
	font:           ^rl.Font,
	font_size:      f32,
	letter_spacing: f32,
	start_index:    int,
	end_index:      int,
}

RenderCommandDataImage :: struct {
	texture: ^rl.Texture2D,
	color:   rl.Color,
	src:     rl.Rectangle,
	dst:     rl.Rectangle,
}

RenderCommandDataScissorStart :: struct {
	rectangle: ClipRectangle,
}

RenderCommandDataScissorEnd :: struct {}

RenderCommandDataCustom :: struct {
	source:       ^Element,
	rectangle:    rl.Rectangle,
	custom_event: rawptr,
}
