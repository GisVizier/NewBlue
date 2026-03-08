--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Button = require(script.Parent.Button)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(script.Parent.Parent.Theme)
local UiLabs = require(ReplicatedStorage.Packages.UiLabs)

local Children = Fusion.Children

local function story(props: UiLabs.FusionProps)
	local scope = (props.scope :: Fusion.Scope<typeof(Fusion)>):innerScope({
		Button = Button,
	})

	scope:New("Frame")({
		BackgroundTransparency = 1,
		Parent = props.target,
		Size = UDim2.fromScale(1, 1),

		[Children] = {
			scope:New("UIListLayout")({
				Padding = UDim.new(0, Theme.spacing._4),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			scope:New("Frame")({
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,

				[Children] = {
					scope:Button({ Content = { "Small" }, Size = "sm" }),
					scope:Button({ Content = { "Medium" }, Size = "md" }),
					scope:Button({ Content = { "Large" }, Size = "lg" }),

					scope:New("UIListLayout")({
						Padding = UDim.new(0, Theme.spacing._3),
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),
				},
			}),

			scope:New("Frame")({
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,

				[Children] = {
					scope:Button({ Variant = "filled", Content = { "Filled" }, Colour = Theme.colour.indigo._600 }),
					scope:Button({ Variant = "outlined", Content = { "Outlined" }, Colour = Theme.colour.indigo._600 }),
					scope:Button({ Variant = "ghost", Content = { "Ghost" }, Colour = Theme.colour.indigo._600 }),

					scope:New("UIListLayout")({
						Padding = UDim.new(0, Theme.spacing._3),
						FillDirection = Enum.FillDirection.Horizontal,
					}),
				},
			}),

			scope:New("Frame")({
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,

				[Children] = {
					scope:Button({ Content = { "Enabled" }, Disabled = false, Colour = Theme.colour.emerald._700 }),
					scope:Button({ Content = { "Disabled" }, Disabled = true, Colour = Theme.colour.emerald._700 }),

					scope:New("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0, Theme.spacing._3),
					}),
				},
			}),

			scope:New("Frame")({
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,

				[Children] = {
					scope:New("UIListLayout")({
						Padding = UDim.new(0, Theme.spacing._3),
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),

					scope:Button({
						Content = { "rbxassetid://14939267269", "Delete" },
						Colour = Theme.colour.red._500,
						Variant = "outlined",
					}),

					scope:Button({
						Content = { "rbxassetid://14939474190" },
						Colour = Theme.colour.green._500,
						Variant = "outlined",
					}),

					-- scope:Button({
					-- 	Content = { "rbxassetid://13858834545" },
					-- 	Colour = Theme.colour.sky._700,
					-- 	ContentSize = Theme.textSize._5xl,
					-- 	PaddingX = Theme.spacing._0,
					-- 	PaddingY = Theme.spacing._0,
					-- }),

					scope:Button({
						Content = { "rbxassetid://14943873128", "Hello world!" },
						Colour = Theme.colour.orange._500,
					}),
				},
			}),
		},
	})
end

return {
	fusion = Fusion,
	story = story,
}
