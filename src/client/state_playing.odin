package client

import "../camera"
import "../physics"
import "../terrain"
import "../types"
import "../utils"
import "core:math/rand"

import "core:math"
import "core:math/linalg"

import rl "vendor:raylib"

playing_state: ClientState = {
	on_enter  = on_enter,
	on_exit   = on_exit,
	// on_network_event = on_network_event,
	on_update = on_update,
	on_render = on_render,
}

@(private = "file")
lock_camera := false

Entity :: struct {
	pos: linalg.Vector2f32,
	col: rl.Color,
}

@(private = "file")
entities: [128]Entity

@(private)
generateEntities :: proc() {
	for i in 0 ..< 128 {
		entities[i].pos.x = rand.float32() * camera.state.cs * utils.MAP_SIZE
		entities[i].pos.y = rand.float32() * camera.state.cs * utils.MAP_SIZE

		entities[i].col = {u8(rand.int31()), u8(rand.int31()), u8(rand.int31()), 255}
	}
}

@(private)
getPlayer :: proc() -> Entity {
    return entities[0]
}

@(private = "file")
on_enter :: proc() {
}

@(private = "file")
on_exit :: proc() {
	rl.SetExitKey(.ESCAPE)
	terrain.destroyChunks()
	physics.closePhysics()
}

// @(private = "file")
// on_network_event :: proc(pEvent: network.ReceivedStruct) {
// 	#partial switch packet in pEvent {
// 	case types.ServerOutput:
// 		global.render_state = packet
// 		updatePlayerPos()
//
// 		if !lock_camera {
// 			camera.StartTagAlong(gPlayer.pos)
// 			lock_camera = true
// 		}
// 	case types.MatchStartOutput:
// 		fmt.println("match really started nw")
// 	// do smth idk
// 	}
// }

@(private = "file")
on_update :: proc(dt: f32) {
	physics.physicsTick()

	camera.Update()
	// sendInputsToServer()

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

	if x_axis != 0 || y_axis != 0 {
		speed: f32 = 5.0
		entities[0].pos.x += x_axis * speed
		entities[0].pos.y += y_axis * speed
		camera.StartTagAlong(entities[0].pos)
	}

	if rl.IsKeyPressed(.R) {
		draw_physics = !draw_physics
	} else if rl.IsKeyPressed(.Q) {
		changeState(&end_screen_state)
	}

}

@(private = "file")
draw_physics := false

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
			cs * (utils.MAP_SIZE - camera.state.hcc),
		),
		math.clamp(
			cp.y - (cs * camera.state.vcc * 0.5),
			0,
			cs * (utils.MAP_SIZE - camera.state.vcc),
		),
	}

	rekt: rl.Rectangle = {
		height = camera.state.cs * camera.state.vcc,
		width  = camera.state.cs * camera.state.hcc,
		x      = camera.state.x_offset,
		y      = camera.state.y_offset,
	}
	rl.BeginScissorMode(i32(rekt.x), i32(rekt.y), i32(rekt.width), i32(rekt.height))

	for i in 0 ..< len(entities) {
		player := entities[i]
		rect: rl.Rectangle

		dim :: 30
		rect.height = dim
		rect.width = dim
		rect.x = player.pos.x - (dim * 0.5) - camTopLeft.x + camera.state.x_offset
		rect.y = player.pos.y - (dim * 0.5) - camTopLeft.y + camera.state.y_offset

		rl.DrawRectangleRec(rect, player.col)
	}

	if draw_physics { 	// due to me using rl.Camera in drawPhysics, I can't clip it. It is not a feature to be used by players so idk, whatever
		physics.drawPhysics()
	}

	rl.EndScissorMode()
}
