package character

import "vendor:box2d"
import "core:math/linalg"

Entity :: struct {
    pos: linalg.Vector2f32,
    physics_id: box2d.BodyId,
    skin: CharacterSkin,
    animation: AnimationState,
}
