package physics

import "core:fmt"
import "thirdparty:tracy"
import "vendor:box2d"

import "../camera"

phyWorld: box2d.WorldId = {}

initPhysics :: proc() {
	_phyWorld := box2d.DefaultWorldDef()
	_phyWorld.gravity = {0, -10.} //ours is a top down, also we just use physics for collision detection!
	_phyWorld.enableSleep = true

	debug_draw := box2d.DefaultDebugDraw()

	phyWorld = box2d.CreateWorld(_phyWorld)

	groundBodyDef := box2d.DefaultBodyDef()
	groundBodyDef.position = {50.0, -50.0}

	groundId := box2d.CreateBody(phyWorld, groundBodyDef)

	groundBox := box2d.MakeBox(50.0, 10.0)
	groundShapeDef := box2d.DefaultShapeDef()
	id := box2d.CreatePolygonShape(groundId, groundShapeDef, groundBox)

	for i in 0 ..< 8 {
		bodyDef := box2d.DefaultBodyDef()
		bodyDef.type = box2d.BodyType.dynamicBody
		bodyDef.position = {11.0 * f32(i), 4.0}
		bodyDef.name = fmt.ctprintf("Box%d", i)
		bodyId := box2d.CreateBody(phyWorld, bodyDef)

		// dynamicBox := box2d.MakeRoundedBox(1.0, 1.0, 5.0)
		// dynamicBox := box2d.MakeBox(4.0, 4.0)
		dynamicBox := box2d.Capsule {
			center1 = {0, 0},
			center2 = {2, 4},
			radius  = 2,
		}

		shapeDef := box2d.DefaultShapeDef()
		shapeDef.density = 1.0
		shapeDef.material.friction = 0.3
		shapeDef.material.restitution = 0.5

		id := box2d.CreateCapsuleShape(bodyId, shapeDef, dynamicBox)
		// i := box2d.CreatePolygonShape(bodyId, shapeDef, dynamicBox)
	}

	box2d.SetLengthUnitsPerMeter(camera.state.cs)
	initDebugDraw()
}

physicsTick :: proc() {
	tracy.ZoneN("Box2d Tick")
	timestep: f32 : 1.0 / 60.0
	subStepCount: i32 : 4
	box2d.World_Step(phyWorld, timestep, subStepCount)
	box2d.SetLengthUnitsPerMeter(camera.state.cs)
}

closePhysics :: proc() {
	box2d.DestroyWorld(phyWorld)
}
