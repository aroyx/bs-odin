package client

import "core:time"

@(private="file")
last_time: time.Time

initTimer :: proc() {
	last_time = time.now()
}

stopTimer :: proc() {
	curr_time := time.now()
	dur := time.diff(last_time, curr_time)
	fps = 1.0 / time.duration_seconds(dur)
}
