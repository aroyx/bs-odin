package network

import "src:common"

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
	common.ServerOutput,
	common.MatchMakingOutput,
	common.CountDownOutput,
	common.MatchStartOutput,
}
