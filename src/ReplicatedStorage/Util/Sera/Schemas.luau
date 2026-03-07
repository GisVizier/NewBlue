--!strict

--[[
	SeraSchemas.luau

	Centralized schema definitions for all network data in VastBlue.
	Each schema defines the exact structure and types for data sent over RemoteEvents.

	Usage:
		local Sera = require(script.Parent.Parent.Sera)
		local SeraSchemas = require(script.Parent.Parent.Sera.Schemas)

		-- Serialize
		local buf = Sera.Serialize(SeraSchemas.CharacterState, { ... })
		-- Deserialize
		local data = Sera.Deserialize(SeraSchemas.CharacterState, buf)
--]]

local Sera = require(script.Parent)

local SeraSchemas = {}

-- =============================================================================
-- CHARACTER REPLICATION
-- =============================================================================

-- Character State Replication (high frequency)
SeraSchemas.CharacterState = Sera.Schema({
	Position = Sera.Vector3, -- 12 bytes
	Rotation = Sera.Float32, -- 4 bytes (Y rotation in radians)
	Velocity = Sera.Vector3, -- 12 bytes
	Timestamp = Sera.Float64, -- 8 bytes
	IsGrounded = Sera.Boolean, -- 1 byte
	AnimationId = Sera.Uint8, -- 1 byte (animation enum)
	SequenceNumber = Sera.Uint16, -- 2 bytes (packet ordering)
	-- Total: 40 bytes
})

-- Delta Character State (for stationary/slow-moving characters)
SeraSchemas.CharacterStateDelta = Sera.Schema({
	Position = Sera.Vector3,
	Rotation = Sera.Float32,
	Velocity = Sera.Vector3,
	Timestamp = Sera.Float64,
	IsGrounded = Sera.Boolean,
	AnimationId = Sera.Uint8,
	SequenceNumber = Sera.Uint16,
})

-- =============================================================================
-- COMBAT SYSTEM
-- =============================================================================

-- Melee Hit (Client -> Server)
SeraSchemas.MeleeHit = Sera.Schema({
	Timestamp = Sera.Float64, -- 8 bytes
	Origin = Sera.Vector3, -- 12 bytes (attacker position)
	HitPosition = Sera.Vector3, -- 12 bytes (impact point)
	TargetUserId = Sera.Float64, -- 8 bytes (0 = NPC/environment)
	HitPart = Sera.Uint8, -- 1 byte (enum: None/Body/Head/Limb)
	AbilityId = Sera.Uint8, -- 1 byte (which attack/combo)
	-- Total: 42 bytes
})

-- Ability Activation (Client -> Server)
SeraSchemas.AbilityActivation = Sera.Schema({
	AbilityId = Sera.Uint8, -- 1 byte
	Timestamp = Sera.Float64, -- 8 bytes
	Position = Sera.Vector3, -- 12 bytes (cast position)
	DirectionX = Sera.Float32, -- 4 bytes
	DirectionY = Sera.Float32, -- 4 bytes
	DirectionZ = Sera.Float32, -- 4 bytes
	-- Total: 33 bytes
})

-- Ability VFX Replication (Server -> Clients)
SeraSchemas.AbilityReplicate = Sera.Schema({
	CasterUserId = Sera.Float64, -- 8 bytes
	AbilityId = Sera.Uint8, -- 1 byte
	Position = Sera.Vector3, -- 12 bytes
	DirectionX = Sera.Float32, -- 4 bytes
	DirectionY = Sera.Float32, -- 4 bytes
	DirectionZ = Sera.Float32, -- 4 bytes
	-- Total: 33 bytes
})

-- Damage Number (Server -> Client)
SeraSchemas.DamageNumber = Sera.Schema({
	Position = Sera.Vector3, -- 12 bytes (world position for popup)
	Damage = Sera.Float32, -- 4 bytes
	IsCritical = Sera.Boolean, -- 1 byte
	DamageType = Sera.Uint8, -- 1 byte (enum: Physical/Elemental/True)
	-- Total: 18 bytes
})

-- =============================================================================
-- ANIMATION / STATE
-- =============================================================================

-- Animation State Change
SeraSchemas.AnimationState = Sera.Schema({
	PlayerUserId = Sera.Uint32, -- 4 bytes
	AnimationName = Sera.String8, -- 1 + length bytes
	Category = Sera.String8, -- 1 + length bytes
	VariantIndex = Sera.Uint8, -- 1 byte
})

-- NPC State Change
SeraSchemas.NPCState = Sera.Schema({
	NPCName = Sera.String8, -- 1 + length bytes
	State = Sera.Uint8, -- 1 byte
})

-- =============================================================================
-- WORLD / MISC
-- =============================================================================

-- Sound Request
SeraSchemas.SoundRequest = Sera.Schema({
	SoundName = Sera.String8, -- 1 + length bytes
	Position = Sera.Vector3, -- 12 bytes
	Volume = Sera.Float32, -- 4 bytes
})

-- Server Correction (anti-cheat reconciliation)
SeraSchemas.ServerCorrection = Sera.Schema({
	Position = Sera.Vector3, -- 12 bytes
	Velocity = Sera.Vector3, -- 12 bytes
	Timestamp = Sera.Float64, -- 8 bytes
	-- Total: 32 bytes
})

-- =============================================================================
-- ENUM MAPPINGS
-- =============================================================================

SeraSchemas.Enums = {
	-- Hit Part (for combat)
	HitPart = {
		None = 0,
		Body = 1,
		Head = 2,
		Limb = 3,
	},

	-- Damage Types
	DamageType = {
		Physical = 0,
		Elemental = 1,
		True = 2,
	},
}

-- Reverse lookup tables for deserialization
SeraSchemas.EnumNames = {}

for enumName, enumTable in pairs(SeraSchemas.Enums) do
	SeraSchemas.EnumNames[enumName] = {}
	for name, value in pairs(enumTable) do
		SeraSchemas.EnumNames[enumName][value] = name
	end
end

return SeraSchemas
