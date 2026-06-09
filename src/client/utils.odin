package client

import "core:time"

@(private = "file")
last_time: time.Time

initTimer :: proc() {
	last_time = time.now()
}

@(private = "file")
TARGET_FPS :: 60.0
@(private = "file")
TARGET_FRAME_DUR :: time.Duration(time.Second / TARGET_FPS)

stopTimer :: proc() {
	curr_time := time.now()
	dur := time.diff(last_time, curr_time)

	sleep_for := TARGET_FRAME_DUR - dur
	time.sleep(sleep_for) // I wanna see what happens if `sleep_for` is negative, but for that to happen I'd need to make a slow application, I think, never gonna happen

	curr_time = time.now()
	dur = time.diff(last_time, curr_time)

	fps = 1.0 / time.duration_seconds(dur)
	frame_time = time.duration_milliseconds(dur)
}
