--!strict
--[[
	Scrim - Semi-transparent layer for focusing attention on modal UIs

	A "scrim" is the design term for a darkened/dimmed layer behind modals,
	drawers, and other overlay content to indicate background is inactive.

	Usage:
		local Scrim = require(script.Parent.Scrim)
		Scrim.show()  -- Dim the background
		Scrim.hide()  -- Remove dimming
		Scrim.bind(State.IsVisible)  -- Bind to Fusion state
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)

local scoped = Fusion.scoped
local peek = Fusion.peek
local player = Players.LocalPlayer
local scope = scoped(Fusion)
local isVisible = scope:Value(false)
local activeCount = 0

local function init()
	local blur = Instance.new("BlurEffect")
	blur.Name = "ScrimBlur"
	blur.Enabled = false
	blur.Parent = workspace.CurrentCamera

	scope:New("ScreenGui")({
		Name = "Scrim",
		Parent = player:WaitForChild("PlayerGui"),
		IgnoreGuiInset = true,
		Enabled = isVisible,

		[Fusion.Children] = {
			scope:New("Frame")({
				Name = "Dim",
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.new(0, 0, 0),
				BackgroundTransparency = 0.75,
			}),
		},
	})

	scope:Observer(isVisible):onBind(function()
		blur.Enabled = peek(isVisible)
	end)
end

init()

local Scrim = {}

function Scrim.show()
	activeCount += 1
	isVisible:set(true)
end

function Scrim.hide()
	activeCount = math.max(0, activeCount - 1)
	if activeCount == 0 then
		isVisible:set(false)
	end
end

function Scrim.isVisible(): boolean
	return peek(isVisible)
end

-- Bind to a Fusion state object (e.g., State.IsVisible)
function Scrim.bind(state: Fusion.Value<boolean>)
	local wasVisible = false
	scope:Observer(state):onBind(function()
		local nowVisible = peek(state)
		if nowVisible and not wasVisible then
			Scrim.show()
		elseif not nowVisible and wasVisible then
			Scrim.hide()
		end
		wasVisible = nowVisible
	end)
end

return Scrim
