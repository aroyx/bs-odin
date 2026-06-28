package network

import "core:fmt"
import "core:time"

import "../types"

import enet "vendor:ENet"

@(private)
connected := false
@(private)
connecting := false

@(private)
peer: ^enet.Peer = nil

@(private)
client: ^enet.Host = nil

@(private)
net_event: enet.Event = {}

@(private)
my_id: uintptr = 0

InitialiseNetwork :: proc() -> bool {
	if enet.initialize() != 0 {
		fmt.println("Unable to Initialise enet, Stopping the client")
		return false
	}

	client = enet.host_create(
		address = nil,
		peerCount = 1,
		channelLimit = 2,
		incomingBandwidth = 0,
		outgoingBandwidth = 0,
	)

	if client == nil {
		fmt.println("Unable to create the client thingy!")
		return false
	}

	return true
}

DestroyNetwork :: proc() {
	if connected {
		enet.peer_disconnect_now(peer, 0)
		enet.peer_reset(peer)
	}

	enet.host_destroy(client)
	enet.deinitialize()
}

Connect :: proc(host: cstring, port: u16) {
	if connected || connecting {
		return
	}

	// make the address and port argumental
	address: enet.Address = {}
	enet.address_set_host(&address, host)
	address.port = port

	peer = enet.host_connect(client, &address, 2, 0)
	if peer == nil {
		fmt.println("No available peers for initiating an ENet connection.")
		return
	}

	connecting = true
}

Disconnect :: proc() {
	assert(peer != nil)
	if connected {
		enet.peer_disconnect(peer, 0)
	}
}

IsConnected :: proc() -> bool {
	return connected && peer != nil
}

Send :: proc(data: rawptr, size: uint, reliable: bool = false) {
	flag: enet.PacketFlag = reliable ? .RELIABLE : .UNSEQUENCED
	packet := enet.packet_create(data, size, {flag})
	enet.peer_send(peer = peer, channelID = 0, packet = packet)
}

GetNetworkEvent :: proc() -> NetworkEvent {
	for enet.host_service(client, &net_event, 0) > 0 {
		switch (net_event.type) {
		case .CONNECT:
			connected = true
			connecting = false
			return connect{}
		case .DISCONNECT:
			connected = false
			peer = nil
			my_id = 0
			return disconnect{}
		case .RECEIVE:
			defer enet.packet_destroy(net_event.packet)
			packet_type := (cast(^types.PacketType)net_event.packet.data)^

			#partial switch (packet_type) {
			case .NEW_JOIN:
				new_join := cast(^types.NewJoin)net_event.packet.data
				my_id = new_join.id
				return none{}

			case .SERVER_OUTPUT:
				server_out := (cast(^types.ServerOutput)net_event.packet.data)^
				return receive{packet = server_out}

			case .MATCH_MAKING_OUTPUT:
				match_making := (cast(^types.MatchMakingOutput)net_event.packet.data)^
				return receive{packet = match_making}

			case .COUNTDOWN_OUTPUT:
				countdown := (cast(^types.CountDownOutput)net_event.packet.data)^
				return receive{packet = countdown}

			case .MATCH_START:
				match_start := (cast(^types.MatchStartOutput)net_event.packet.data)^
				return receive{packet = match_start}

			case .PING:
				Pong()
				return none{}
			}
			return none{}
		case .NONE:
			return none{}
		}
	}
	return none{}
}

GetServerID :: proc() -> uintptr {
	return my_id
}

@(private = "file")
ping_sent_time: time.Time = {}

Ping :: proc() {
	ping_sent_time = time.now()

	a: types.Ping = {.PING}
	Send(&a, size_of(a), true)
}

Pong :: proc() {
	diff := time.duration_milliseconds(time.diff(ping_sent_time, time.now()))
	fmt.printfln("Ping: %fms", diff)
}
