--!strict

-- Client bootstrap
-- Controllers that need to run as StarterCharacterScripts remain in StarterCharacterScripts/
-- Controllers here run as StarterPlayerScripts (persist across respawns)

local Controllers = {
	require(script.Controllers.CameraController),
	require(script.Controllers.WindController),
}

for _, controller in Controllers do
	if controller.Init then
		controller:Init()
	end
end

for _, controller in Controllers do
	if controller.Start then
		controller:Start()
	end
end
