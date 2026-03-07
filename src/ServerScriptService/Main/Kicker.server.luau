local AuthorizeUsers = {
	143897090;
	294150975;
	220365802;
	123721150;
	264053807;
	398632409;
	3882191972;
	123721150;
	247935750;
	31556003;
}


local ValidTesterRanks = {

	252;
	254;
	255;

}


_G.TestingActive = game:GetService("ReplicatedStorage"):WaitForChild("TestingActive").Value


game.Players.PlayerAdded:Connect(function(Player)
	
	if game:GetService("RunService"):IsStudio() then
		return
	end
	
	local Valid = false
	
	local UserId = Player.UserId
	
	local Rank = Player:GetRankInGroup(10950769)
	
	for i,v in pairs(AuthorizeUsers) do
		if v == UserId  then
			if _G.TestingActive then
				Valid = true
			end
		end
	end
	
	for i,v in pairs(ValidTesterRanks) do
		if v == Rank  then
			Valid = true
		end
	end
	
	print(Valid)
	
	wait(4)
	--[[
	if not Valid then
		Player:Kick("You are not authorized")
	else
		local Valid = Instance.new("BoolValue")
		Valid.Name = "Valid"
		Valid.Parent = Player
		_G.Notify(Player,"Authorization Successful","Positive")
	end
	--]]
	
	local Valid = Instance.new("BoolValue")
	Valid.Name = "Valid"
	Valid.Parent = Player
	_G.Notify(Player,"Authorization Successful","Positive")
	
end)