--!strict

local Net = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Net"))

local NotificationService = {}

function NotificationService:Init()
end

function NotificationService:Start()
end

function NotificationService.Send(player: Player, message: string, notifyType: string, duration: number?, sound: string?)
	local finalDuration = duration or 5
	Net.fireClient("Notify", player, notifyType, message, finalDuration, sound)
end

return NotificationService
