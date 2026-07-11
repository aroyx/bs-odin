package client

import "../camera"
import "../physics"
import "../terrain"
import "../utils"

import "core:math/rand"
import "vendor:box2d"

import "core:math"
import "core:math/linalg"

import rl "vendor:raylib"

playing_state: ClientState = {
	on_enter  = on_enter,
	on_exit   = on_exit,
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

@(private = "file")
playerId: box2d.BodyId

@(private)
generateEntities :: proc() {
	for i in 0 ..< 128 {
		entities[i].pos.x = rand.float32() * camera.state.cs * utils.MAP_SIZE
		entities[i].pos.y = rand.float32() * camera.state.cs * utils.MAP_SIZE

		entities[i].col = {u8(rand.int31()), u8(rand.int31()), u8(rand.int31()), 255}
	}

	playerBody := box2d.DefaultBodyDef()
	playerBody.position = {
		entities[0].pos.x / camera.state.cs,
		entities[0].pos.y / camera.state.cs,
	}
	playerBody.type = .dynamicBody
    playerBody.fixedRotation = true

	playerId = box2d.CreateBody(physics.phyWorld, playerBody)

	playerBox := box2d.MakeRoundedBox(0.5, 0.5, 0.2)
	playerShapeDef := box2d.DefaultShapeDef()

	_ = box2d.CreatePolygonShape(playerId, playerShapeDef, playerBox)
}

@(private)
getPlayer :: proc() -> Entity {
	return entities[0]
}

@(private = "file")
rotate_phone_texture: rl.Texture

@(private = "file")
on_enter :: proc() {
	rotate_phone_img := rl.LoadImage("res/images/rotate_phone.png")

	rotate_phone_texture = rl.LoadTextureFromImage(rotate_phone_img)
	rl.SetTextureFilter(rotate_phone_texture, .BILINEAR)

	rl.UnloadImage(rotate_phone_img)
}

@(private = "file")
on_exit :: proc() {
	rl.UnloadTexture(rotate_phone_texture)
	terrain.destroyChunks()
	box2d.DestroyBody(playerId)
	physics.closePhysics()
}

@(private = "file")
on_update :: proc(dt: f32) {
	physics.physicsTick()

	body_pos := box2d.Body_GetPosition(playerId)
	entities[0].pos = {body_pos.x * camera.state.cs, body_pos.y * camera.state.cs}
	// entities[0].pos = {body_pos.x, body_pos.y}

	// fmt.println(body_pos)
	// fmt.println(entities[0].pos)

	camera.Update()

	if rl.IsWindowResized() {
		w := rl.GetRenderWidth()
		h := rl.GetRenderHeight()
		camera.SizeUpdate(w, h)
		terrain.generateRenderChunks()
	}

	x_axis: f32 = 0
	y_axis: f32 = 0

	if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP) do y_axis = -1
	if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN) do y_axis = 1
	if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT) do x_axis = -1
	if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) do x_axis = 1

	input.x_axis = x_axis
	input.y_axis = y_axis
	input.mouse = {}

	speed: f32 = 10.0
	force: box2d.Vec2 = {x_axis * speed, y_axis * speed}

	box2d.Body_SetLinearVelocity(playerId, force)

	if x_axis != 0 || y_axis != 0 {
		camera.StartTagAlong(entities[0].pos)
	}

	if rl.IsKeyPressed(.R) {
		draw_physics = !draw_physics
	} else if rl.IsKeyPressed(.Q) {
		changeState(&end_screen_state)
	}

	if rl.GuiButton({f32(rl.GetRenderWidth()) - 40, 0, 40, 40}, "#113#") {
		changeState(&end_screen_state)
	}
}

@(private = "file")
draw_physics := false

@(private = "file")
on_render :: proc() {
	rl.ClearBackground({2, 5, 17, 255})

	win_w, win_h := f32(rl.GetRenderWidth()), f32(rl.GetRenderHeight())

	if global.options.on_mobile && win_w / win_h < 1.0 { 	// in potrait mode
		tw, th := f32(rotate_phone_texture.width), f32(rotate_phone_texture.height)

		scale: f32 = math.min(win_w / tw, win_h / th)
		pos := rl.Vector2{(win_w - tw * scale) / 2.0, (win_h - th * scale) / 2.0}

		rl.DrawTextureEx(rotate_phone_texture, pos, 0.0, scale, rl.WHITE)
		return
	}

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
