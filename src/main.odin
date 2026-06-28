package main

import "server"
import "client"
import "utils"

main :: proc() {
	when utils.SERVER {
		server.BootServer()
	} else {
		client.BootClient()
	}
}
