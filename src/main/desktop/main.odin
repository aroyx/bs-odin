package main

import client ".."
import "core:fmt"
import "core:os"

import "thirdparty:tracy"

main :: proc() {
	if !checkResourceDir() {
		return
	}

	client.init()

	for client.shouldRun() {
		tracy.FrameMark()
		client.update()
	}

	client.close()
}

checkResourceDir :: proc() -> bool {
	if os.is_directory("res") {
		return true
	}

	fmt.println(
		"`res` directory that contains all the resources not found!!\n",
		"You have to run the executable and have the `res` directory besides it!\n",
		"Run the executable from the root of `res` folder!",
	)

	return false
}
