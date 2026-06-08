package client

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

quit := false
show_fps := true
input: common.PlayerInput = {}
client_state: ClientState = .MAIN_MENU
render_state: common.ServerOutput = {}
countdown: common.CountDownOutput = {}
fps: f64 = 0
