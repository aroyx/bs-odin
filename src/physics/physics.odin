package physics

import "thirdparty:tracy"
import "vendor:box2d"

import "../utils"

phyWorld: box2d.WorldId = {}

initPhysics :: proc() {
	_phyWorld := box2d.DefaultWorldDef()
	_phyWorld.gravity = {0, 0} //ours is a top down, also we just use physics for collision detection!
	_phyWorld.enableSleep = true

	phyWorld = box2d.CreateWorld(_phyWorld)

	debug_draw := box2d.DefaultDebugDraw()
	initDebugDraw()

	{
		generateIslands()
		pushIslandsToPhysics()
		createBoundary()
	}
}

physicsTick :: proc() {
	tracy.ZoneN("Box2d Tick")
	timestep: f32 : 1.0 / 60.0
	subStepCount: i32 : 4
	box2d.World_Step(phyWorld, timestep, subStepCount)
}

closePhysics :: proc() {
	box2d.DestroyWorld(phyWorld)
}

@(private = "file")
createBoundary :: proc() {
	x: f32 = utils.MAP_SIZE
	y: f32 = utils.MAP_SIZE

	points: [4]box2d.Vec2 = {{0, 0}, {0, y}, {x, y}, {x, 0}}

	boundaryBody := box2d.DefaultBodyDef()
	boundaryBody.type = .staticBody
	boundaryId := box2d.CreateBody(phyWorld, boundaryBody)

	boundaryChainDef := box2d.DefaultChainDef()
	boundaryChainDef.count = 4
	boundaryChainDef.points = &points[0]
	boundaryChainDef.isLoop = true

	_ = box2d.CreateChain(boundaryId, boundaryChainDef)
}
