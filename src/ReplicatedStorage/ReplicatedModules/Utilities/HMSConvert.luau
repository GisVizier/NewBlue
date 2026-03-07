
function Format(Int)
	return string.format("%02i", Int)
end

local module = {



	ConverToHMS = function(Seconds)
		local Minutes = (Seconds - Seconds%60)/60
		Seconds = Seconds - Minutes*60
		local Hours = (Minutes - Minutes%60)/60
		Minutes = Minutes - Hours*60
		return Format(Hours)..":"..Format(Minutes)..":"..Format(Seconds)
	end,



}

return module
