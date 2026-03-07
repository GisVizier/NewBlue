--!strict

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IS_SERVER = RunService:IsServer()

local REMOTES = {
	Events = {
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
	},
	Functions = {
		"FilterRequest",
	},
}

local RATE_LIMIT_WINDOW = 1
local RATE_LIMIT_MAX = 10

local Net = {}

local remotesFolder: Folder

local rateLimits: { [string]: { [number]: { count: number, resetTime: number } } } = {}

local function getRateLimitKey(player: Player, remoteName: string): boolean
	local userId = player.UserId
	if not rateLimits[remoteName] then
		rateLimits[remoteName] = {}
	end
	local entry = rateLimits[remoteName][userId]
	local now = tick()
	if not entry or now >= entry.resetTime then
		rateLimits[remoteName][userId] = { count = 1, resetTime = now + RATE_LIMIT_WINDOW }
		return true
	end
	entry.count += 1
	return entry.count <= RATE_LIMIT_MAX
end

if IS_SERVER then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "GameRemotes"
	remotesFolder.Parent = ReplicatedStorage

	for _, name in REMOTES.Events do
		local remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = remotesFolder
	end

	for _, name in REMOTES.Functions do
		local remote = Instance.new("RemoteFunction")
		remote.Name = name
		remote.Parent = remotesFolder
	end

	function Net.listen(remoteName: string, handler: (player: Player, ...any) -> ...any)
		local remote = remotesFolder:FindFirstChild(remoteName)
		if not remote then
			error("[Net] Remote not found: " .. remoteName)
		end

		if remote:IsA("RemoteEvent") then
			(remote :: RemoteEvent).OnServerEvent:Connect(function(player: Player, ...)
				if not getRateLimitKey(player, remoteName) then
					return
				end
				handler(player, ...)
			end)
		elseif remote:IsA("RemoteFunction") then
			(remote :: RemoteFunction).OnServerInvoke = function(player: Player, ...)
				if not getRateLimitKey(player, remoteName) then
					return nil
				end
				return handler(player, ...)
			end
		end
	end

	function Net.fireClient(remoteName: string, player: Player, ...: any)
		local remote = remotesFolder:FindFirstChild(remoteName)
		if not remote or not remote:IsA("RemoteEvent") then
			error("[Net] RemoteEvent not found: " .. remoteName)
		end
		(remote :: RemoteEvent):FireClient(player, ...)
	end

	function Net.fireAllClients(remoteName: string, ...: any)
		local remote = remotesFolder:FindFirstChild(remoteName)
		if not remote or not remote:IsA("RemoteEvent") then
			error("[Net] RemoteEvent not found: " .. remoteName)
		end
		(remote :: RemoteEvent):FireAllClients(...)
	end
else
	remotesFolder = ReplicatedStorage:WaitForChild("GameRemotes") :: Folder

	function Net.fire(remoteName: string, ...: any)
		local remote = remotesFolder:WaitForChild(remoteName)
		if not remote:IsA("RemoteEvent") then
			error("[Net] RemoteEvent not found: " .. remoteName)
		end
		(remote :: RemoteEvent):FireServer(...)
	end

	function Net.invoke(remoteName: string, ...: any): ...any
		local remote = remotesFolder:WaitForChild(remoteName)
		if not remote:IsA("RemoteFunction") then
			error("[Net] RemoteFunction not found: " .. remoteName)
		end
		return (remote :: RemoteFunction):InvokeServer(...)
	end

	function Net.connect(remoteName: string, handler: (...any) -> ())
		local remote = remotesFolder:WaitForChild(remoteName)
		if not remote:IsA("RemoteEvent") then
			error("[Net] RemoteEvent not found: " .. remoteName)
		end
		return (remote :: RemoteEvent).OnClientEvent:Connect(handler)
	end
end

return Net
