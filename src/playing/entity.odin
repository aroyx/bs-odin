package playing

import hm "core:container/handle_map"
import "core:math/linalg"
import "core:math/rand"

import "../camera"
import "../physics"
import "../terrain"
import "../utils"

import "vendor:box2d"

Entity :: struct {
	handle:     EntityHandle,
	id:         int, // a unique number per entity for animation and shii
	health:     f32,
	pos:        linalg.Vector2f32,
	physics_id: box2d.BodyId,
	data:       EntityData,
	size:       [2]f32,
}

EntityHandle :: distinct hm.Handle32

@(private)
entities: hm.Dynamic_Handle_Map(Entity, EntityHandle)

@(private)
render_list: [dynamic]EntityHandle

@(private)
player_handle: EntityHandle

@(private)
total_enemies := 0

EntityData :: union {
	PlayerData,
	EnemyData,
	FoliageData,
}

PlayerData :: struct {
	state:           PlayerState,
	skin:            CharacterSkin,
	animation:       AnimationState,
	stun_cooldown:   f32,
	attack_cooldown: f32,
	bomb_cooldown: f32,
}

PlayerState :: enum u8 {
	IDLE,
	WALK,
	RUN,
	ATTACK,
	HURT,
	DEAD,
	BOMB_AIM,
	BOMB_THROW,
}

EnemyData :: struct {
	state:           EnemyState,
	skin:            CharacterSkin,
	animation:       AnimationState,
	target_pos:      linalg.Vector2f32,
	attack_landed:   bool,
	target_time:     f32,
	stun_cooldown:   f32,
	attack_cooldown: f32,
}

EnemyState :: enum u8 {
	ROAM,
	CHASE,
	ATTACK,
	HURT,
	DEAD,
}

FoliageData :: struct {
	plant_type: int,
	alpha:      u8,
	is_dying:   bool,
	time_left:  f32,
}

// HealthRegenerate :: union {
// 	NoRegenerate,
// 	YesRegenerate,
// }

// NoRegenerate :: struct {}
// YesRegenerate :: struct {
// 	wait_for: f32, // time to rest before can regenerate
// }

@(private)
updateEntitiesPosition :: proc() {
	it := hm.iterator_make(&entities)

	for entity, handle in hm.iterate(&it) {
		#partial switch type in entity.data {
		case FoliageData:
			continue
		}

		entity.pos = box2d.Body_GetPosition(entity.physics_id) * camera.state.cs
	}
}

@(private)
sortEntitiesYaxis :: proc() {
	// since the renderlist is already "almost" sorted, insertion sort will work the best in theory
	// https://stackoverflow.com/questions/220044/which-sort-algorithm-works-best-on-mostly-sorted-data
	for i in 1 ..< len(render_list) {
		i_handle := render_list[i]
		i_entity := hm.get(&entities, i_handle)
		i_y := i_entity.pos.y

		j := i - 1

		for j >= 0 {
			j_entity := hm.get(&entities, render_list[j])
			j_y := j_entity.pos.y

			if j_y > i_y {
				render_list[j + 1] = render_list[j]
				j -= 1
			} else {break}
		}

		render_list[j + 1] = i_handle
	}

	// slice.sort_by(render_list[:], proc(i, j: ^character.Entity) -> bool {
	// 	return i.pos.y < j.pos.y
	// })
}

generateEntities :: proc() {
	// player animation
	player_data := PlayerData {
		skin = player_skin,
		state = .IDLE,
		animation = {flip_x = 1},
	}
	changeAnimation(&player_data.animation, .IDLE)

	player_pos := getRandomLandPosition()

	// player physics
	playerBody := box2d.DefaultBodyDef()
	playerBody.position = {player_pos.x / camera.state.cs, (player_pos.y / camera.state.cs) + 0.01}
	playerBody.type = .dynamicBody
	playerBody.fixedRotation = true
	playerBody.linearDamping = 10

	player_physics_id := box2d.CreateBody(physics.phyWorld, playerBody)

	playerBox := box2d.MakeRoundedBox(0.2, 0.08, 0.1)
	playerShapeDef := box2d.DefaultShapeDef()
	_ = box2d.CreatePolygonShape(player_physics_id, playerShapeDef, &playerBox)

	cs := camera.state.cs

	p_entity := Entity {
		pos        = player_pos,
		data       = player_data,
		physics_id = player_physics_id,
		health     = 100,
		size       = {2, 3},
	}

	player_handle = addEntity(&p_entity)

	total_enemies = 0
	for i in 1 ..< 128 {
		// enemy animation
		e_pos := getRandomLandPosition()

		e_data := EnemyData {
			state = .ROAM,
			animation = {flip_x = 1},
		}

		randomSkin(&e_data.skin)
		changeAnimation(&e_data.animation, .IDLE)

		// enemy physics
		enemyBody := box2d.DefaultBodyDef()
		enemyBody.position = {e_pos.x / camera.state.cs, e_pos.y / camera.state.cs}
		enemyBody.type = .dynamicBody
		enemyBody.fixedRotation = true
		enemyBody.linearDamping = 10

		e_phy_id := box2d.CreateBody(physics.phyWorld, enemyBody)

		enemyBox := box2d.MakeRoundedBox(0.2, 0.08, 0.1)
		enemyShapeDef := box2d.DefaultShapeDef()
		_ = box2d.CreatePolygonShape(e_phy_id, enemyShapeDef, &enemyBox)

		e_entity := Entity {
			pos        = e_pos,
			data       = e_data,
			physics_id = e_phy_id,
			health     = 100,
			size       = {2, 3},
		}

		addEntity(&e_entity)
	}

	// foliage for testing purposes
	// for i in 1 ..< 512 {
	// 	f_pos := getRandomLandPosition()
	//
	//        f_data := FoliageData {
	// 		plant_type = .PLANT,
	// 	}
	//
	// 	f_entity := Entity {
	// 		pos        = f_pos,
	// 		data       = f_data,
	// 		physics_id = box2d.BodyId{}, // no physics needed
	// 		health     = 100,
	// 	}
	//
	// 	addEntity(&f_entity)
	// }
}

@(private = "file")
getRandomLandPosition :: proc() -> linalg.Vector2f32 {
	tries := 100

	for i in 0 ..< 100 {
		x := rand.float32() * camera.state.cs * utils.MAP_SIZE
		y := rand.float32() * camera.state.cs * utils.MAP_SIZE

		if terrain.isLand(x, y) {
			return {x, y}
		}
	}

	x := rand.float32() * camera.state.cs * utils.MAP_SIZE
	y := rand.float32() * camera.state.cs * utils.MAP_SIZE
	return {x, y}
}

getPlayer :: proc() -> Entity {
	a, b := hm.get(&entities, player_handle)
	if b do return a^
	else do return {}
}

@(private = "file")
unique_id := 0

addEntity :: proc(entity: ^Entity) -> EntityHandle {
	entity.id = unique_id
	unique_id += 1

	handle := hm.add(&entities, entity^)

	append(&render_list, handle)

	if _, ok := entity.data.(EnemyData); ok {
		total_enemies += 1
	}

	return handle
}

removeEntity :: proc(handle: EntityHandle) -> bool {
	ok, err := hm.remove(&entities, handle)
	if !ok {
		return false
	}

	for i in 0 ..< len(render_list) {
		if render_list[i] == handle {
			unordered_remove(&render_list, i)
			break
		}
	}

	return true
}
