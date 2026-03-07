game.Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function()
		Player.Character.Archivable = true
		print("SetTrue")
	end)
end)