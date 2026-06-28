package network

import "../types"

NetworkEvent :: union {
	connect,
	disconnect,
	receive,
	none,
}

connect :: struct {}
disconnect :: struct {}

receive :: struct {
	packet: ReceivedStruct,
}

none :: struct {}

ReceivedStruct :: union {
	types.ServerOutput,
	types.MatchMakingOutput,
	types.CountDownOutput,
	types.MatchStartOutput,
	types.Loading,
}
