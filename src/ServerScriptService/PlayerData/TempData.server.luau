

game.Players.PlayerAdded:Connect(function(Player)
	local TempData = Instance.new("Folder",Player)
	TempData.Name = "TempData"
	
	for i,v in pairs(script:GetChildren())do
		local Clone = v:Clone()
		Clone.Parent = TempData
	end
end)

