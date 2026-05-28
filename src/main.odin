package main

import "core:fmt"
import "vendor:sdl3"

Cat :: struct {
	age: i32,
	gay: bool,
	name: f32,
	ars: i64,
}

main :: proc() {
    cat: Cat = {
        name = 32,
        gay = false,
        ars = 32,
        age = 34,
    }

    new: ^i16 = cast(^i16)&cat;
    fmt.print(new^)

	window: ^sdl3.Window = sdl3.CreateWindow("HMH-Odin", 800, 600, {.RESIZABLE})
	defer sdl3.DestroyWindow(window)

	renderer := sdl3.CreateRenderer(window, nil)
	defer sdl3.DestroyRenderer(renderer)

	quit: bool = false
	event: sdl3.Event

	alu := 1024 * 1024 * 1024

	for !quit {
		sdl3.SetRenderDrawColor(renderer, 200, 100, 240, 255)
		sdl3.RenderClear(renderer)

		for (sdl3.PollEvent(&event)) {
			if event.type == .QUIT {
				quit = true
				break
			}
		}

		sdl3.RenderPresent(renderer)
		sdl3.Delay(16)
		alu += 1
	}
}
