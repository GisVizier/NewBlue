--!strict

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SceneController = {}

function SceneController:Init()
end

function SceneController:Start()
end

function SceneController.PlayCinematic(params: { Parent: BasePart })
	-- Cinematic camera setup - targets the given parent part
	local camera = workspace.CurrentCamera
	if camera and params.Parent then
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = params.Parent.CFrame * CFrame.new(0, 2, 8)
	end
end

function SceneController.PlayTween(instance: Instance, params: { Time: number, EasingStyle: string?, Goal: { [string]: any } })
	local easingStyle = Enum.EasingStyle.Linear
	if params.EasingStyle then
		local ok, style = pcall(function()
			return (Enum.EasingStyle :: any)[params.EasingStyle]
		end)
		if ok and style then
			easingStyle = style
		end
	end

	local tweenInfo = TweenInfo.new(params.Time, easingStyle)
	TweenService:Create(instance, tweenInfo, params.Goal):Play()
end

return SceneController
