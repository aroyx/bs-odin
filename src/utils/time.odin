package utils

import "core:time"
import rl "vendor:raylib"

@(private = "file")
last_time: time.Time

total_time, frame_time, fps, dt: f64 = 0, 0, 0, 0

when ODIN_OS == .JS {
	initTimer :: proc() {
		last_time = time.now()
	}

	stopTimer :: proc() {
		curr_time := time.now()
		dur := time.diff(last_time, curr_time)
		frame_time = time.duration_milliseconds(dur)

        // no need to sleep, raylib does that for us (let's pray it does)

		fps = f64(rl.GetFPS())
		dt = f64(rl.GetFrameTime())
        total_time += dt * 1000.0
	}

} else {
	@(private = "file")
	TARGET_FPS :: 60.0
	@(private = "file")
	TARGET_FRAME_DUR :: time.Duration(time.Second / TARGET_FPS)

	initTimer :: proc() {
		last_time = time.now()
	}

	stopTimer :: proc() {
		curr_time := time.now()
		dur := time.diff(last_time, curr_time)
		frame_time = time.duration_milliseconds(dur)

		sleep_for := TARGET_FRAME_DUR - dur
		time.sleep(sleep_for) // I wanna see what happens if `sleep_for` is negative, but for that to happen I'd need to make a slow application, I think, never gonna happen. UNLESS!

		curr_time = time.now()
		dur = time.diff(last_time, curr_time)

		fps = 1.0 / time.duration_seconds(dur)
		dt = time.duration_seconds(dur)
        total_time += dt * 1000.0
	}
}
