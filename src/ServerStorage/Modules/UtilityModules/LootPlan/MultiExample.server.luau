-- Place this script in ServerScriptService, place the LootPlan module in ReplicatedStorage

local LootPlan = require(game.ReplicatedStorage.LootPlan)
local DropPlan = LootPlan.new('multi')

-- Add loot types to LootPlan (name, chance)
DropPlan:AddLoot("wizard hat", 0.1) -- 0.1% chance of receiving a wizard hat
DropPlan:AddLoot("dagger", 2) -- 2% chance of receiving a dagger
DropPlan:AddLoot("arrow", 10) -- 10% chance of receiving a arrows
DropPlan:AddLoot("gold coin", 80) -- 80% chance of receiving a gold coin

DropPlan:ChangeLootChance("dagger", 100) -- (name, newChance) example of changing chance to 100%

DropPlan:RemoveLoot("arrow") -- (name) example of removing loot

DropPlan:ChangeLootChance("gold coin", DropPlan:GetLootChance("gold coin") - 30) -- example of using GetLootChance to decrease the chance

-- For MultiLootPlans, GetRandomLoot returns a table of items received
print('- "multi" LootPlan example -')
local LootTable = DropPlan:GetRandomLoot(1000000) -- The argument is the number of iterations to run, each iteration adding more loot to the table. 
for LootName, LootQuantity in pairs(LootTable) do
	print(LootName,"=",LootQuantity) -- Displaying the loot table contents to output
end