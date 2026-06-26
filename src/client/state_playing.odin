package client

import "src:client/camera"
import "src:client/network"
import "src:common"

import "core:math"
import "core:math/linalg"

import rl "vendor:raylib"

playing_state: ClientState = {
	on_enter         = on_enter,
	on_network_event = on_network_event,
	on_update        = on_update,
	on_render        = on_render,
}

@(private = "file")
lock_camera := false

@(private = "file")
on_enter :: proc() {
	w := rl.GetScreenWidth()
	h := rl.GetScreenHeight()
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
on_update :: proc(dt: f32) {
	camera.Update()
	sendInputsToServer()

	if rl.IsWindowResized() {
		w := rl.GetScreenWidth()
		h := rl.GetScreenHeight()
		camera.SizeUpdate(w, h)

		generateVertices()
	}

	x_axis: f32 = 0
	y_axis: f32 = 0

	if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP) do y_axis = -1
	if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN) do y_axis = 1
	if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT) do x_axis = -1
	if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) do x_axis = 1

	global.input.x_axis = x_axis
	global.input.y_axis = y_axis
	global.input.type = .PLAYER_INPUT
}

@(private = "file")
on_render :: proc() {
	rl.ClearBackground(rl.BLACK)

	renderTerrain()

	cs := camera.state.cs
	cp := camera.camPos

	camTopLeft: linalg.Vector2f32 = {
		math.clamp(cp.x - (cs * camera.state.hcc * 0.5), 0, cs * (map_size - camera.state.hcc)),
		math.clamp(cp.y - (cs * camera.state.vcc * 0.5), 0, cs * (map_size - camera.state.vcc)),
	}

	for i in 0 ..< global.render_state.player_count {
		player := global.render_state.states[i]
		rect: rl.Rectangle

		dim :: 30
		rect.height = dim
		rect.width = dim
		rect.x = player.x - (dim * 0.5) - camTopLeft.x + camera.state.x_offset
		rect.y = player.y - (dim * 0.5) - camTopLeft.y + camera.state.y_offset

		rl.DrawRectangleRec(
			rect,
			{0, u8((player.x / 800.0) * 255.0), u8((player.y / 600.0) * 255.0), 255},
		)
	}
}
