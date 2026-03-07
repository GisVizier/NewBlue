--!strict

local function Format(int: number): string
	return string.format("%02i", int)
end

local HMSConvert = {}

function HMSConvert.ConvertToHMS(seconds: number): string
	local minutes = (seconds - seconds % 60) / 60
	seconds = seconds - minutes * 60
	local hours = (minutes - minutes % 60) / 60
	minutes = minutes - hours * 60
	return Format(hours) .. ":" .. Format(minutes) .. ":" .. Format(seconds)
end

return HMSConvert
