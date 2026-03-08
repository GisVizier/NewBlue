--!strict
--!nolint LocalShadow

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Fusion"))

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

type Scope = Fusion.Scope<typeof(Fusion)>
type UsedAs<T> = Fusion.UsedAs<T>
type Child = Fusion.Child

local function LoadingScreen(
	scope: Scope,
	props: {
		LabelText: UsedAs<string>,
		SkipVisible: UsedAs<boolean>,
		OnSkip: (() -> ())?,
	}
): Child
	local scope = scope:innerScope()

	local isHovering = scope:Value(false)

	local skipBackgroundTransparency = scope:Spring(
		scope:Computed(function(use)
			return if use(isHovering) then 0.7 else 0.85
		end),
		25
	)

	return scope:New("ScreenGui")({
		Name = "LoadingScreen",
		DisplayOrder = 100,
		IgnoreGuiInset = true,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		ResetOnSpawn = false,

		[Children] = {
			scope:New("Frame")({
				Name = "Canvas",
				Active = true,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(44, 44, 44),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),

				[Children] = {
					scope:New("TextLabel")({
						Name = "Label",
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 0.0731),
						Text = props.LabelText,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						TextTransparency = 0.35,
						ZIndex = 2,

						[Children] = {
							scope:New("UIPadding")({
								PaddingBottom = UDim.new(0.006, 0),
								PaddingLeft = UDim.new(0.262, 0),
								PaddingRight = UDim.new(0.262, 0),
								PaddingTop = UDim.new(0.006, 0),
							}),

							scope:New("UIAspectRatioConstraint")({
								AspectRatio = 24.3,
							}),
						},
					}),

					scope:New("TextButton")({
						Name = "Skip",
						AnchorPoint = Vector2.new(0.5, 0.8),
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
						BackgroundTransparency = skipBackgroundTransparency,
						BorderSizePixel = 0,
						FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json"),
						Position = UDim2.fromScale(0.5, 0.8),
						Size = UDim2.fromScale(0.169, 0.0731),
						Text = "Skip",
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextScaled = true,
						TextTransparency = 0.35,
						Visible = props.SkipVisible,
						ZIndex = 2,

						[OnEvent("Activated")] = function()
							if props.OnSkip then
								props.OnSkip()
							end
						end,

						[OnEvent("MouseEnter")] = function()
							isHovering:set(true)
						end,

						[OnEvent("MouseLeave")] = function()
							isHovering:set(false)
						end,

						[Children] = {
							scope:New("UICorner")({
								CornerRadius = UDim.new(0.2, 0),
							}),

							scope:New("UIPadding")({
								PaddingBottom = UDim.new(0.00462, 0),
								PaddingLeft = UDim.new(0.325, 0),
								PaddingRight = UDim.new(0.325, 0),
								PaddingTop = UDim.new(0.00462, 0),
							}),

							scope:New("UIAspectRatioConstraint")({
								AspectRatio = 4.13,
							}),
						},
					}),
				},
			}),
		},
	})
end

return LoadingScreen
