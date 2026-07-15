package playing

import "core:math/linalg"
import "core:math/rand"

import "../camera"
import "../physics"
import "../terrain"
import "../utils"

import "vendor:box2d"
import "vendor:raylib"

@(private)
entities: #soa[128]Entity

@(private)
render_list: [len(entities)]int

Entity :: struct {
	pos:        linalg.Vector2f32,
	physics_id: box2d.BodyId,
	data:       EntityData,
	health:     Health,
}

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

newdata :: distinct PlayerData

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
	state:     EnemyState,
	skin:      CharacterSkin,
	animation: AnimationState,
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

Health :: struct {
	health: f32,
	// regenerate: HealthRegenerate,
}

// HealthRegenerate :: union {
// 	NoRegenerate,
// 	YesRegenerate,
// }

// NoRegenerate :: struct {}
// YesRegenerate :: struct {
// 	wait_for: f32, // time to rest before can regenerate
// }

updateEntitiesPosition :: proc() {
	for i in 0 ..< len(entities) {
		id := entities.physics_id[i]
		pos := &entities.pos[i]
		body_pos := box2d.Body_GetPosition(id)
		pos^ = {body_pos.x * camera.state.cs, body_pos.y * camera.state.cs}
	}
}

@(private)
sortEntitiesYaxis :: proc() {
	// since the renderlist is already "almost" sorted, insertion sort will work the best in theory
	// https://stackoverflow.com/questions/220044/which-sort-algorithm-works-best-on-mostly-sorted-data
	for i in 1 ..< len(render_list) {
		key_index := render_list[i]
		key_y := entities.pos[key_index].y
		j := i - 1

		for j >= 0 && entities.pos[render_list[j]].y > key_y {
			render_list[j + 1] = render_list[j]
			j -= 1
		}

		render_list[j + 1] = key_index
	}

	// slice.sort_by(render_list[:], proc(i, j: ^character.Entity) -> bool {
	// 	return i.pos.y < j.pos.y
	// })
}

generateEntities :: proc() {
	// player animation
	entities.pos[0] = getRandomLandPosition()
	entities.health[0] = {
		health = 100,
	}

	pData := PlayerData {
		skin = player_skin,
		state = .IDLE,
		animation = {flip_x = 1},
	}

	changeAnimation(&pData.animation, .IDLE)

	entities.data[0] = pData

	// player physics
	playerBody := box2d.DefaultBodyDef()
	playerBody.position = {
		entities.pos[0].x / camera.state.cs,
		entities.pos[0].y / camera.state.cs,
	}
	playerBody.type = .dynamicBody
	playerBody.fixedRotation = true
	playerBody.linearDamping = 10

	entities.physics_id[0] = box2d.CreateBody(physics.phyWorld, playerBody)

	playerBox := box2d.MakeRoundedBox(0.2, 0.08, 0.1)
	playerShapeDef := box2d.DefaultShapeDef()
	_ = box2d.CreatePolygonShape(entities.physics_id[0], playerShapeDef, playerBox)

	// playerSensorBox := box2d.MakeOffsetRoundedBox(0.2, 0.6, {0, -0.65}, {c = 1, s = 0}, 0.2)
	playerSensorBox := box2d.MakeOffsetBox(0.3, 0.7, {0, -0.75}, {c = 1, s = 0})
	playerSensorShapeDef := box2d.DefaultShapeDef()
	playerSensorShapeDef.density = 0
	playerSensorShapeDef.isSensor = true
	playerSensorShapeDef.enableSensorEvents = true
	_ = box2d.CreatePolygonShape(entities.physics_id[0], playerSensorShapeDef, playerSensorBox)

	for i in 1 ..< len(entities) {
		// enemy animation
		entities.pos[i] = getRandomLandPosition()
		entities.health[0] = {
			health = 100,
		}

		eData := EnemyData {
			state = .ROAM,
			animation = {flip_x = 1},
		}

		randomSkin(&eData.skin)
		changeAnimation(&eData.animation, .IDLE)

		entities.data[i] = eData

		// enemy physics
		enemyBody := box2d.DefaultBodyDef()
		enemyBody.position = {
			entities.pos[i].x / camera.state.cs,
			entities.pos[i].y / camera.state.cs,
		}
		enemyBody.type = .dynamicBody
		enemyBody.fixedRotation = true
		enemyBody.linearDamping = 10

		entities.physics_id[i] = box2d.CreateBody(physics.phyWorld, enemyBody)

		enemyBox := box2d.MakeRoundedBox(0.2, 0.08, 0.1)
		enemyShapeDef := box2d.DefaultShapeDef()
		_ = box2d.CreatePolygonShape(entities.physics_id[i], enemyShapeDef, enemyBox)

		enemySensorBox := box2d.MakeOffsetBox(0.4, 0.75, {0, -0.75}, {c = 1, s = 0})
		enemySensorShapeDef := box2d.DefaultShapeDef()
		enemySensorShapeDef.density = 0
		enemySensorShapeDef.isSensor = true
		enemySensorShapeDef.enableSensorEvents = true
		_ = box2d.CreatePolygonShape(entities.physics_id[i], enemySensorShapeDef, enemySensorBox)
	}

	for i in 0 ..< len(entities) {
		render_list[i] = i
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
	return entities[0]
}
