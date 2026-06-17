package client

import "core:encoding/ini"
import "core:fmt"
import "core:strconv"
import "core:strings"
import "src:common"

ClientState :: enum u8 {
	MAIN_MENU,
	MATCH_MAKING,
	PLAYING,
	END_SCREEN,
}

// MatchMakingState :: enum u8 {
// 	CONNECTING_PLAYERS,
// 	GAME_START_COUNTDOWN,
// }

GlobalState :: struct {
	quit:         bool,
	net:          Network,
	time:         Time,
	input:        common.PlayerInput,
	client_state: ClientState,
	render_state: common.ServerOutput,
}

Time :: struct {
	fps:        f64,
	frame_time: f64,
	dt:         f64,
	show_fps:   bool,
	countdown:  common.CountDownOutput,
}

Network :: struct {
	port: u16,
	host: cstring,
}

global: GlobalState = {}

stateInit :: proc() -> bool {
	global.quit = false
	global.time.show_fps = true
	global.client_state = .MAIN_MENU
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

	return true
}
