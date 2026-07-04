package utils

import "vendor:raylib"
loadRayGuiStyleFromMemory :: proc(data: []u8) {
	// https://github.com/raysan5/raylib/blob/master/examples/core/raygui.h#L4844
	if len(data) < 12 do return // too small to even have the initial things
	if data[0] != 'r' || data[1] != 'G' || data[2] != 'S' || data[3] != ' ' do return

	propertyCount := (cast(^u32le)&data[8])^

	for i in 0 ..< propertyCount {
		index := int(12 + 8 * i)
		if index + 8 > len(data) do break

		controlId := (cast(^u16le)&data[index])^
		propertyId := (cast(^u16le)&data[index + 2])^
		propertyValue := (cast(^i32le)&data[index + 2 + 2])^

		if controlId == 0 {
			raylib.GuiSetStyle(auto_cast 0, i32(propertyId), i32(propertyValue))

			// https://github.com/raysan5/raylib/blob/master/examples/core/raygui.h#L1422
			RAYGUI_MAX_PROPS_EXTENDED :: 8
			RAYGUI_MAX_CONTROLS :: 16

			if propertyId < RAYGUI_MAX_PROPS_EXTENDED {
				for j in 1 ..< RAYGUI_MAX_CONTROLS {
					raylib.GuiSetStyle(auto_cast j, i32(propertyId), i32(propertyValue))
				}
			}
		} else {
			raylib.GuiSetStyle(auto_cast controlId, i32(propertyId), i32(propertyValue))
		}
	}
}
