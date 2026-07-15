package playing

import "../camera"
import "../physics"
import "../terrain"
import "../utils"

import "core:math"
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

	for i in render_list {
		pos := entities.pos[i]

		char_rekt := rl.Rectangle {
			x      = pos.x - camTopLeft.x + camera.state.x_offset - cs,
			y      = pos.y - camTopLeft.y + camera.state.y_offset - cs * 1.5,
			width  = cs * 2,
			height = cs * 3,
		}

		if !rl.CheckCollisionRecs(rekt, char_rekt) do continue

		switch &d in entities.data[i] {
		case EnemyData:
			drawAnimate(&d.animation, &d.skin, pos, camTopLeft)
		case PlayerData:
			drawAnimate(&d.animation, &d.skin, pos, camTopLeft)
		case FoliageData:
		// draw texture only
		}
	}

	if draw_physics {
		physics.drawPhysics()
	}

	rl.EndScissorMode()
}
