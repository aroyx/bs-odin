package utils

import "core:math"

import rl "vendor:raylib"

FontSize :: enum u8 {
	SMALL,
	MEDIUM,
	LARGE,
}

@(private = "file")
font: [FontSize]rl.Font

@(private = "file")
font_sizes: [FontSize]f32 = {
	.SMALL  = 12,
	.MEDIUM = 24,
	.LARGE  = 48,
}

@(private = "file")
icon_font: rl.Font

initFont :: proc() {
	font[.SMALL] = rl.LoadFontEx("./res/fonts/supercell.otf", i32(font_sizes[.SMALL]), nil, 0)
	font[.MEDIUM] = rl.LoadFontEx("./res/fonts/supercell.otf", i32(font_sizes[.MEDIUM]), nil, 0)
	font[.LARGE] = rl.LoadFontEx("./res/fonts/supercell.otf", i32(font_sizes[.LARGE]), nil, 0)

	icon_codepoints := [?]rune {
		0xe048, // ICON_LUCIDE_ARROW_LEFT
		0xe049, // ICON_LUCIDE_ARROW_RIGHT
		0xe06e, // ICON_LUCIDE_CHEVRON_LEFT
		0xe06f, // ICON_LUCIDE_CHEVRON_RIGHT
		0xe14d, // ICON_LUCIDE_SAVE
		0xe18e, // ICON_LUCIDE_TRASH_2
		0x78, // ICON_LUCIDE_X
	}

	icon_font = rl.LoadFontEx(
		"./res/fonts/lucide.ttf",
		32,
		&icon_codepoints[0],
		len(icon_codepoints),
	)

	rl.SetTextureFilter(font[.SMALL].texture, .BILINEAR)
	rl.SetTextureFilter(font[.MEDIUM].texture, .BILINEAR)
	rl.SetTextureFilter(font[.LARGE].texture, .BILINEAR)
	rl.SetTextureFilter(icon_font.texture, .BILINEAR)
}

getIconFont :: proc() -> ^rl.Font {
	return &icon_font
}

getFont :: proc(size: FontSize = FontSize.MEDIUM) -> ^rl.Font {
	return &font[size]
}

getFontSize :: proc(size: FontSize = FontSize.MEDIUM) -> f32 {
	return font_sizes[size]
}

deinitFont :: proc() {
	for f in font {
		rl.UnloadFont(f)
	}
}

drawText :: proc(text: cstring, size: FontSize, position: rl.Vector2, tint: rl.Color) {
	rl.DrawTextEx(font[size], text, position, font_sizes[size], 1, tint)
}

drawCenteredText :: proc(
	text: cstring,
	size: FontSize = .MEDIUM,
	x_offset: f32 = 0,
	y_offset: f32 = 0,
	tint: rl.Color = rl.BLACK,
) {
	if text == nil do return

	w := f32(rl.GetRenderWidth())
	h := f32(rl.GetRenderHeight())

	s := rl.MeasureTextEx(font[size], text, font_sizes[size], 1)

	x := ((w - s.x) / 2.0) + x_offset
	y := ((h - s.y) / 2.0) + y_offset

	rl.DrawTextEx(font[size], text, {math.round(x), math.round(y)}, font_sizes[size], 1, tint)
}

getTextSize :: proc(text: cstring, size: FontSize) -> (f32, f32) {
	s := rl.MeasureTextEx(font[size], text, font_sizes[size], 1)
	return s.x, s.y
}
