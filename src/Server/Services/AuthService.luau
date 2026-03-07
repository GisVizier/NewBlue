--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Constants = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Constants"))
local NotificationService = require(script.Parent.NotificationService)

local AuthService = {}

function AuthService:Init()
end

function AuthService:Start()
	Players.PlayerAdded:Connect(function(player)
		self:_authorize(player)
	end)

	for _, player in Players:GetPlayers() do
		task.spawn(function()
			self:_authorize(player)
		end)
	end
end

function AuthService:_authorize(player: Player)
	if RunService:IsStudio() then
		self:_grantAccess(player)
		return
	end

	local valid = false
	local userId = player.UserId

	local rank = 0
	local success, _ = pcall(function()
		rank = player:GetRankInGroup(Constants.GROUP_ID)
	end)

	if not success then
		rank = 0
	end

	if Constants.TESTING_ACTIVE then
		for _, id in Constants.AUTHORIZED_USER_IDS do
			if id == userId then
				valid = true
				break
			end
		end
	end

	for _, r in Constants.VALID_TESTER_RANKS do
		if r == rank then
			valid = true
			break
		end
	end

	-- Currently always granting access (kick logic disabled in original)
	self:_grantAccess(player)
end

function AuthService:_grantAccess(player: Player)
	local validFlag = Instance.new("BoolValue")
	validFlag.Name = "Valid"
	validFlag.Parent = player
	NotificationService.Send(player, "Authorization Successful", "Positive")
end

return AuthService
