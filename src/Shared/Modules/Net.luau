--!strict

--[[
    Net — Networking layer backed by BridgeNet2.
    Preserves the same API surface so all consumers work unchanged.

    Server: Net.listen(name, handler), Net.fireClient(name, player, ...), Net.fireAllClients(name, ...)
    Client: Net.fire(name, ...), Net.connect(name, handler), Net.invoke(name, ...)
]]

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("BridgeNet2"))

local IS_SERVER = RunService:IsServer()

local BRIDGE_NAMES = {
	-- Customization
	"CustomizeEvent",
	"UpdateColorEvent",
	"RaceRoll",
	-- Economy / Realm
	"RealmRequest",
	"Purchase",
	-- UI / Feedback
	"Notify",
	"LocalSoundEvent",
	-- Combat
	"MeleeHit",
	"AbilityActivation",
	"AbilityReplicate",
	"DamageNumber",
	-- Character replication
	"CharacterState",
	"AnimationStateEvent",
	"NPCStateEvent",
	"SoundRequestEvent",
	-- Misc
	"FilterRequest",
}

local Net = {}

local bridges: { [string]: any } = {}

for _, name in BRIDGE_NAMES do
	if IS_SERVER then
		bridges[name] = BridgeNet2.ServerBridge(name)
	else
		bridges[name] = BridgeNet2.ClientBridge(name)
	end
end

local function getBridge(name: string): any
	local bridge = bridges[name]
	if not bridge then
		error("[Net] Bridge not found: " .. name)
	end
	return bridge
end

if IS_SERVER then
	function Net.listen(remoteName: string, handler: (player: Player, ...any) -> ...any)
		local bridge = getBridge(remoteName)

		-- Support invoke pattern (client calls InvokeServerAsync, handler returns a value)
		bridge.OnServerInvoke = function(player: Player, content: any)
			if type(content) == "table" and content._bn2 then
				return handler(player, table.unpack(content, 1, content.n))
			else
				return handler(player)
			end
		end

		-- Support fire pattern (client calls Fire, no return value expected)
		bridge:Connect(function(player: Player, content: any)
			if type(content) == "table" and content._bn2 then
				handler(player, table.unpack(content, 1, content.n))
			else
				handler(player)
			end
		end)
	end

	function Net.fireClient(remoteName: string, player: Player, ...: any)
		local bridge = getBridge(remoteName)
		local packed = table.pack(...)
		packed._bn2 = true
		bridge:Fire(player, packed)
	end

	function Net.fireAllClients(remoteName: string, ...: any)
		local bridge = getBridge(remoteName)
		local packed = table.pack(...)
		packed._bn2 = true
		bridge:Fire(BridgeNet2.AllPlayers(), packed)
	end
else
	function Net.fire(remoteName: string, ...: any)
		local bridge = getBridge(remoteName)
		local packed = table.pack(...)
		packed._bn2 = true
		bridge:Fire(packed)
	end

	function Net.invoke(remoteName: string, ...: any): ...any
		local bridge = getBridge(remoteName)
		local packed = table.pack(...)
		packed._bn2 = true
		return bridge:InvokeServerAsync(packed)
	end

	function Net.connect(remoteName: string, handler: (...any) -> ())
		local bridge = getBridge(remoteName)
		return bridge:Connect(function(content: any)
			if type(content) == "table" and content._bn2 then
				handler(table.unpack(content, 1, content.n))
			else
				handler()
			end
		end)
	end
end

return Net
