package main

import "server"
import "client"

SERVER :: #config(SERVER, false)

main :: proc() {
	when SERVER {
		server.BootServer()
	} else {
		client.BootClient()
	}
}
