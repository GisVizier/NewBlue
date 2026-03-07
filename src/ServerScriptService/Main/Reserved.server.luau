local MessagingService =game:GetService("MessagingService")
local ActivePlayers = game:GetService("ReplicatedStorage"):WaitForChild("RealmData"):WaitForChild("Active Players")
local ReservedID = game:GetService("ReplicatedStorage"):WaitForChild("RealmData"):WaitForChild("ReservedID")

local LastRecieved = 0
MessagingService:SubscribeAsync("PlayerUpdate",function(message)

	local Data = game:GetService("HttpService"):JSONDecode(message.Data)
	
	local Players= Data.Players
	local Reserved = Data.Reserved
	

	
	if ReservedID.Value == Reserved then
		ActivePlayers.Value = #Players

		LastRecieved = tick()

	end
end)


while wait(20) do
	local PassedTime = tick() - LastRecieved
	
	if PassedTime > 20 then
		ActivePlayers.Value = 0
	end
	
end