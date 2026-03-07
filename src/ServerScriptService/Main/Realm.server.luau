local DataVer = 3
local Data_Store =game:GetService("DataStoreService")
local RealmStore = Data_Store:GetDataStore("RealmData"..DataVer)
local RealmRequest =game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RealmRequest")
local TS = game:GetService("TeleportService")
local RealmIndex = {}
RealmIndex.__index = RealmIndex


local ReservedID = game:GetService("ReplicatedStorage"):WaitForChild("RealmData"):WaitForChild("ReservedID")
local BannedPlayers = game:GetService("ReplicatedStorage"):WaitForChild("RealmData"):WaitForChild("BannedPlayers")


local function UpdateBannedPlayers(Player)
	local BanList = RealmStore:GetAsync("Ban/"..Player.UserId.."Ver"..DataVer)
	BannedPlayers.Value = BanList
end

local function VerifyBanList(Player : Player)
	local BanList = RealmStore:GetAsync("Ban/"..Player.UserId.."Ver"..DataVer)
	if not BanList then
		BanList = RealmStore:SetAsync("Ban/"..Player.UserId.."Ver"..DataVer,game:GetService("HttpService"):JSONEncode({}))
	end
	UpdateBannedPlayers(Player)
end

local ActivePlaces = {

	["First Sea"] = 10235829017;
	["Arena Hub"] = 10780744555


}

game.Players.PlayerAdded:Connect(function(Player)
	print(Player)
	local RealmData = Player:WaitForChild("GamePasses/Products"):WaitForChild("Realm")
	local RealmDatePurchased = RealmData:WaitForChild("DatePurchased")

	local RealmCode = Player:WaitForChild("GamePasses/Products"):WaitForChild("Realm"):WaitForChild("RealmCode")
	local ID = RealmStore:GetAsync("RealmIds/"..RealmCode.Value.."Ver"..DataVer)

	if ID then
		ReservedID.Value = ID

		VerifyBanList(Player)

		RealmDatePurchased.Changed:Connect(function(thing)
			RealmIndex.Eliminate(Player.UserId)

			if RealmDatePurchased.Value ~= 0 then
				RealmIndex.Generate(Player)
			end
		end)
	end
end)

function GetRealm(Player)
	local RealmOwner = false
	if not RealmStore:GetAsync("RealmOwners/"..Player.UserId.."Ver"..DataVer) then
		
	else
		RealmOwner = true
	end
	return RealmOwner
end


function RealmIndex.Generate(Player)
	
	local RealmCode = Player:WaitForChild("GamePasses/Products"):WaitForChild("Realm"):WaitForChild("RealmCode")
	local DatePurchased = Player:WaitForChild("GamePasses/Products"):WaitForChild("Realm"):WaitForChild("DatePurchased")

	
	local ReservedServer,ReservedId
		
	local succ,err = pcall(function()
		ReservedServer,ReservedId = TS:ReserveServer(10235829017)
	end)
	
	if succ then

		local RandomCode = string.split(game:GetService("HttpService"):GenerateGUID(false),"-")[1]

		RealmCode.Value = RandomCode
		
		
		RealmStore:SetAsync("RealmOwners/"..Player.UserId.."Ver"..DataVer,RandomCode)
		RealmStore:SetAsync("RealmCodes/"..RandomCode.."Ver"..DataVer,ReservedServer)
		RealmStore:SetAsync("UserIds/"..RandomCode.."Ver"..DataVer,Player.UserId)
		RealmStore:SetAsync("RealmIds/"..RandomCode.."Ver"..DataVer,ReservedId)
		RealmStore:SetAsync("RealmExpirations/"..RandomCode.."Ver"..DataVer,DatePurchased.Value + 2592000)
		ReservedID.Value = ReservedId

		
		
	else
		warn(err,"When Generating Reserve")
	end
	
	


	

end

--finish expiring

function RealmIndex.Eliminate(UserId)
	local RealmCode =RealmStore:GetAsync("RealmOwners/"..UserId.."Ver"..DataVer)
	

	if RealmStore:GetAsync("RealmOwners/"..UserId.."Ver"..DataVer) then
		local RealmPlace = RealmStore:GetAsync("RealmCodes/"..RealmCode.."Ver"..DataVer)
		local RealmId = RealmStore:GetAsync("RealmIds/"..RealmCode.."Ver"..DataVer)
		local RealmExpiration = RealmStore:GetAsync("RealmExpirations/"..RealmCode.."Ver"..DataVer)

		if RealmPlace and RealmId and RealmExpiration then
			RealmStore:RemoveAsync("RealmOwners/"..UserId.."Ver"..DataVer)
			RealmStore:RemoveAsync("RealmCodes/"..RealmCode.."Ver"..DataVer)
			RealmStore:RemoveAsync("RealmIds/"..RealmId.."Ver"..DataVer)
			RealmStore:RemoveAsync("RealmExpirations/"..RealmCode.."Ver"..DataVer)
			RealmStore:RemoveAsync("UserIds/"..RealmCode.."Ver"..DataVer)


			local Message = {Function = "RealmShutdown",Params = {Reserved = RealmId}}
			local EncodedMessage = game:GetService("HttpService"):JSONEncode(Message)
			game:GetService("MessagingService"):PublishAsync("GlobalFunction",EncodedMessage)
			
		end
	end
end

function RealmIndex.ShutDown(UserId)
	local RealmCode = RealmStore:GetAsync("RealmOwners/"..UserId.."Ver"..DataVer)
	
	if RealmStore:GetAsync("RealmOwners/"..UserId.."Ver"..DataVer) then
		local RealmPlace = RealmStore:GetAsync("RealmCodes/"..RealmCode.."Ver"..DataVer)
		local RealmId = RealmStore:GetAsync("RealmIds/"..RealmCode.."Ver"..DataVer)
		local RealmExpiration = RealmStore:GetAsync("RealmExpirations/"..RealmCode.."Ver"..DataVer)

		if RealmPlace and RealmId and RealmExpiration then
	

			local Message = {Function = "RealmShutdown",Params = {Reserved = RealmId}}
			local EncodedMessage = game:GetService("HttpService"):JSONEncode(Message)
			game:GetService("MessagingService"):PublishAsync("GlobalFunction",EncodedMessage)

		end
	end
end

local TemporaryRealmDuration =game:GetService("ReplicatedStorage"):WaitForChild("RealmData"):WaitForChild("TemporaryRealmDuration").Value
local HMS = require(game:GetService("ReplicatedStorage"):WaitForChild("ReplicatedModules"):WaitForChild("Utilities"):WaitForChild("HMSConvert")) 
local GenerateDebounce = false
local BanDebounce = false

RealmRequest.OnServerEvent:Connect(function(Player,Params)
	local Action = Params.Action

	
	
	local RealmData = Player:WaitForChild("GamePasses/Products"):WaitForChild("Realm")
	local RealmCode = RealmData:WaitForChild("RealmCode")
	local DataPurchased = RealmData:WaitForChild('DatePurchased')
	local PassedTime = tick() - DataPurchased.Value
	
	local PlayerOwnsRealm = false
	
	if PassedTime <= TemporaryRealmDuration then
		PlayerOwnsRealm = true
	end
	

	
	if Action == "Generate" and PlayerOwnsRealm then
		if not GenerateDebounce then
			GenerateDebounce = true
			_G.Notify(Player,"Generating Code","Positive")
			RealmIndex.Eliminate(Player.UserId)
			RealmIndex.Generate(Player)
			GenerateDebounce = false
		else
			_G.Notify(Player,"Code Processing","Negative")
		end
	
	end
	
	if PlayerOwnsRealm and Action == "Ban" then
		if not BanDebounce then
			local BanList = game:GetService("HttpService"):JSONDecode(RealmStore:GetAsync("Ban/"..Player.UserId.."Ver"..DataVer)) 
			local User = Params.User
			local FindPlayer
			local succ,err = pcall(function()
				FindPlayer = game.Players:GetUserIdFromNameAsync(User)
			end) 

			if succ then

				if FindPlayer == Player.UserId then
					_G.Notify(Player,"You can't ban yourself","Negative")
					return
				end
				BanDebounce = true


				local Found = false
				for i,v in pairs(BanList) do if v == FindPlayer then Found = true end end
				if Found == true then
					_G.Notify(Player,"Player is already banned","Negative")
				else
					_G.Notify(Player,"Banning","Negative")
					table.insert(BanList,FindPlayer)
					RealmStore:SetAsync("Ban/"..Player.UserId.."Ver"..DataVer,game:GetService("HttpService"):JSONEncode(BanList))
					UpdateBannedPlayers(Player)
					BanDebounce = false
					_G.Notify(Player,"Player has been banned","Negative")
				end
			else
				warn("PlayerNotFound")
				_G.Notify(Player,"Player Does Not Exist","Negative")
			end
			
		else
			_G.Notify(Player,"Busy","Negative")
		end
	end
	
	if Action == "Revoke" and PlayerOwnsRealm then
		if not BanDebounce then
			local BanList = game:GetService("HttpService"):JSONDecode(RealmStore:GetAsync("Ban/"..Player.UserId.."Ver"..DataVer)) 
			local User = Params.User

			local FindPlayer
			local succ,err = pcall(function()
				FindPlayer = game.Players:GetUserIdFromNameAsync(User)
			end) 

			if FindPlayer then
				BanDebounce = true

				local Removed = false
				for i,v in pairs(BanList)do
					if v == FindPlayer then
						Removed = true
						table.remove(BanList,i)
					end
				end


				if Removed then
					_G.Notify(Player,"Revoking","Negative")
					RealmStore:SetAsync("Ban/"..Player.UserId.."Ver"..DataVer,game:GetService("HttpService"):JSONEncode(BanList))
					UpdateBannedPlayers(Player)
					_G.Notify(Player,"Ban has been revoked","Positive")
					BanDebounce = false
				end
			end
			
		else
			_G.Notify(Player,"Busy","Negative")
		end	
	end
	
	if Action == "Join" then
		local Code = Params.Code
		local RealmPlace = RealmStore:GetAsync("RealmCodes/"..Code.."Ver"..DataVer)
		local RealmExpiration = RealmStore:GetAsync("RealmExpirations/"..RealmCode.Value.."Ver"..DataVer)
		local UserId = RealmStore:GetAsync("UserIds/"..Code.."Ver"..DataVer)
		
		
		
		


			if RealmPlace and RealmExpiration then

			local BanList = game:GetService("HttpService"):JSONDecode(RealmStore:GetAsync("Ban/"..UserId.."Ver"..DataVer)) 
			print(UserId.."ServerOwnerId")
			print(Player.UserId.."LocalID")

			for i,v in pairs(BanList)do
				print(v.."FromBanList")
				if v == Player.UserId then

					_G.Notify(Player,"You are banned from this realm","Negative")
					return
				end
			end


				local TimeRemaining = RealmExpiration - tick()
					if TimeRemaining <= 0 then
					RealmIndex.Eliminate(UserId)
					print("Elimating")
					_G.Notify(Player,"Server Has Expired","Negative")
				else
					print('FoundFealm')
					TS:TeleportToPrivateServer(10235829017,RealmPlace,game.Players:GetPlayers())
					_G.Notify(Player,"Teleporting","Positive")
				end
				
			

			else
				print("placeDoesNotExist")
				_G.Notify(Player,"Server Does Not Exist","Negative")

			end
		
	
	end
	
	

	
	
end)

