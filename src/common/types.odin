package types

PacketType :: enum u8 {
	NEW_JOIN,
	PLAYER_INPUT,
	SERVER_OUTPUT,
}

NewJoin :: struct {
	type: PacketType,
	id:   uintptr,
}

PlayerInput :: struct {
	type:   PacketType,
	x_axis: f32,
	y_axis: f32,
}

PlayerState :: struct {
	id:   uintptr,
	x:    f32,
	y:    f32,
}

MAX_PLAYERS :: 2
ServerOutput :: struct {
    type: PacketType,
    player_count: u8,
	states: [MAX_PLAYERS]PlayerState,
}
