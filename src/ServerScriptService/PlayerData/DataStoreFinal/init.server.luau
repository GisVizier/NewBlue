
DATASTOREVERSION = 7 --DO NOT change this unless you need to reset the datastore!!
AUTOSAVEPERIOD = 120 --Amount of seconds per autosave



StarterData = script:WaitForChild("StarterPlayerData"):Clone()
for i,v in pairs(StarterData:GetChildren())do
	if v:IsA("PackageLink") then
		v:Destroy()
	end
end



local ProfileService = require(game:GetService("ServerStorage"):WaitForChild("Modules"):WaitForChild("Data"):WaitForChild("ProfileService"))





local GlobalDataTable = {}
local function getGlobalDataTable(object)
	if (not object:FindFirstChild(".temp")) and object.Name ~= ".temp" and object.Name ~= ".savedata" then
		local objClassName = object.ClassName
		if tostring(string.sub(objClassName,#objClassName-4,#objClassName)) == "Value" then

			local CurrentParent 	= object
			local CurrentStructure	= {}
			local valueValue		= tostring(object.Value)

			if object:IsA("Color3Value") then
				valueValue = {object.Value.r,object.Value.g,object.Value.b}
			elseif object:IsA("Vector3Value") then
				valueValue = {object.Value.x,object.Value.y,object.Value.z}
			elseif object:IsA("IntConstrainedValue") then	
				valueValue = {object.Value,object.MinValue,object.MaxValue}
			elseif object:IsA("ObjectValue") then
				local ObjectStructure = {}
				local ObjectParent = object.Value

				coroutine.resume(coroutine.create(function()
					for i = 1,1000 do
						table.insert(ObjectStructure, 1, ObjectParent.Name)
						ObjectParent = ObjectParent.Parent
						if ObjectParent == game then
							break	
						end end	
				end))

				valueValue = ObjectStructure	
			end	


			for i = 1,100 do
				table.insert(CurrentStructure, 1, CurrentParent.Name)
				CurrentParent = CurrentParent.Parent
				if CurrentParent == StarterData then
					break	
				end end
			table.insert(GlobalDataTable, {valueValue,CurrentStructure,objClassName,object.Name})
		end
		for _, child in ipairs(object:GetChildren()) do
			getGlobalDataTable(child)
		end
	end
end

getGlobalDataTable(StarterData)
local ProfileStore = ProfileService.GetProfileStore(
	"PlayerDataVer"..DATASTOREVERSION,
	GlobalDataTable
)

local Profiles = {}



function SaveData(player)
	local CurrentDataTable 	= {}	

	local function getPlayerDataTable(object)
		if (not object:FindFirstChild(".temp")) and object.Name ~= ".temp" and object.Name ~= ".savedata" then
			local objClassName = object.ClassName
			if tostring(string.sub(objClassName,#objClassName-4,#objClassName)) == "Value" then

				local CurrentParent 	= object
				local CurrentStructure	= {}
				local valueValue		= tostring(object.Value)

				if object:IsA("Color3Value") then
					valueValue = {object.Value.r,object.Value.g,object.Value.b}
				elseif object:IsA("Vector3Value") then
					valueValue = {object.Value.x,object.Value.y,object.Value.z}
				elseif object:IsA("IntConstrainedValue") then	
					valueValue = {object.Value,object.MinValue,object.MaxValue}
				elseif object:IsA("ObjectValue") then
					local ObjectStructure = {}
					local ObjectParent = object.Value

					coroutine.resume(coroutine.create(function()
						for i = 1,1000 do
							table.insert(ObjectStructure, 1, ObjectParent.Name)
							ObjectParent = ObjectParent.Parent
							if ObjectParent == game then
								break	
							end end	
					end))

					valueValue = ObjectStructure	
				end	


				for i = 1,100 do
					table.insert(CurrentStructure, 1, CurrentParent.Name)
					CurrentParent = CurrentParent.Parent
					if CurrentParent == player then
						break	
					end end
				table.insert(CurrentDataTable, {valueValue,CurrentStructure,objClassName,object.Name})
			end
			for _, child in ipairs(object:GetChildren()) do
				getPlayerDataTable(child)
			end
		end
	end


	if player then
		for i,v in pairs(player:GetChildren()) do
			if v:FindFirstChild(".savedata") then
				getPlayerDataTable(v)	

			end
		end

		local FindProfile = Profiles[player]
		FindProfile.Data = CurrentDataTable
	end	
end

function StringToCFrame(String)
	local components = {}
	for Match in String:gmatch("[%d%.]+") do
		table.insert(components, tonumber(Match))
	end
	return unpack(components)
end

function FixValue(object,t)
	if object:IsA("Color3Value") then
		return Color3.new(unpack(t))	
	elseif object:IsA("Vector3Value") then
		return Vector3.new(unpack(t))
	elseif object:IsA("CFrameValue") then
		return CFrame.new(StringToCFrame(t))
	elseif object:IsA("BoolValue") then
		return tostring(t) == "true"	
	elseif object:IsA("ObjectValue") then
		local returnVal = nil
		local CurrentPosition 	= game
		for i = 1,#t do
			if CurrentPosition:FindFirstChild(t[i]) then
				CurrentPosition = CurrentPosition:FindFirstChild(t[i])
				if i == #t then
					returnVal = CurrentPosition
				end end	end	
		return returnVal
	else
		return t
	end		
end

game.Players.PlayerAdded:connect(function(player)
	
	local LoadedData = ProfileStore:LoadProfileAsync("Player_"..player.UserId)
	if not LoadedData then
		player:Kick()
	else	



		LoadedData:ListenToRelease(function()


			SaveData(player)
			Profiles[player] = nil
			player:Kick()
		end)
		if player:IsDescendantOf(game.Players) then
			Profiles[player] = LoadedData
		else
			LoadedData:Release()
		end
	end

	local newPlayerData 		= StarterData:Clone()
	for i,v in pairs(newPlayerData:GetChildren()) do
		local MakeSData = Instance.new("ObjectValue",v)
		MakeSData.Name = ".savedata"
	end
	local DataSentToPlayer = false
	coroutine.resume(coroutine.create(function()


		for _,LoadInfo in pairs(LoadedData["Data"]) do
			local CurrentPosition 	= newPlayerData
			for i = 1,#LoadInfo[2] do
				if CurrentPosition:FindFirstChild(LoadInfo[2][i]) then
					CurrentPosition 		= CurrentPosition:FindFirstChild(LoadInfo[2][i])
					if i == #LoadInfo[2] then
						if LoadInfo[3] == "IntConstrainedValue" then
							CurrentPosition.MinValue 	= LoadInfo[1][2]
							CurrentPosition.MaxValue 	= LoadInfo[1][3]
							CurrentPosition.Value 		= LoadInfo[1][1]
						else
							CurrentPosition.Value 	= FixValue(CurrentPosition,LoadInfo[1])
						end
					end else
					if i ~= #LoadInfo[2] then

					end 
				end 
			end
		end 
		for i,v in pairs(newPlayerData:GetChildren()) do
			v.Parent = player
		end
		DataSentToPlayer = true
	end))	
	coroutine.resume(coroutine.create(function() -- incase datastore machine [b]roke
		wait(5)
		if DataSentToPlayer == false then
			for i,v in pairs(newPlayerData:GetChildren()) do
				v.Parent = player
			end
		end
	end))
	Instance.new("BoolValue",player).Name = "SavesLoaded"
	player.CharacterAdded:connect(function(character)
		local Data = player:WaitForChild("Data")
		Data.ChildAdded:connect(function(child)
			if child.Name ~= ".savedata" then
				child:Destroy()
			end
		end)

	end) 



end)


game.ReplicatedStorage.Save.Event:Connect(function(Player)

	local Plr = game.Players:FindFirstChild(Player.Name)
	if Plr then

		SaveData(Plr)
	end
end)

spawn(function()
	while wait(AUTOSAVEPERIOD) do
		for _,v in pairs(game.Players:GetChildren()) do
			SaveData(v)	
			wait(.5)
		end	
	end
end)


game.Players.PlayerRemoving:Connect(function(player)



	local FindProfile = Profiles[player]
	if FindProfile then


		SaveData(player)
		FindProfile:Release()

	end
end)

