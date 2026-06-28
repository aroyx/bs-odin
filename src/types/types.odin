package type

import "core:math/linalg"

PlayerState :: struct {
	id: uintptr,
	pos: linalg.Vector2f32,
}

MAX_PLAYERS :: 2
