package types

// always output the player positions each second
// the user needs to know the map beforehand, if smth happens like wall breaking 
// - we will notify the player about the wall break as a change input, only when applicable

@(private)
buttons :: enum u8 {
	RightClick,
	LeftClick,
	MiddleClick,
}

Button :: bit_set[buttons]

PlayerInput :: struct {
	button: Button,
	id:     u32,
	x_axis: f32,
	y_axis: f32,
}

ServerOutput :: struct {
	x:  f32,
	y:  f32,
	id: u32,
}

ServerOutputs: [dynamic]ServerOutput
