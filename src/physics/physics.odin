package physics

import "thirdparty:tracy"
import "vendor:box2d"

import "../camera"

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
	}
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
