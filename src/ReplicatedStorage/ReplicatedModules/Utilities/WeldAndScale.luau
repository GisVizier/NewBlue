

local function CalcSizeOffset(Vector3Value,Char)

	local hum = Char:WaitForChild("Humanoid")

	local DepthScale = hum:WaitForChild("BodyDepthScale")
	local HeightScale = hum:WaitForChild("BodyHeightScale")
	local WidthScale = hum:WaitForChild("BodyWidthScale")

	local Y = Vector3Value.Y * HeightScale.Value
	local Z = Vector3Value.Z * DepthScale.Value
	local X = Vector3Value.X * WidthScale.Value

	local NewVector = Vector3.new(X,Y,Z)

	return NewVector
end

local function ScaleWeld(Weld,Char)
	
	local hum = Char:WaitForChild("Humanoid")

	local DepthScale = hum:WaitForChild("BodyDepthScale")
	local HeightScale = hum:WaitForChild("BodyHeightScale")
	local WidthScale = hum:WaitForChild("BodyWidthScale")
	
	if Weld:IsA("Bone") then
		local Y = (Weld.Position.Y * HeightScale.Value)
		local Z = (Weld.Position.Z * DepthScale.Value)
		local X= (Weld.Position.X * WidthScale.Value)
		Weld.Position = Vector3.new(X,Y,Z)
	else
		
	


		local Y0 = (Weld.C0.Position.Y * HeightScale.Value)
		local Z0 = (Weld.C0.Position.Z * DepthScale.Value)
		local X0 = (Weld.C0.Position.X * WidthScale.Value)
		local RX0,RY0,RZ0 = Weld.C0:ToOrientation()


		local Y1 = (Weld.C1.Position.Y * HeightScale.Value)
		local Z1 = (Weld.C1.Position.Z * DepthScale.Value)
		local X1 = (Weld.C1.Position.X * WidthScale.Value)
		local RX1,RY1,RZ1 = Weld.C1:ToOrientation()





		Weld.C0 = CFrame.new(X0,Y0,Z0) * CFrame.Angles(RX0,RY0,RZ0)
		Weld.C1 = CFrame.new(X1,Y1,Z1) * CFrame.Angles(RX1,RY1,RZ1)
	end

	

end

local module = {




	WeldAndScale = function(Params)
		
		local Char = Params.Char
		local NoScale = Params.NoScale
		local WeaponWeldBool = Params.WeaponWeldBool
		local Name = Params.Name
		local WeldReference = Params.WeldReference
		local Parent = Params.Parent
	
		

		
		local hum = Char:WaitForChild("Humanoid")

		
		local DepthScale = hum:WaitForChild("BodyDepthScale")
		local HeightScale = hum:WaitForChild("BodyHeightScale")
		local WidthScale = hum:WaitForChild("BodyWidthScale")
		

		local HasBone = false
		local NewModel = WeldReference:Clone()
		
		for i,v in pairs(NewModel:GetDescendants())do
			if v:IsA("Bone") then
				HasBone = true
			end
		end
		
		for i,v in pairs(NewModel:GetDescendants())do
			if v:IsA("BasePart") then
				v.CanCollide = false
				v.Anchored = false
				v.CanQuery = false
				v.Massless = true
				v:SetAttribute("Transparency",v.Transparency)
				v:SetAttribute("Material",string.split(tostring(v.Material),".")[3])
				v:SetAttribute("OriginalTransparency",v.Transparency)
			end
		end
	
	
		
		for i,v in pairs(NewModel:GetChildren())do
			local FindBodyPart = Char:FindFirstChild(v.Name) 
			if FindBodyPart and v:IsA("Model") then
				
				local PrimaryPart = v.PrimaryPart 

				for i,e in pairs(v:GetChildren())do
					if e:IsA("BasePart") and e~= PrimaryPart then
						
						
						if FindBodyPart.Name ~= "Head" then
							if not NoScale then
								local OffsetSize = CalcSizeOffset(e.Size,Char)

								e.Size = OffsetSize
						
							end
								e.CanCollide = false
								e.Anchored = false
								e.Massless = true
								e.CanQuery = false
					
						
						end
						
					end
				end
				
				if PrimaryPart then
					
				
					local FindAccessoryWeld = PrimaryPart:FindFirstChildOfClass("Motor6D") or PrimaryPart:FindFirstChildOfClass("Weld")
					if FindAccessoryWeld or WeaponWeldBool then
						
						if WeaponWeldBool then
							
						
							
							local Motor6D = PrimaryPart:FindFirstChildOfClass("Motor6D")
							
							
								
							if not Motor6D  then
								
								Motor6D = Instance.new("Motor6D")
								Motor6D.Parent = FindBodyPart
								Motor6D.Part0 = FindBodyPart
								Motor6D.Part1 = PrimaryPart
								ScaleWeld(Motor6D,Char)
								
							else
						
								Motor6D:Clone()
					
								Motor6D.Part0 = FindBodyPart
								Motor6D.Part1 = PrimaryPart
								Motor6D.Parent = FindBodyPart
								Motor6D.Name = "Motor6D"
							
								ScaleWeld(Motor6D,Char)
							end
					
							
						else
						
							local AccessoryWeld = FindAccessoryWeld:Clone()
							FindAccessoryWeld:Destroy()
							if FindBodyPart.Name ~= "Head" then
						
								ScaleWeld(AccessoryWeld,Char)
							end

							AccessoryWeld.Name = "AccessoryWeld"
							AccessoryWeld.Parent = PrimaryPart
							if FindAccessoryWeld.Name == PrimaryPart.Name then

								AccessoryWeld.Part0 = FindBodyPart
								AccessoryWeld.Part1 = PrimaryPart
							else
							
								AccessoryWeld.Part0 = PrimaryPart
								AccessoryWeld.Part1 = FindBodyPart
							end
						end
						
						
					
				
					
						
						for i,e in pairs(v:GetChildren())do
							if FindBodyPart.Name ~= "Head" then
							local FindWeld = e:FindFirstChildOfClass("Motor6D") or e:FindFirstChildOfClass("Weld")
							if FindWeld then
									if not HasBone then
									
										if not NoScale then
											ScaleWeld(FindWeld,Char)
										end
										
									end
								end
							end
						end
						
					end
					
				else
					
					for i,e in pairs(v:GetDescendants())do
						if e:IsA("BasePart") then
							
						
						local FindWeld = e:FindFirstChildOfClass("Motor6D") or e:FindFirstChildOfClass("Weld")
						local WeldClone = FindWeld:Clone()
						FindWeld:Destroy()
						WeldClone.Parent = e
						WeldClone.Part0 = e
						WeldClone.Part1 = FindBodyPart

						if FindBodyPart.Name ~= "Head" then

							if WeldClone then
								ScaleWeld(WeldClone,Char)
							end
						end
					end
					end
				end
				
		
			end
		end
		
		if Name then
			NewModel.Name = Name
		end
		
		NewModel.Parent = Parent
		
	

		return NewModel
		--end
	end,






}

return module
