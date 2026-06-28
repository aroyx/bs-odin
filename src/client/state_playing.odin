package client

import "core:fmt"
import "../camera"
import "../network"
import "../terrain"
import "../types"

import "core:math"
import "core:math/linalg"

import rl "vendor:raylib"

playing_state: ClientState = {
	on_enter         = on_enter,
	on_exit          = on_exit,
	on_network_event = on_network_event,
	on_update        = on_update,
	on_render        = on_render,
}

@(private = "file")
lock_camera := false

@(private = "file")
on_enter :: proc() {
	rl.SetExitKey(.KEY_NULL) // whatif they prees accidentially while parkouring?

	w := rl.GetScreenWidth()
	h := rl.GetScreenHeight()
	camera.Init(w, h, terrain.MAP_SIZE)
	lock_camera = false

	terrain.createTerrain()
	ready: types.ClientReady = {
		type = .CLIENT_READY,
	}
	network.Send(&ready, size_of(ready), true)
}

@(private = "file")
on_exit :: proc() {
	rl.SetExitKey(.ESCAPE)
	terrain.destroyChunks()
}

@(private = "file")
on_network_event :: proc(pEvent: network.ReceivedStruct) {
	#partial switch packet in pEvent {
	case types.ServerOutput:
		global.render_state = packet
		updatePlayerPos()

		if !lock_camera {
			camera.StartTagAlong(gPlayer.pos)
			lock_camera = true
		}
	case types.MatchStartOutput:
        fmt.println("match really started nw")
	// do smth idk
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
		terrain.generateRenderChunks()
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

	terrain.renderTerrain()

	cs := camera.state.cs
	cp := camera.camPos

	camTopLeft: linalg.Vector2f32 = {
		math.clamp(
			cp.x - (cs * camera.state.hcc * 0.5),
			0,
			cs * (terrain.MAP_SIZE - camera.state.hcc),
		),
		math.clamp(
			cp.y - (cs * camera.state.vcc * 0.5),
			0,
			cs * (terrain.MAP_SIZE - camera.state.vcc),
		),
	}

	for i in 0 ..< global.render_state.player_count {
		player := global.render_state.states[i]
		rect: rl.Rectangle

		dim :: 30
		rect.height = dim
		rect.width = dim
		rect.x = player.pos.x - (dim * 0.5) - camTopLeft.x + camera.state.x_offset
		rect.y = player.pos.y - (dim * 0.5) - camTopLeft.y + camera.state.y_offset

		rl.DrawRectangleRec(
			rect,
			{0, u8((player.pos.x / 800.0) * 255.0), u8((player.pos.y / 600.0) * 255.0), 255},
		)
	}
}
