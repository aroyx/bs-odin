package main

import "core:encoding/ini"
import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"
import "core:strconv"
import "core:strings"
import "core:time"

import "../terrain"

ServerState :: enum u8 {
	MATCH_MAKING,
	COUNTDOWN,
    LOADING,
	MATCH_RUNNING,
	MATCH_END,
}

ServerPlayerState :: struct {
	id:    uintptr,
	pos:   linalg.Vector2f32,
	ready: bool,
}

GlobalState :: struct {
	client_id_counter: uintptr,
	server_state:      ServerState,
	players:           map[uintptr]ServerPlayerState,
	time:              TimeState,
	net:               Network,
	seed:              i32,
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
	global.players = make(map[uintptr]ServerPlayerState)
	global.seed = rand.int31()

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

	broadcastCountDown(3)
}

startLoading :: proc() {
    global.server_state = .LOADING

    broadcastLoading()
    // generate terrain
    terrain.setSeed(global.seed)
    terrain.createTerrain()
}

updateCountdown :: proc() {
	if global.server_state != .COUNTDOWN do return

	curr_time := time.now()
	diff := f32(time.duration_seconds(time.diff(global.time.last_countdown_time, curr_time)))

	global.time.last_countdown_time = curr_time
	global.time.countdown_time_left -= diff

	if global.time.countdown_time_left <= 0 {
		startLoading()
		return
	}

	current_sec := u8(math.ceil(global.time.countdown_time_left))

	if current_sec < global.time.last_sec_sent {
		global.time.last_sec_sent = current_sec
		broadcastCountDown(global.time.last_sec_sent)
	}
}

startMatch :: proc() {
	global.server_state = .MATCH_RUNNING
	broadcastMatchStart()
}

clientReady :: proc(id: uintptr) {
	if !(id in global.players) do return

	player := &global.players[id]

    player.ready = true

    for _, pl in global.players {
        if !pl.ready do return
    }

    // all players are ready, can start match now
    startMatch()
}
