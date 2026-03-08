--!strict
-- still WIP

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Colours = require(script.Colours)
local deepFreeze = require(ReplicatedStorage.Shared.Utility.deepFreeze)

type PaddingProps = {
	PaddingTop: UDim,
	PaddingBottom: UDim,
	PaddingLeft: UDim,
	PaddingRight: UDim,
}

local Theme = {}

Theme.colour = Colours

Theme.font = {
	sans = Font.new("rbxasset://fonts/families/GothamSSm.json"),
	serif = Font.new("rbxasset://fonts/families/Merriweather.json"),
	mono = Font.new("rbxasset://fonts/families/RobotoMono.json"),
}

-- Tailwind-like spacing scale in pixels (rem values in comments are reference-only).
Theme.spacing = {
	_0 = 0,
	_0_5 = 2,
	_1 = 4,
	_1_5 = 6,
	_2 = 8,
	_2_5 = 10,
	_3 = 12,
	_3_5 = 14,
	_4 = 16,
	_5 = 20,
	_6 = 24,
	_7 = 28,
	_8 = 32,
	_9 = 36,
	_10 = 40,
	_11 = 44,
	_12 = 48,
	_14 = 56,
	_16 = 64,
	_20 = 80,
	_24 = 96,
	_28 = 112,
	_32 = 128,
	_36 = 144,
	_40 = 160,
	_44 = 176,
	_48 = 192,
	_52 = 208,
	_56 = 224,
	_60 = 240,
	_64 = 256,
	_72 = 288,
	_80 = 320,
	_96 = 384,
}

Theme.radius = {
	none = UDim.new(0, 0),
	xs = UDim.new(0, 2), -- 0.125rem
	sm = UDim.new(0, 4), -- 0.25rem
	md = UDim.new(0, 6), -- 0.375rem
	lg = UDim.new(0, 8), -- 0.5rem
	xl = UDim.new(0, 12), -- 0.75rem
	_2xl = UDim.new(0, 16), -- 1rem
	_3xl = UDim.new(0, 24), -- 1.5rem
	_4xl = UDim.new(0, 32), -- 2rem
	full = UDim.new(1, 0), -- 50% (fully round)
}

Theme.textSize = {
	xs = 12, -- 0.75rem
	sm = 14, -- 0.875rem
	base = 16, -- 1rem
	lg = 18, -- 1.125rem
	xl = 20, -- 1.25rem
	_2xl = 24, -- 1.5rem
	_3xl = 30, -- 1.875rem
	_4xl = 36, -- 2.25rem
	_5xl = 48, -- 3rem
	_6xl = 60, -- 3.75rem
	_7xl = 72, -- 4.5rem
	_8xl = 96, -- 6rem
	_9xl = 128, -- 8rem
}

Theme.fontWeight = {
	thin = Enum.FontWeight.Thin, -- 100
	extraLight = Enum.FontWeight.ExtraLight, -- 200
	light = Enum.FontWeight.Light, -- 300
	normal = Enum.FontWeight.Regular, -- 400
	medium = Enum.FontWeight.Medium, -- 500
	semiBold = Enum.FontWeight.SemiBold, -- 600
	bold = Enum.FontWeight.Bold, -- 700
	extraBold = Enum.FontWeight.ExtraBold, -- 800
	black = Enum.FontWeight.Heavy, -- 900
}

Theme.duration = {
	default = 0.15, -- 150ms (Tailwind default)
	fast = 0.075, -- 75ms
	slow = 0.3, -- 300ms
}

Theme.lineHeight = {
	none = 1, -- Single-line, no extra spacing
	tight = 1.25, -- Compact multi-line (lists, captions)
	normal = 1.5, -- Body text, descriptions
	relaxed = 1.75, -- Comfortable reading
	loose = 2, -- Extra breathing room
}

-- Create uniform padding props for UIPadding
function Theme.padding(value: number): PaddingProps
	local udim = UDim.new(0, value)
	return {
		PaddingTop = udim,
		PaddingBottom = udim,
		PaddingLeft = udim,
		PaddingRight = udim,
	}
end

-- Create XY padding props for UIPadding (x = left/right, y = top/bottom)
function Theme.paddingXY(x: number, y: number): PaddingProps
	local xUdim = UDim.new(0, x)
	local yUdim = UDim.new(0, y)
	return {
		PaddingTop = yUdim,
		PaddingBottom = yUdim,
		PaddingLeft = xUdim,
		PaddingRight = xUdim,
	}
end

-- Create individual padding props
function Theme.paddingEach(top: number, right: number, bottom: number, left: number): PaddingProps
	return {
		PaddingTop = UDim.new(0, top),
		PaddingBottom = UDim.new(0, bottom),
		PaddingLeft = UDim.new(0, left),
		PaddingRight = UDim.new(0, right),
	}
end

-- Get transparency value from alpha (convenience for BackgroundTransparency etc.)
function Theme.alpha(value: number): number
	return 1 - math.clamp(value, 0, 1)
end

return deepFreeze(Theme)
