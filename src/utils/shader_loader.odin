package utils

import "core:fmt"
import "vendor:raylib"

when ODIN_OS == .JS {
	glsl_version := "100"
} else {
	glsl_version := "330"
}

loadShader :: proc(vs_name, fs_name: cstring) -> raylib.Shader {
	vs_path := fmt.ctprintf("res/shaders/glsl%s/%s", glsl_version, vs_name)
	fs_path := fmt.ctprintf("res/shaders/glsl%s/%s", glsl_version, fs_name)

	return raylib.LoadShader(vs_path, fs_path)
}
