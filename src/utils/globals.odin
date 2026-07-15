package utils

global: GlobalState = {
	quit = false,
	options = {show_fps = false, on_mobile = false},
}

GlobalState :: struct {
	quit:    bool,
	options: struct {
		on_mobile: bool,
		show_fps:  bool,
	},
}
