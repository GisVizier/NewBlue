

local module = {

	BindAnimPlayer = function(Item)
		
		local function PlayAnim()
			wait(2)
			local AnimController = Item:WaitForChild("AnimationController")
			local LoadAnim = AnimController:LoadAnimation(Item:FindFirstChild("Animation",true))
			LoadAnim:Play()
			print(LoadAnim)
		end
		
		PlayAnim()
		Item:GetPropertyChangedSignal("Parent"):Connect(function()
			PlayAnim()
		end)
	end,




}

return module
