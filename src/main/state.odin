package client

import "core:fmt"

client_state: ^ClientState

ClientState :: struct {
	on_enter:  proc(),
	on_exit:   proc(),
	on_update: proc(dt: f32),
	on_render: proc(),
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
