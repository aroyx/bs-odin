package main

// goals: recieve inputs and move the guys

import "core:fmt"
import enet "vendor:ENet"

main :: proc() {
	if enet.initialize() != 0 {
		fmt.println("Unable to Initialize enet, Stopping the server")
		return
	}
	defer enet.deinitialize()

	address: enet.Address = {
		host = enet.HOST_ANY,
		port = 7777,
	}

	max_clients :: 32
	server := enet.host_create(&address, max_clients, 2, 0, 0)

	if server == nil {
		fmt.println("Unable to create the server!")
		return
	}
	defer enet.host_destroy(server)

	fmt.println("Server Started successfully!")

	event: enet.Event
	client_id: uintptr = 0

	for {
		for enet.host_service(server, &event, 100) > 0 {
			switch event.type {
			case enet.EventType.CONNECT:
				{
					fmt.printf(
						"A new client connected from %d:%d.\n",
						event.peer.address.host,
						event.peer.address.port,
					)

					event.peer.data = rawptr(client_id)
					client_id += 1
					break
				}
			case enet.EventType.DISCONNECT:
				{
					fmt.printf("%d disconnected.\n", cast(uintptr)event.peer.data)
					event.peer.data = nil
					break
				}
			case enet.EventType.RECEIVE:
				{
					fmt.printf(
						"A packet of length %lu containing %s was received from %d on channel %d.\n",
						event.packet.dataLength,
						event.packet.data,
						cast(uintptr)event.peer.data,
						event.channelID,
					)
					enet.packet_destroy(event.packet)
					break
				}
			case enet.EventType.NONE:
				{
					fmt.printf("Whar are you upto mate\n")
					break
				}
			}
		}
	}
}
