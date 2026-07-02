package main

import "../client"

import "thirdparty:tracy"

main :: proc() {
	client.init()

	for client.shouldRun() {
		tracy.FrameMark()
		client.update()
	}

	client.close()
}
