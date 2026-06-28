package client

import "core:encoding/ini"
import "core:fmt"
import "core:math/linalg"
import "core:strconv"
import "core:strings"

import "../network"
import "../types"

// MatchMakingState :: enum u8 {
// 	CONNECTING_PLAYERS,
// 	GAME_START_COUNTDOWN,
// }

GlobalState :: struct {
	quit:         bool,
	net:          Network,
	time:         Time,
	input:        types.PlayerInput,
	render_state: types.ServerOutput,
}

Time :: struct {
	show_fps:  bool,
	countdown: types.CountDownOutput,
}

Network :: struct {
	port: u16,
	host: cstring,
}

global: GlobalState = {}

gPlayer: types.PlayerState = {}

client_state: ^ClientState

ClientState :: struct {
	on_enter:  proc(),
	on_exit:   proc(),
    on_network_event: proc(event: network.ReceivedStruct),
	on_update: proc(dt: f32),
	on_render: proc(),
}

stateInit :: proc() -> bool {
	global.quit = false
	global.time.show_fps = true
	global.input = {}
	global.render_state = {}
	global.time.countdown = {}

	config, alloc_error := ini.load_map_from_path("config.ini", context.allocator) or_return

	defer ini.delete_map(config)

	if alloc_error != .None {
		fmt.println("Unable to allocate memory!")
		return false
	}

	network := config["network"] or_return
	port := network["port"] or_return
	port_int := strconv.parse_int(port) or_return
	host := network["host"] or_return

	chost := strings.clone_to_cstring(host)

	global.net.host = chost
	global.net.port = u16(port_int)

	changeState(&main_menu_state)

	if client_state != nil && client_state.on_enter != nil {
		client_state.on_enter()
	}

	return true
}

changeState :: proc(new_state: ^ClientState) {
    if client_state == new_state do return

	if client_state != nil && client_state.on_exit != nil {
		client_state.on_exit()
	}
	client_state = new_state

	if client_state != nil && client_state.on_enter != nil {
		client_state.on_enter()
	}
}

updatePlayerPos :: proc() {
	for i in global.render_state.states {
		if i.id == network.GetServerID() {
			gPlayer.pos = {i.pos.x, i.pos.y}
		}
	}
}
