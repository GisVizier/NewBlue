-- Place this script in ServerScriptService, place the LootPlan module in ReplicatedStorage

-- For SingleLootPlans, Chance is measured relative to the combined chance values of other loot entries. 
-- Example; If you have 2 loot entries, one with 5 chance, and the other with 15 chance, loot one has a 25% chance of being selected.
-- This is because 5(individual chance)/20(combined chance) = 0.25

local LootPlan = require(game.ReplicatedStorage.LootPlan)

-- Create new LootPlan with the class "single"
local OrePlan = LootPlan.new('single')

-- Add loot types to LootPlan (name,chance)
OrePlan:AddLoot("diamond",0.01)
OrePlan:AddLoot("gold",2)
OrePlan:AddLoot("iron",10)
OrePlan:AddLoot("stone",100)

--[[
	Still confused on how the chance works? 
	
	To get the true chance of an item, simply add up all of the loot rarities, 
	and then divide the specific loot chance by the total loot chance.
	
	The total in this example is 112.01 (100+10+2+0.01), so iron has a true chance of 10/112.01 = 8.927%
--]]

local test = {} -- This is a table we're using to gather the results of the LootPlan

for i = 1,1000000 do -- One million iterations to show it's efficient
	-- For SingleLootPlans, GetRandomLoot() returns a single random loot based on chance, and returns it's name
    local result = OrePlan:GetRandomLoot()
    test[result] = test[result] and test[result]+1 or 1 -- Gathering the test results
end

print'- "single" LootPlan example -'
for LootName, LootQuantity in pairs(test) do
	print(LootName,"=",LootQuantity) -- Displaying the test results to output
end