package playing

import "../camera"
import "../physics"
import "../terrain"
import "../utils"
import "thirdparty:orui"

import "core:math"
import "core:math/ease"
import "core:math/linalg"

import "vendor:box2d"
import rl "vendor:raylib"

@(private = "file")
lock_camera := false

player_skin: CharacterSkin

@(private = "file")
rotate_phone_texture: rl.Texture

enter :: proc() {
	rotate_phone_img := rl.LoadImage("res/images/rotate_phone.png")

	rotate_phone_texture = rl.LoadTextureFromImage(rotate_phone_img)
	rl.SetTextureFilter(rotate_phone_texture, .BILINEAR)

	rl.UnloadImage(rotate_phone_img)
}

exit :: proc() {
	rl.UnloadTexture(rotate_phone_texture)
	terrain.destroyChunks()
	box2d.DestroyBody(entities.physics_id[0])
	physics.closePhysics()
}

update :: proc(dt: f32) {
	physics.physicsTick()

	camera.update()

	if rl.IsWindowResized() {
		w := rl.GetRenderWidth()
		h := rl.GetRenderHeight()
		camera.sizeUpdate(w, h)
		terrain.generateRenderChunks()
		camera.startTagAlong(entities[0].pos)
	}

	playerStateMachineUpdate(dt)
	enemyStateMachineUpdate(dt)

	updateEntitiesPosition()
	sortEntitiesYaxis()

	if rl.IsKeyPressed(.R) {
		draw_physics = !draw_physics
	}
}

@(private = "file")
draw_physics := false

render :: proc() {
	win_w, win_h := f32(rl.GetRenderWidth()), f32(rl.GetRenderHeight())
	if utils.global.options.on_mobile && win_w / win_h < 1.0 { 	// in potrait mode
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

	R1 := rl.Color{240, 113, 103, 100}
	R2 := rl.ColorLerp(R1, rl.BLACK, 0.1)
	G1 := rl.Color{0, 210, 210, 100}
	G2 := rl.ColorLerp(G1, rl.BLACK, 0.1)

	for i in render_list {
		pos := entities.pos[i]

		char_rekt := rl.Rectangle {
			x      = pos.x - camTopLeft.x + camera.state.x_offset - cs,
			y      = pos.y - camTopLeft.y + camera.state.y_offset - cs * 1.5,
			width  = cs * 2,
			height = cs * 3,
		}

		if !rl.CheckCollisionRecs(rekt, char_rekt) do continue

		health := entities[i].health.health

		switch &d in entities.data[i] {
		case EnemyData:
			drawAnimate(&d.animation, &d.skin, pos, camTopLeft)
			renderHealthBar(health, i, pos, camTopLeft, R1, R2)
		case PlayerData:
			drawAnimate(&d.animation, &d.skin, pos, camTopLeft)
			renderHealthBar(health, i, pos, camTopLeft, G1, G2)
		case FoliageData:
		// draw texture only
		}

	}

	if draw_physics {
		physics.drawPhysics()
	}

	rl.EndScissorMode()
}

@(private = "file")
renderHealthBar :: proc(health: f32, id: int, pos, camTopLeft: [2]f32, color1, color2: rl.Color) {
	if health <= 0 do return

	cs := camera.state.cs
	draw_x := pos.x - camTopLeft.x + camera.state.x_offset
	draw_y := pos.y - camTopLeft.y + camera.state.y_offset + (cs * 0.25)

	max_w := cs * 2
	h := cs / 3

	x := draw_x - (max_w * 0.5)
	y := draw_y - (cs * 3)

	BORDER :: 2

	{orui.container(
			orui.id("health", id),
			{
				position = {type = .Fixed, value = {x, y}},
				width = orui.fixed(max_w),
				height = orui.fixed(h),
				background_color = rl.WHITE,
				border = orui.border(BORDER),
				border_color = rl.BLACK,
				corner_radius = orui.corner(cs / 3),
				layout = .None,
			},
		)

		percent := math.saturate(health / 100)

		{
			orui.container(
				orui.id("insta", id),
				{
					position = {type = .Absolute, value = {BORDER, BORDER}},
					width = orui.percent(percent),
					height = orui.percent(1),
					background_color = color2,
					corner_radius = orui.corner(cs / 3),
				},
			)
		}

		{
			orui.container(
				orui.id("smoth", id),
				{
					position = {type = .Absolute, value = {BORDER, BORDER}},
					width = orui.percent(orui.animate("w", percent, 0.5, ease.Ease.Cubic_In)),
					height = orui.percent(1),
					background_color = color1,
					corner_radius = orui.corner(cs / 3),
				},
			)
		}
	}
}
