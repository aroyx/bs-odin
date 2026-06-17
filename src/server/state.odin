package server

import "core:strconv"
import "core:fmt"
import "core:encoding/ini"
import "core:math"
import "core:strings"
import "core:time"
import "src:common"

ServerState :: enum u8 {
	MATCH_MAKING,
	COUNTDOWN,
	MATCH_RUNNING,
	MATCH_END,
}

GlobalState :: struct {
	client_id_counter: uintptr,
	server_state:      ServerState,
	players:           map[uintptr]common.PlayerState,
	time:              TimeState,
	net:               Network,
}

TimeState :: struct {
	countdown_time_left: f32,
	last_sec_sent:       u8,
	last_countdown_time: time.Time,
}

Network :: struct {
	port: u16,
	host: cstring,
}

global: GlobalState = {}

defaultState :: proc() -> bool {
	global.server_state = .MATCH_MAKING
	global.client_id_counter = 0
	global.players = make(map[uintptr]common.PlayerState)

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

destroyState :: proc() {
	delete(global.players)
}

startCountdown :: proc() {
	global.server_state = .COUNTDOWN
	global.time.countdown_time_left = 3.0
	global.time.last_sec_sent = 3
	global.time.last_countdown_time = time.now()

	sendCountDown(3)
}

updateCountdown :: proc() {
	if global.server_state != .COUNTDOWN do return

	curr_time := time.now()
	diff := f32(time.duration_seconds(time.diff(global.time.last_countdown_time, curr_time)))

	global.time.last_countdown_time = curr_time
	global.time.countdown_time_left -= diff

	if global.time.countdown_time_left <= 0 {
		startMatch()
		return
	}

	current_sec := u8(math.ceil(global.time.countdown_time_left))

	if current_sec < global.time.last_sec_sent {
		global.time.last_sec_sent = current_sec
		sendCountDown(global.time.last_sec_sent)
	}
}

startMatch :: proc() {
	global.server_state = .MATCH_RUNNING
	sendMatchStartSignal()
}
