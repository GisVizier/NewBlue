local rp = game:GetService("ReplicatedStorage")
local ReplicatedModules = rp:WaitForChild("ReplicatedModules")
local Remotes = rp:WaitForChild("Remotes")
local RichTextClient = Remotes:WaitForChild("RichText")

local module = {

	Notify = function(Player,Text,NotifyType)
		print(Player)
		print(Text)
		print(NotifyType)
	if NotifyType == "Normal" then
		local PlayerGui = Player:WaitForChild("PlayerGui")
		local NotificationGui = PlayerGui:WaitForChild("Notification")
		local LayoutFrame = NotificationGui:WaitForChild("Layout")
		local Templates = LayoutFrame:WaitForChild("Templates")
		local Template = Templates:WaitForChild("Template")
		
		local TextClone = Template:Clone()
		TextClone.Parent = LayoutFrame
		TextClone.Visible = true
		TextClone.Name = "Notify1"
		for i,v in pairs(LayoutFrame:GetChildren())do
			if v:IsA("TextLabel") then
					
				v.LayoutOrder = v.LayoutOrder + 1	
			end
			
		end
		RichTextClient:FireClient(Player,TextClone,Text,"Center","Wiggle",100,0.1,0.1,false,false,1,"Center","GothamBold",22)
		game.Debris:AddItem(TextClone,3.5)
		end
		
		if NotifyType == "Negative" then
			local PlayerGui = Player:WaitForChild("PlayerGui")
			local NotificationGui = PlayerGui:WaitForChild("Notification")
			local LayoutFrame = NotificationGui:WaitForChild("Layout")
			local Templates = LayoutFrame:WaitForChild("Templates")
			local Template = Templates:WaitForChild("Template")

			local TextClone = Template:Clone()
			TextClone.Parent = LayoutFrame
			TextClone.Visible = true
			TextClone.Name = "Notify1"
			for i,v in pairs(LayoutFrame:GetChildren())do
				if v:IsA("TextLabel") then
					v.LayoutOrder = v.LayoutOrder + 1	
				end

			end
			RichTextClient:FireClient(Player,TextClone,"<Color=Red>"..Text,"Center","Wiggle",100,0.1,0.1,false,false,1,"Center","GothamBold",22)
			game.Debris:AddItem(TextClone,3.5)
		end
		
		if NotifyType == "Positive" then
			local PlayerGui = Player:WaitForChild("PlayerGui")
			local NotificationGui = PlayerGui:WaitForChild("Notification")
			local LayoutFrame = NotificationGui:WaitForChild("Layout")
			local Templates = LayoutFrame:WaitForChild("Templates")
			local Template = Templates:WaitForChild("Template")

			local TextClone = Template:Clone()
			TextClone.Parent = LayoutFrame
			TextClone.Visible = true
			TextClone.Name = "Notify1"
			for i,v in pairs(LayoutFrame:GetChildren())do
				if v:IsA("TextLabel") then
					v.LayoutOrder = v.LayoutOrder + 1	
				end

			end
			RichTextClient:FireClient(Player,TextClone,"<Color=Green>"..Text,"Center","Wiggle",100,0.1,0.1,false,false,1,"Center","GothamBold",22)
			game.Debris:AddItem(TextClone,3.5)
		end
		
		if NotifyType == "Rainbow" then
			local PlayerGui = Player:WaitForChild("PlayerGui")
			local NotificationGui = PlayerGui:WaitForChild("Notification")
			local LayoutFrame = NotificationGui:WaitForChild("Layout")
			local Templates = LayoutFrame:WaitForChild("Templates")
			local Template = Templates:WaitForChild("Template")

			local TextClone = Template:Clone()
			TextClone.Parent = LayoutFrame
			TextClone.Visible = true
			TextClone.Name = "Notify1"
			for i,v in pairs(LayoutFrame:GetChildren())do
				if v:IsA("TextLabel") then
					v.LayoutOrder = v.LayoutOrder + 1	
				end

			end
			RichTextClient:FireClient(Player,TextClone,Text,"Center","Rainbow",1,1,1,false,false,1,"Center","GothamBold",22)
			game.Debris:AddItem(TextClone,3.5)
		end
		
		
	end,
	
	
	
	

}

return module
