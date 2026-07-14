package client

import "../camera"
import "../character"
import "../physics"
import "../terrain"
import "../utils"
import "thirdparty:orui"

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

@(private = "file")
entities: [128]character.Entity

@(private)
generateEntities :: proc() {
	// player animation
	entities[0].pos.x = rand.float32() * camera.state.cs * utils.MAP_SIZE
	entities[0].pos.y = rand.float32() * camera.state.cs * utils.MAP_SIZE

	entities[0].skin = player_skin
	entities[0].animation.flip_x = 1

	character.changeAnimation(&entities[0], .IDLE)

	// player physics
	playerBody := box2d.DefaultBodyDef()
	playerBody.position = {
		entities[0].pos.x / camera.state.cs,
		entities[0].pos.y / camera.state.cs,
	}
	playerBody.type = .dynamicBody
	playerBody.fixedRotation = true
	playerBody.linearDamping = 10

	entities[0].physics_id = box2d.CreateBody(physics.phyWorld, playerBody)

	playerBox := box2d.MakeRoundedBox(0.2, 0.08, 0.1)
	playerShapeDef := box2d.DefaultShapeDef()
	_ = box2d.CreatePolygonShape(entities[0].physics_id, playerShapeDef, playerBox)

	// playerSensorBox := box2d.MakeOffsetRoundedBox(0.2, 0.6, {0, -0.65}, {c = 1, s = 0}, 0.2)
	playerSensorBox := box2d.MakeOffsetBox(0.3, 0.7, {0, -0.75}, {c = 1, s = 0})
	playerSensorShapeDef := box2d.DefaultShapeDef()
	playerSensorShapeDef.density = 0
	playerSensorShapeDef.isSensor = true
	playerSensorShapeDef.enableSensorEvents = true
	_ = box2d.CreatePolygonShape(entities[0].physics_id, playerSensorShapeDef, playerSensorBox)

	for i in 1 ..< 128 {
		// enemy animation
		entities[i].pos.x = rand.float32() * camera.state.cs * utils.MAP_SIZE
		entities[i].pos.y = rand.float32() * camera.state.cs * utils.MAP_SIZE

		character.randomSkin(&entities[i].skin)

		entities[i].animation.flip_x = 1
		character.changeAnimation(&entities[i], .IDLE)

		// enemy physics
		enemyBody := box2d.DefaultBodyDef()
		enemyBody.position = {
			entities[i].pos.x / camera.state.cs,
			entities[i].pos.y / camera.state.cs,
		}
		enemyBody.type = .dynamicBody
		enemyBody.fixedRotation = true
		enemyBody.linearDamping = 10

		entities[i].physics_id = box2d.CreateBody(physics.phyWorld, enemyBody)

		enemyBox := box2d.MakeRoundedBox(0.2, 0.08, 0.1)
		enemyShapeDef := box2d.DefaultShapeDef()
		_ = box2d.CreatePolygonShape(entities[i].physics_id, enemyShapeDef, enemyBox)

		enemySensorBox := box2d.MakeOffsetBox(0.4, 0.75, {0, -0.75}, {c = 1, s = 0})
		enemySensorShapeDef := box2d.DefaultShapeDef()
		enemySensorShapeDef.density = 0
		enemySensorShapeDef.isSensor = true
		enemySensorShapeDef.enableSensorEvents = true
		_ = box2d.CreatePolygonShape(entities[i].physics_id, enemySensorShapeDef, enemySensorBox)
	}
}

@(private)
getPlayer :: proc() -> character.Entity {
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
	box2d.DestroyBody(entities[0].physics_id)
	physics.closePhysics()
}

@(private = "file")
on_update :: proc(dt: f32) {
	physics.physicsTick()

	body_pos := box2d.Body_GetPosition(entities[0].physics_id)
	entities[0].pos = {body_pos.x * camera.state.cs, body_pos.y * camera.state.cs}
	// entities[0].pos = {body_pos.x, body_pos.y}

	// fmt.println(body_pos)
	// fmt.println(entities[0].pos)

	camera.update()

	if rl.IsWindowResized() {
		w := rl.GetRenderWidth()
		h := rl.GetRenderHeight()
		camera.sizeUpdate(w, h)
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

	// box2d.Body_SetLinearVelocity(entities[0].physics_id, force)
	box2d.Body_ApplyForceToCenter(entities[0].physics_id, force, true)

	if x_axis != 0 || y_axis != 0 {
		camera.startTagAlong(entities[0].pos)

		player := &entities[0]

		if player.animation.current_animation != .RUNNING {
			character.changeAnimation(player, .RUNNING)
		}

		if x_axis < 0 {
			player.animation.flip_x = -1
		} else if x_axis > 0 {
			player.animation.flip_x = 1
		}

	} else {
		character.changeAnimation(&entities[0], .IDLE)
	}

	if rl.IsKeyPressed(.R) {
		draw_physics = !draw_physics
	}

	clearId()
}

@(private = "file")
draw_physics := false

@(private = "file")
on_render :: proc() {
	rl.ClearBackground({2, 5, 17, 255})

	{orui.container(orui.id(getId()), {width = orui.grow(), height = orui.grow()})
		{orui.container(orui.id(getId()), {width = orui.grow()})}

		if orui.label(
			orui.id(getId()),
			"\u0078",
			{
				width = orui.fixed(40),
				height = orui.fixed(40),
				align = {.Center, .Center},
				font = utils.getIconFont(),
				font_size = 30,
				color = rl.BLACK,
				background_color = CYAN,
				border = getBorder(),
				border_color = rl.BLACK,
				corner_radius = orui.corner(10),
				margin = orui.margin(10),
			},
		) {
			changeState(&end_screen_state)
		}
	}

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
		char_rekt := rl.Rectangle {
			x      = entities[i].pos.x - camTopLeft.x + camera.state.x_offset - cs,
			y      = entities[i].pos.y - camTopLeft.y + camera.state.y_offset - cs,
			width  = cs * 2,
			height = cs * 3,
		}

		if !rl.CheckCollisionRecs(rekt, char_rekt) do continue

		character.drawAnimate(&entities[i], camTopLeft)
	}

	if draw_physics {
		physics.drawPhysics()
	}

	rl.EndScissorMode()
}
