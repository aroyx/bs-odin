// copied and modified from https://github.com/karl-zylinski/odin-raylib-web

package main_web

import "base:runtime"
import "core:c"
import "core:mem"

import client ".."
import "../../utils"

@(private = "file")
web_context: runtime.Context

@(export)
main_start :: proc "c" (on_mobile: bool) {
	context = runtime.default_context()

	// The WASM allocator doesn't seem to work properly in combination with
	// emscripten. There is some kind of conflict with how the manage memory.
	// So this sets up an allocator that uses emscripten's malloc.
	context.allocator = emscripten_allocator()
	runtime.init_global_temporary_allocator(1 * mem.Megabyte)

	// Since we now use js_wasm32 we should be able to remove this and use
	// context.logger = log.create_console_logger(). However, that one produces
	// extra newlines on web. So it's a bug in that core lib.

	context.logger = create_emscripten_logger()

	web_context = context

    utils.global.options.on_mobile = on_mobile
	client.init()
}

@(export)
main_update :: proc "c" () -> bool {
	context = web_context
	client.update()
	return client.shouldRun()
}

@(export)
main_end :: proc "c" () {
	context = web_context
	client.close()
}

@(export)
web_window_size_changed :: proc "c" (w: c.int, h: c.int) {
	context = web_context
	client.windowSizeChanged(int(w), int(h))
}
