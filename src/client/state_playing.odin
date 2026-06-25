package client

import "src:client/camera"
import "src:client/network"
import "src:common"

import "vendor:sdl3"

import "core:math"
import "core:math/linalg"

playing_state: ClientState = {
	on_enter         = on_enter,
	on_network_event = on_network_event,
	on_event         = on_event,
	on_update        = on_update,
	on_render        = on_render,
}

@(private = "file")
lock_camera := false

@(private = "file")
on_enter :: proc() {
	w, h: i32
	sdl3.GetWindowSize(window, &w, &h)
	camera.Init(w, h, map_size)
    lock_camera = false
}

@(private = "file")
on_network_event :: proc(pEvent: network.ReceivedStruct) {
	#partial switch packet in pEvent {
	case common.ServerOutput:
		global.render_state = packet
		updatePlayerPos()

        if !lock_camera {
            camera.StartTagAlong(gPlayer.pos)
            lock_camera = true
        }
	}
}

@(private = "file")
on_event :: proc(event: ^sdl3.Event) {
	if event.type == .WINDOW_RESIZED {
		w, h: i32
		sdl3.GetWindowSize(window, &w, &h)
		camera.SizeUpdate(w, h)

		generateVertices()
	}

	keys := sdl3.GetKeyboardState(nil)

	x_axis: f32 = 0
	y_axis: f32 = 0

	if keys[sdl3.Scancode.W] || keys[sdl3.Scancode.UP] do y_axis = -1
	if keys[sdl3.Scancode.S] || keys[sdl3.Scancode.DOWN] do y_axis = 1
	if keys[sdl3.Scancode.A] || keys[sdl3.Scancode.LEFT] do x_axis = -1
	if keys[sdl3.Scancode.D] || keys[sdl3.Scancode.RIGHT] do x_axis = 1

	global.input.x_axis = x_axis
	global.input.y_axis = y_axis
	global.input.type = .PLAYER_INPUT
}

@(private = "file")
on_update :: proc(dt: f32) {
	camera.Update()
}

@(private = "file")
on_render :: proc() {
	sdl3.SetRenderDrawColor(renderer, 0, 0, 0, 255) // black
	sdl3.RenderClear(renderer)

	renderTerrain()

	cs := camera.state.cs
	cp := camera.camPos

	camTopLeft: linalg.Vector2f32 = {
		math.clamp(cp.x - (cs * camera.state.hcc * 0.5), 0, cs * (map_size - camera.state.hcc)),
		math.clamp(cp.y - (cs * camera.state.vcc * 0.5), 0, cs * (map_size - camera.state.vcc)),
	}

	for i in 0 ..< global.render_state.player_count {
		player := global.render_state.states[i]
		rect: sdl3.FRect

		dim :: 30
		rect.h = dim
		rect.w = dim
		rect.x = player.x - (dim * 0.5) - camTopLeft.x + camera.state.x_offset
		rect.y = player.y - (dim * 0.5) - camTopLeft.y + camera.state.y_offset

		sdl3.SetRenderDrawColor(
			renderer,
			0,
			u8((player.x / 800.0) * 255.0),
			u8((player.y / 600.0) * 255.0),
			255,
		)

		sdl3.RenderFillRect(renderer, &rect)
	}
}
