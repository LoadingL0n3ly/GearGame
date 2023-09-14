local timeStart = tick()
_G.GameVersion = 0.03

-- // SERVICES
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- // FOLDERS
local Common = ServerScriptService.Common
local Shared = game.ReplicatedStorage.Shared
local Remotes = game.ReplicatedStorage.Remotes

-- // MODULES
local DataHandler = require(Common.DataHandler)
local GearHandler = require(Common.GearHandler)

-- // REMOTE EVENTS

-- // WORLD SETUP

-- // SETUP

-- // TABLES
local PlayerConnections = {}

-- // MISC


-- // FUNCTIONS
local function CharacterAdded(char)
	local Player = Players:GetPlayerFromCharacter(char) if not Player then return end
    GearHandler.CharAdded(char)
end

local function CharacterRemoving(char) 
	local Player = Players:GetPlayerFromCharacter(char) if not Player then return end

end

local function PlayerAdded(player: Player)
	PlayerConnections[player] = {}

	PlayerConnections[player]["CharAdded"] = player.CharacterAdded:Connect(CharacterAdded)
	PlayerConnections[player]["CharRemoving"] = player.CharacterRemoving:Connect(CharacterRemoving)
end

-- // CONNECTIONS
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(PlayerAdded, player)
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	-- Clear Connections
	local Connections = PlayerConnections[player] if not Connections then return end
	for index, connection in Connections do
		connection:Disconnect()
	end

	PlayerConnections[player] = nil
end)

RunService.Stepped:Connect(function(time, deltaTime)

end)

print("🏁 Loaded Server v." .. _G.GameVersion .. " in " .. math.floor((tick() - timeStart) * 1000) .. " ms")