--!strict

local CURRENT_VERSION = 1

local Migrations: { [number]: (data: any) -> () } = {}

-- Example future migration:
-- Migrations[1] = function(data)
--     data.Data.SomeNewField = "default"
-- end

local DataMigrations = {}

function DataMigrations.Run(data: any)
	if not data._version then
		data._version = 0
	end

	while data._version < CURRENT_VERSION do
		local nextVersion = data._version + 1
		local migrator = Migrations[nextVersion]
		if migrator then
			migrator(data)
		end
		data._version = nextVersion
	end
end

return DataMigrations
