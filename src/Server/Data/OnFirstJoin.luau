--[[
    Called when a player joins for the first time.
    Seeds starter data.
]]

local DataGlobal = require(script.Parent.DataGlobal)

return function(Data)
	Data.FirstJoin = DataGlobal.osTime(true)
end
