--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local WeldAndScale = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"):WaitForChild("WeldAndScale"))
local RaceConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("RaceConfig"))
local Net = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Net"))
local DataService = require(script.Parent.Parent.DataService)

local LootPlan = require(ServerStorage:WaitForChild("Modules"):WaitForChild("UtilityModules"):WaitForChild("LootPlan"))

local CustomizationMeshes = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("CustomizeMeshes")
local RaceAdditions = CustomizationMeshes:WaitForChild("RaceAdditions")

local RacePlan = LootPlan.new("single")
for name, weight in pairs(RaceConfig.Probabilities) do
	RacePlan:AddLoot(name, weight)
end

local spinDebounces: { [number]: boolean } = {}

local RaceHandler = {}

function RaceHandler.ApplyRaceAdditions(char: Model, raceType: string, bodyType: any)
	local raceAdditionsFolder = char:FindFirstChild("RaceAdditions")
	if not raceAdditionsFolder then
		raceAdditionsFolder = Instance.new("Folder")
		raceAdditionsFolder.Name = "RaceAdditions"
		raceAdditionsFolder.Parent = char
	end

	for _, v in raceAdditionsFolder:GetChildren() do
		v:Destroy()
	end

	local findRaceType = RaceAdditions:FindFirstChild(raceType)
	if findRaceType then
		local findBodyType = findRaceType:FindFirstChild(tostring(bodyType))
		if findBodyType then
			WeldAndScale.WeldAndScale({ Char = char, WeldReference = findBodyType, Parent = raceAdditionsFolder })
		end
	end
end

function RaceHandler.RandomBodyType(data: any): number
	local raceType = data.Data.CharacterData.Race.RaceType
	local findRace = RaceAdditions:FindFirstChild(raceType)
	if findRace then
		return math.random(1, #findRace:GetChildren())
	end
	return 0
end

function RaceHandler.RollRace(player: Player)
	local userId = player.UserId

	if spinDebounces[userId] then
		return
	end

	spinDebounces[userId] = true
	task.delay(RaceConfig.SPIN_DEBOUNCE_TIME, function()
		spinDebounces[userId] = nil
	end)

	local data = DataService.GetData(player)
	if not data then
		return
	end

	local spins = data.GamePasses.Products.RaceSpins
	if spins <= 0 then
		return
	end

	data.GamePasses.Products.RaceSpins = spins - 1

	local totalResults = {}
	for _ = 1, RaceConfig.SPIN_RESULT_COUNT do
		table.insert(totalResults, RacePlan:GetRandomLoot())
	end

	Net.fireClient("RaceRoll", player, totalResults)

	local chosenRace = totalResults[RaceConfig.SPIN_RESULT_INDEX]
	data.Data.CharacterData.Race.RaceType = chosenRace

	local newBodyType = 0
	local findRace = RaceAdditions:FindFirstChild(chosenRace)
	if findRace then
		newBodyType = math.random(1, #findRace:GetChildren())
	end
	data.Data.CharacterData.Race.BodyType = newBodyType
end

function RaceHandler.Init()
	Net.listen("RaceRoll", function(player: Player)
		RaceHandler.RollRace(player)
	end)
end

return RaceHandler
