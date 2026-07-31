package playing

import anim "../animations"
import "../camera"
import "../physics"
import "../terrain"
import "../utils"

import hm "core:container/handle_map"
import "core:math"
import "core:math/ease"
import "core:math/linalg"

import "thirdparty:orui"
import "thirdparty:tracy"
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
	loadFoliage()

	attack_button_data.texture = anim.getPartTex(
		player_skin.type[.WEAPON],
		player_skin.tier[.WEAPON],
		.WEAPON,
	)
}

exit :: proc() {
	rl.UnloadTexture(rotate_phone_texture)
	terrain.destroyChunks()
	box2d.DestroyBody(hm.get(&entities, player_handle).physics_id)
	physics.closePhysics()
	unloadSounds()

	unLoadFoliage()

	hm.dynamic_destroy(&entities)
	clear(&render_list)
}

update :: proc(dt: f32) {
	physics.physicsTick()

	camera.update()

	if rl.IsWindowResized() {
		w := rl.GetRenderWidth()
		h := rl.GetRenderHeight()
		camera.sizeUpdate(w, h)
		terrain.generateRenderChunks()
		camera.startTagAlong(hm.get(&entities, player_handle).pos)
	}

	p_entity := hm.get(&entities, player_handle)
	p_pos := p_entity.pos

	it := hm.iterator_make(&entities)

	for e, handle in hm.iterate(&it) {
		switch &entity in &e.data {
		case EnemyData:
			enemyStateMachineUpdate(e, dt, p_pos)
		case PlayerData:
			playerStateMachineUpdate(dt)
		case FoliageData:
			foliageStateMachineUpdate(e, handle, dt)
		}
	}

	updateFoliage()

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

	tracy.ZoneN("Render Entities")
	p_entity := hm.get(&entities, player_handle)
	p_pos := p_entity.pos

	// for e, handle in hm.iterate(&it) {
	for i in 0 ..< len(render_list) {
		handle := render_list[i]

		e, ok := hm.get(&entities, handle)

		if !ok do continue

		pos := e.pos

		w := e.size.x * camera.state.cs
		h := e.size.y * camera.state.cs

		bounding_box := rl.Rectangle {
			x      = pos.x - camTopLeft.x + camera.state.x_offset - (w / 2),
			y      = pos.y - camTopLeft.y + camera.state.y_offset - h,
			width  = w,
			height = h,
		}

		if !rl.CheckCollisionRecs(rekt, bounding_box) do continue

		health := e.health

		switch &d in e.data {
		case EnemyData:
			drawAnimate(&d.animation, &d.skin, pos, camTopLeft)
			renderHealthBar(health, e.id, pos, camTopLeft, R1, R2)
		case PlayerData:
			drawAnimate(&d.animation, &d.skin, pos, camTopLeft)
			renderHealthBar(health, e.id, pos, camTopLeft, G1, G2)
		case FoliageData:
			drawFoliage(&d, pos, camTopLeft, p_pos, bounding_box)
		}
	}

	if draw_physics {
		physics.drawPhysics()
	}

	rl.EndScissorMode()
}

renderUI :: proc() -> bool {
	return drawControls()
}

@(private = "file")
renderHealthBar :: proc(health: f32, id: int, pos, camTopLeft: [2]f32, color1, color2: rl.Color) {
	if health <= 0 do return

	cs := camera.state.cs
	draw_x := pos.x - camTopLeft.x + camera.state.x_offset
	draw_y := pos.y - camTopLeft.y + camera.state.y_offset + (cs * 0.25)

	max_w := cs * 2
	h := max(cs / 3, 8)

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

@(private = "file")
drawFoliage :: proc(
	data: ^FoliageData,
	pos, camTopLeft, p_pos: [2]f32,
	bounding_box: rl.Rectangle,
) {
	tex := foliage_textures[data.plant_type]

	if tex.id == 0 do return

	cs := camera.state.cs
	tex_w, tex_h := f32(tex.width), f32(tex.height)

	draw_x := pos.x - camTopLeft.x + camera.state.x_offset
	draw_y := pos.y - camTopLeft.y + camera.state.y_offset

	scale := cs * 0.015

	offset_y := 0.08 * cs * 4.0
	x := draw_x - (tex_w * scale * 0.5)
	y := draw_y - (tex_h * scale) + offset_y

	if !data.is_dying {
		p_pos_screen :[2]f32= {
            p_pos.x - camTopLeft.x + camera.state.x_offset, 
            p_pos.y - camTopLeft.y + camera.state.y_offset, 
        }

		if rl.CheckCollisionPointRec(p_pos_screen, bounding_box) {
			data.alpha = 150
		} else {
			data.alpha = 255
		}
	}

	rl.DrawTextureEx(tex, {x, y}, 0.0, scale, {255, 255, 255, data.alpha})
}
