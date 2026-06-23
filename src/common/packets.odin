package common

PacketType :: enum u8 {
	NEW_JOIN,
	PLAYER_INPUT,
	SERVER_OUTPUT,
	MATCH_MAKING_OUTPUT,
	COUNTDOWN_OUTPUT,
	MATCH_START,
	PING,
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

ServerOutput :: struct {
	type:         PacketType,
	player_count: u8,
	states:       [MAX_PLAYERS]PlayerState,
}

MatchMakingOutput :: struct {
	type:         PacketType,
	player_count: u8,
}

CountDownOutput :: struct {
	type: PacketType,
	time: u8,
	show: bool, // if false, someone left the game and client should stop the countdown
}

MatchStartOutput :: struct {
	type: PacketType,
}

Ping :: struct {
    type: PacketType,
}
