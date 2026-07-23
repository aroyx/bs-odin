package playing

import hm "core:container/handle_map"
import "core:math/linalg"
import "core:math/rand"

import "../camera"
import "../physics"
import "../terrain"
import "../utils"

import "vendor:box2d"
import "vendor:raylib"

Entity :: struct {
	handle:     EntityHandle,
	pos:        linalg.Vector2f32,
	physics_id: box2d.BodyId,
	data:       EntityData,
	health:     f32,
}

EntityHandle :: distinct hm.Handle32

MAX_ENTITIES :: 1024

@(private)
entities: hm.Static_Handle_Map(MAX_ENTITIES, Entity, EntityHandle)

@(private)
render_list: [MAX_ENTITIES]EntityHandle

@(private)
entity_count: int

@(private)
player_handle: EntityHandle

EntityData :: union {
	PlayerData,
	EnemyData,
	FoliageData,
}

PlayerData :: struct {
	state:           PlayerState,
	skin:            CharacterSkin,
	animation:       AnimationState,
	attack_cooldown: f32,
	stun_cooldown:   f32,
}

PlayerState :: enum u8 {
	IDLE,
	WALK,
	RUN,
	JUMP,
	ATTACK,
	HURT,
	DEAD,
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
	image: raylib.Texture,
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
		entity.pos = box2d.Body_GetPosition(entity.physics_id) * camera.state.cs
	}
}

@(private)
sortEntitiesYaxis :: proc() {
	// since the renderlist is already "almost" sorted, insertion sort will work the best in theory
	// https://stackoverflow.com/questions/220044/which-sort-algorithm-works-best-on-mostly-sorted-data
	for i in 1 ..< entity_count {
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
	playerBody.position = {player_pos.x / camera.state.cs, player_pos.y / camera.state.cs}
	playerBody.type = .dynamicBody
	playerBody.fixedRotation = true
	playerBody.linearDamping = 10

	player_physics_id := box2d.CreateBody(physics.phyWorld, playerBody)

	playerBox := box2d.MakeRoundedBox(0.2, 0.08, 0.1)
	playerShapeDef := box2d.DefaultShapeDef()
	_ = box2d.CreatePolygonShape(player_physics_id, playerShapeDef, playerBox)

	p_entity := Entity {
		pos        = player_pos,
		data       = player_data,
		physics_id = player_physics_id,
		health     = 100,
	}

	player_handle = addEntity(p_entity)

	for i in 1 ..< 127 {
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
		_ = box2d.CreatePolygonShape(e_phy_id, enemyShapeDef, enemyBox)

		e_entity := Entity {
			pos        = e_pos,
			data       = e_data,
			physics_id = e_phy_id,
			health     = 100,
		}

		addEntity(e_entity)
	}
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

addEntity :: proc(entity: Entity) -> EntityHandle {
	handle := hm.add(&entities, entity)

	if entity_count < MAX_ENTITIES {
		render_list[entity_count] = handle
		entity_count += 1
	}

	return handle
}

removeEntity :: proc(handle: EntityHandle) -> bool {
	if !hm.remove(&entities, handle) {
		return false
	}

	for i in 0 ..< entity_count {
		if render_list[i] != handle do continue

		for j in i ..< entity_count {
			render_list[j] = render_list[j + 1]
		}

		entity_count -= 1
		break
	}

	return true
}
