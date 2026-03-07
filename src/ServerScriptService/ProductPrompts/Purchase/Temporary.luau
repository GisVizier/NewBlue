local module = {
	
	Engage = function(Player)
		
		local GamePassesProducts = Player:WaitForChild("GamePasses/Products")
		local RealmData = GamePassesProducts:WaitForChild("Realm")
		local DatePurchased = RealmData:WaitForChild("DatePurchased")
		DatePurchased.Value = tick()
		
		
		return true
	end,

}

return module

