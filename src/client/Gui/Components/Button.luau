--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Contrast = require(script.Parent.Parent.Utility.Contrast)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Theme = require(script.Parent.Parent.Theme)

type Scope = Fusion.Scope<typeof(Fusion)>
type UsedAs<T> = Fusion.UsedAs<T>
type Size = "sm" | "md" | "lg"

local PRESS_INTENSITY = 0.2
local DISABLED_ALPHA = 0.4
local OUTLINED_FILL_ALPHA = 0.1
local MIN_ICON_PADDING = Theme.spacing._1
local SIZE_CONFIG: { [Size]: {
	contentSize: number,
	gap: number,
	paddingX: number,
	paddingY: number,
} } = {
	sm = {
		contentSize = Theme.textSize.base,
		gap = Theme.spacing._1,
		paddingX = Theme.spacing._3_5,
		paddingY = Theme.spacing._1_5,
	},
	md = {
		contentSize = Theme.textSize.lg,
		gap = Theme.spacing._1_5,
		paddingX = Theme.spacing._4,
		paddingY = Theme.spacing._2,
	},
	lg = {
		contentSize = Theme.textSize.xl,
		gap = Theme.spacing._2,
		paddingX = Theme.spacing._5,
		paddingY = Theme.spacing._2_5,
	},
}

local OnEvent = Fusion.OnEvent
local peek = Fusion.peek
local Children = Fusion.Children

local function emphasiseColour(colour: Color3, intensity: number): Color3
	local coefficient = intensity * (1 + Contrast.perceivedBrightness(colour))
	return Contrast.emphasise(colour, coefficient)
end

local function isValidInput(input: InputObject): boolean
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
		or input.KeyCode == Enum.KeyCode.ButtonA
		or input.KeyCode == Enum.KeyCode.Return
end

local function compactPadding(value: number, ratio: number): number
	return math.max(MIN_ICON_PADDING, math.floor((value * ratio) + 0.5))
end

local function Button(
	scope: Scope,
	props: {
		AnchorPoint: UsedAs<Vector2>?,
		LayoutOrder: UsedAs<number>?,
		Position: UsedAs<UDim2>?,
		Visible: UsedAs<boolean>?,
		ZIndex: UsedAs<number>?,

		Colour: UsedAs<Color3>?,
		Disabled: UsedAs<boolean>?,
		Variant: UsedAs<"filled" | "outlined" | "ghost">?,
		OnClick: (() -> ())?,
		Size: UsedAs<Size>?,
		PaddingY: UsedAs<number>?,
		Content: UsedAs<{ string }>?,
		PaddingX: UsedAs<number>?,
		ContentGap: UsedAs<number>?,
		ContentSize: UsedAs<number>?,
	}
): Instance
	scope = scope:innerScope()

	local baseColour = props.Colour or Theme.colour.stone._800
	local isPressed = scope:Value(false)
	local isHovered = scope:Value(false)
	local variant = props.Variant or "filled"
	local size = props.Size or "md"

	local backgroundColour = scope:Computed(function(use)
		local base = use(baseColour)
		if use(props.Disabled) then
			return base
		elseif use(isPressed) then
			return emphasiseColour(base, PRESS_INTENSITY)
		elseif use(isHovered) then
			return emphasiseColour(base, 2 / 15)
		else
			return base
		end
	end)

	local pressSpring = scope:Spring(
		scope:Computed(function(use)
			return use(isPressed) and 1 or 0
		end),
		50,
		1
	)

	local isIconOnly = scope:Computed(function(use)
		local content = use(props.Content)
		return content ~= nil and #content == 1 and string.find(content[1], "rbxassetid://", 1, true) ~= nil
	end)

	local paddingY = scope:Computed(function(use)
		local basePaddingY = use(props.PaddingY) or SIZE_CONFIG[use(size)].paddingY
		if use(isIconOnly) then
			return UDim.new(0, compactPadding(basePaddingY, 0.7))
		else
			return UDim.new(0, basePaddingY)
		end
	end)

	local paddingX = scope:Computed(function(use)
		local basePaddingX = use(props.PaddingX) or SIZE_CONFIG[use(size)].paddingX
		if use(isIconOnly) then
			return UDim.new(0, compactPadding(basePaddingX, 0.35))
		else
			return UDim.new(0, basePaddingX)
		end
	end)

	local contentGap = scope:Computed(function(use)
		local preset = SIZE_CONFIG[use(size)]
		return use(props.ContentGap) or preset.gap
	end)

	local filledContentColour = scope:Computed(function(use)
		return Contrast.textOn(use(baseColour), Theme.colour.white, Theme.colour.slate._900)
	end)
	local contentColour = scope:Computed(function(use)
		if use(variant) == "filled" then
			return use(filledContentColour)
		elseif use(variant) == "outlined" then
			return use(backgroundColour)
		elseif use(variant) == "ghost" then
			return use(backgroundColour)
		else
			return use(filledContentColour)
		end
	end)
	local contentColourSpring = scope:Spring(contentColour, 60, 1)

	local contentTransparency = scope:Computed(function(use)
		return if use(props.Disabled) then Theme.alpha(DISABLED_ALPHA) else 0
	end)

	local contentSize = scope:Computed(function(use)
		local preset = SIZE_CONFIG[use(size)]
		return use(props.ContentSize) or preset.contentSize
	end)

	return scope:New("TextButton")({
		AnchorPoint = props.AnchorPoint,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundColor3 = scope:Spring(backgroundColour, 60, 1),
		LayoutOrder = props.LayoutOrder,
		Name = script.Name,
		Position = props.Position,
		Visible = props.Visible,
		ZIndex = props.ZIndex,

		Active = scope:Computed(function(use)
			return not use(props.Disabled)
		end),

		BackgroundTransparency = scope:Computed(function(use)
			if use(variant) == "filled" then
				return if use(props.Disabled) then Theme.alpha(DISABLED_ALPHA) else 0
			elseif use(variant) == "outlined" then
				local alpha = if use(props.Disabled) then OUTLINED_FILL_ALPHA * DISABLED_ALPHA else OUTLINED_FILL_ALPHA
				return Theme.alpha(alpha)
			else
				return 1
			end
		end),

		[OnEvent("Activated")] = function()
			if props.OnClick and not peek(props.Disabled) then
				props.OnClick()
			end
		end,

		[OnEvent("MouseEnter")] = function()
			isHovered:set(true)
		end,

		[OnEvent("InputBegan")] = function(input: InputObject)
			if not peek(props.Disabled) and isValidInput(input) then
				isPressed:set(true)
			end
		end,

		[OnEvent("InputEnded")] = function(input: InputObject)
			if isValidInput(input) then
				isPressed:set(false)
			end
		end,

		[OnEvent("MouseLeave")] = function()
			isHovered:set(false)
			isPressed:set(false)
		end,

		[OnEvent("SelectionGained")] = function()
			isHovered:set(true)
		end,

		[OnEvent("SelectionLost")] = function()
			isHovered:set(false)
			isPressed:set(false)
		end,

		[Children] = {
			scope:New("UICorner")({ CornerRadius = Theme.radius.md }),

			scope:New("UIStroke")({
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = Theme.colour.white,
				Transparency = scope:Computed(function(use)
					if use(variant) == "ghost" then
						return 1
					elseif use(props.Disabled) then
						return Theme.alpha(DISABLED_ALPHA)
					else
						return 0
					end
				end),

				[Children] = scope:New("UIGradient")({
					Rotation = 90,
					Color = scope:Computed(function(use)
						local intensity = if (use(variant) == "filled")
								and not (use(props.Disabled) or use(isHovered) or use(isPressed))
							then PRESS_INTENSITY
							else 0

						local bgColour = use(backgroundColour)
						return ColorSequence.new({
							ColorSequenceKeypoint.new(0, Contrast.lighten(bgColour, intensity)),
							ColorSequenceKeypoint.new(1, bgColour),
						})
					end),
				}),
			}),

			scope:New("UIScale")({
				Scale = scope:Computed(function(use)
					return 1 - (use(pressSpring) * 0.05)
				end),
			}),

			scope:New("UIPadding")({
				PaddingBottom = paddingY,
				PaddingLeft = paddingX,
				PaddingRight = paddingX,
				PaddingTop = paddingY,
			}),

			scope:New("Frame")({
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,

				[Children] = {
					scope:New("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = scope:Computed(function(use)
							return UDim.new(0, use(contentGap))
						end),
					}),

					scope:ForValues(props.Content or {}, function(_, scope: Scope, content)
						if string.find(content, "rbxassetid://", 1, true) then
							return scope:New("ImageLabel")({
								BackgroundTransparency = 1,
								Image = content,
								ImageColor3 = contentColourSpring,
								ImageTransparency = contentTransparency,
								Size = scope:Computed(function(use)
									local size = use(contentSize)
									return UDim2.fromOffset(size, size)
								end),
							})
						else
							return scope:New("TextLabel")({
								AutomaticSize = Enum.AutomaticSize.XY,
								BackgroundTransparency = 1,
								FontFace = Font.new(Theme.font.sans.Family, Theme.fontWeight.semiBold),
								Text = content,
								TextColor3 = contentColourSpring,
								TextSize = contentSize,
								TextTransparency = contentTransparency,
							})
						end
					end) :: any,
				},
			}),
		},
	})
end

return Button
