local DataHandler = {}
--local MarketPlaceService = game:GetService("MarketplaceService")

local ProfileTemplate = {
	Points = 100,
	Kills = 0,
	GamepassData = {},
	PermanentGears = {
		125013769,
	}
}

local ProfileService = require(game.ServerScriptService.Utils.ProfileService)
local BadgeService = game:GetService("BadgeService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ProfileStore = ProfileService.GetProfileStore("Dev_" .. _G.GameVersion, ProfileTemplate)



local Common = game.ServerScriptService.Common
local Shared = game.ReplicatedStorage.Shared

-- // MODULES
local PointHandler = require(Common.PointHandler)
local GearHandler = require(Common.GearHandler)
local KillLeaderboardHandler = require(Common.KillLeaderBoardHandler)
local GamepassHandler = require(Common.GamepassHandler)


local Profiles = {}
local DataHandler = {}

local function FirstJoin(player)
	print("First time joining, welcome!")
end 

local function InitiateStats(player, profile)
	local Data = profile.Data
	GearHandler.LoadData(player, Data.PermanentGears)
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local KillsValue = Instance.new("IntValue")
	KillsValue.Name = "Kills"
	KillsValue.Value = Data.Kills
	KillsValue.Parent = leaderstats

	PointHandler.LoadData(player, Data.Points)

	GamepassHandler.loadPlayerGamepasses(player, profile.Data.GamepassData)
	task.wait(1)
	GamepassHandler.checkForOwnedPasses(player)
end

local function PlayerAdded(player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)

	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()
		profile:ListenToRelease(function()
			Profiles[player] = nil
			-- The profile could've been loaded on another Roblox server:
			player:Kick("release fail PS1")
		end)

		if player:IsDescendantOf(Players) == true then
			Profiles[player] = profile
			InitiateStats(player, profile)
		else
			profile:Release()
		end
	else
		player:Kick("PS2")
	end
end

local function SaveData(player, profile)
	profile.Data.Points = PointHandler.FetchData(player)

	profile.Data.Kills = player.leaderstats.Kills.Value or -5
	KillLeaderboardHandler.UpdatePlayerKills(player, profile.Data.Kills)

	profile.Data.PermanentGears = GearHandler.FetchData(player, true)
end

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(PlayerAdded, player)
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	local profile = Profiles[player]
	if profile ~= nil then
		SaveData(player, profile)
		profile:Release()
	end
end)

return DataHandler
