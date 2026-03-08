--!strict

local clamp = math.clamp

--[[
	Color contrast utilities for UI decisions.

	Why this exists:
	- Buttons and labels need readable foreground/background pairs.
	- We want deterministic behavior (same input colors => same output color).
	- We also want a tiny set of color transforms (lighten/darken/emphasise) without a package dependency.

	How to think about it:
	- `perceivedBrightness` is a fast "how bright does this feel?" heuristic.
	- `relativeLuminance` + `ratio` are WCAG math for accessibility checks.
	- `textOn` chooses the better of light/dark text for a given background.
]]

local function clampColor(color: Color3): Color3
	return Color3.new(clamp(color.R, 0, 1), clamp(color.G, 0, 1), clamp(color.B, 0, 1))
end

local function toLinear(value: number): number
	if value <= 0.03928 then
		return value / 12.92
	end
	return ((value + 0.055) / 1.055) ^ 2.4
end

local Contrast = {}

-- Lerp toward white by coefficient (0..1).
function Contrast.lighten(color: Color3, coefficient: number): Color3
	return clampColor(color:Lerp(Color3.new(1, 1, 1), coefficient))
end

-- Lerp toward black by coefficient (0..1).
function Contrast.darken(color: Color3, coefficient: number): Color3
	return clampColor(color:Lerp(Color3.new(0, 0, 0), coefficient))
end

-- Quick visual brightness heuristic (used for "feel" interactions).
function Contrast.perceivedBrightness(color: Color3): number
	local red = color.R * 255
	local green = color.G * 255
	local blue = color.B * 255
	return ((red * 299 + green * 587 + blue * 114) / 1000) / 255
end

-- WCAG relative luminance.
function Contrast.relativeLuminance(color: Color3): number
	local red = toLinear(color.R)
	local green = toLinear(color.G)
	local blue = toLinear(color.B)
	return 0.2126 * red + 0.7152 * green + 0.0722 * blue
end

-- WCAG contrast ratio in [1..21].
function Contrast.ratio(a: Color3, b: Color3): number
	local luminanceA = Contrast.relativeLuminance(a)
	local luminanceB = Contrast.relativeLuminance(b)
	local lighter = math.max(luminanceA, luminanceB)
	local darker = math.min(luminanceA, luminanceB)
	return (lighter + 0.05) / (darker + 0.05)
end

-- "Emphasise" a color: bright colors get darker, dark colors get lighter.
-- This keeps hover/press feedback visible no matter the base color family.
function Contrast.emphasise(color: Color3, coefficient: number, threshold: number?): Color3
	local cutoff = if type(threshold) == "number" then threshold else 0.5
	if Contrast.relativeLuminance(color) > cutoff then
		return Contrast.darken(color, coefficient)
	end
	return Contrast.lighten(color, coefficient)
end

-- Pick whichever text color has stronger contrast on this background.
-- Great default for "filled" buttons with arbitrary Color3 inputs.
function Contrast.textOn(background: Color3, lightText: Color3?, darkText: Color3?): Color3
	local light = lightText or Color3.fromRGB(255, 255, 255)
	local dark = darkText or Color3.fromRGB(15, 23, 42)
	local lightRatio = Contrast.ratio(background, light)
	local darkRatio = Contrast.ratio(background, dark)
	return if lightRatio >= darkRatio then light else dark
end

-- WCAG AA threshold check:
-- normal text >= 4.5, large text >= 3.
function Contrast.meetsAA(background: Color3, text: Color3, largeText: boolean?): boolean
	local required = if largeText then 3 else 4.5
	return Contrast.ratio(background, text) >= required
end

return table.freeze(Contrast)
