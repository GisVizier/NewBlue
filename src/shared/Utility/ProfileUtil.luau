--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ProfileTemplate = require(ReplicatedStorage.Shared.Registry.ProfileTemplate)
local Replion = require(ReplicatedStorage.Packages.Replion)

export type ServerProfile = Replion.ServerReplion<ProfileTemplate.Data>
export type ClientProfile = Replion.ClientReplion<ProfileTemplate.Data>

local isClient = RunService:IsClient()

local function getClientProfile(): ClientProfile?
	return Players.LocalPlayer:GetAttribute("ProfileLoaded") and Replion.Client:GetReplion("Profile")
end

local function getServerProfile(player: Player): ServerProfile?
	return player:GetAttribute("ProfileLoaded") and Replion.Server:GetReplionFor(player, "Profile")
end

local ProfileUtil = {}

ProfileUtil.None = Replion.None

function ProfileUtil.getProfile(player: Player?): (ClientProfile | ServerProfile)?
	return (isClient and getClientProfile()) or (player and getServerProfile(player))
end

ProfileUtil.getClient = getClientProfile

function ProfileUtil.waitForClient(): ClientProfile
	if not Players.LocalPlayer:GetAttribute("ProfileLoaded") then
		Players.LocalPlayer:GetAttributeChangedSignal("ProfileLoaded"):Wait()
	end
	return Replion.Client:WaitReplion("Profile")
end

ProfileUtil.getServer = getServerProfile

function ProfileUtil.waitForServer(player: Player): ServerProfile?
	if not player:GetAttribute("ProfileLoaded") then
		player:GetAttributeChangedSignal("ProfileLoaded"):Wait()
	end
	return Replion.Server:WaitReplionFor(player, "Profile")
end

return ProfileUtil
