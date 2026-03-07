--!strict

local ReplicaServer = {}

export type Replica = {
	Id: string,
	Class: string,
	Data: { [string]: any },
	Replicate: (self: Replica) -> (),
	SetValue: (self: Replica, path: { string }, value: any) -> (),
	SetValues: (self: Replica, path: { string }, values: { [string]: any }) -> (),
	ArrayInsert: (self: Replica, path: { string }, index: number, value: any) -> (),
	ArraySet: (self: Replica, path: { string }, index: number, value: any) -> (),
	ArrayRemove: (self: Replica, path: { string }, index: number) -> (),
	ConnectOnServerEvent: (self: Replica, callback: (player: Player, ...any) -> ()) -> (),
	Destroy: (self: Replica) -> (),
}

ReplicaServer.New = function(_options: { ClassName: string, Replication: string?, Data: { [string]: any }? }): Replica
	return {} :: any
end

ReplicaServer.Token = function(_className: string): string
	return "" :: any
end

ReplicaServer.ReadyPlayers = {} :: { [Player]: boolean }
ReplicaServer.NewReadyPlayer = nil :: RBXScriptSignal?

return ReplicaServer
