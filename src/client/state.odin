package client

import "core:fmt"
import "core:math/linalg"

global: GlobalState = {
	quit = false,
	options = {show_fps = true, on_mobile = false},
}

input: struct {
	x_axis: f32,
	y_axis: f32,
	mouse:  linalg.Vector2f32,
} = {
	x_axis = 0,
	y_axis = 0,
	mouse  = {},
}

client_state: ^ClientState

GlobalState :: struct {
	quit:    bool,
	options: struct {
		on_mobile: bool,
		show_fps:  bool,
	},
}

ClientState :: struct {
	on_enter:  proc(),
	on_exit:   proc(),
	// on_network_event: proc(event: network.ReceivedStruct),
	on_update: proc(dt: f32),
	on_render: proc(),
}

stateInit :: proc() -> bool {
	changeState(&main_menu_state)

	if client_state != nil && client_state.on_enter != nil {
		client_state.on_enter()
	}

	return true
}

changeState :: proc(new_state: ^ClientState) {
	if client_state == new_state {
		fmt.println("Trying to change to the same state!")
		return
	}

	if client_state != nil && client_state.on_exit != nil {
		client_state.on_exit()
	}
	client_state = new_state

	if client_state != nil && client_state.on_enter != nil {
		client_state.on_enter()
	}
}
