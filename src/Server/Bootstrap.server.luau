--!strict

local Services = {
	require(script.Services.DataService),
	require(script.Services.NotificationService),
	require(script.Services.AuthService),
	require(script.Services.FilterService),
	require(script.Services.PurchaseService),
	require(script.Services.CustomizationService),
	require(script.Services.RealmService),
}

for _, service in Services do
	service:Init()
end

for _, service in Services do
	service:Start()
end
