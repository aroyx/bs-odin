package server

import "core:math"
import "core:time"
import "src:common"

client_id_counter: uintptr = 0
players: map[uintptr]common.PlayerState

ServerState :: enum u8 {
	MATCH_MAKING,
	COUNTDOWN,
	MATCH_RUNNING,
	MATCH_END,
}

server_state: ServerState = .MATCH_MAKING

defaultState :: proc() -> int {
	players = make(map[uintptr]common.PlayerState)

	return 0
}

destroyState :: proc() {
	delete(players)
}

countdown_time_left: f32
last_sec_sent: u8
last_countdown_time: time.Time

startCountdown :: proc() {
	server_state = .COUNTDOWN
	countdown_time_left = 3.0
	last_sec_sent = 3
	last_countdown_time = time.now()

	sendCountDown(3)
}

updateCountdown :: proc() {
	if server_state != .COUNTDOWN do return

	curr_time := time.now()
	diff := f32(time.duration_seconds(time.diff(last_countdown_time, curr_time)))

	last_countdown_time = curr_time
	countdown_time_left -= diff

	if countdown_time_left <= 0 {
		startMatch()
		return
	}

	current_sec := u8(math.ceil(countdown_time_left))

	if current_sec < last_sec_sent {
		last_sec_sent = current_sec
		sendCountDown(last_sec_sent)
	}
}

startMatch :: proc() {
	server_state = .MATCH_RUNNING
    sendMatchStartSignal()
}
