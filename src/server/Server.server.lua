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
local PointHandler = require(Common.PointHandler)
local DeathHandler = require(Shared.DeathHandler)
local ChatHandler = require(Common.ChatHandler)
local MapHandler = require(Common.MapHandler)
local KillLeaderBoardHandler = require(Common.KillLeaderBoardHandler)
local SoftShutdown = require(Common.SoftShutdown)
local GamepassHandler = require(Common.GamepassHandler)

GamepassHandler.Setup()
-- // REMOTE EVENTS

-- // WORLD SETUP

-- // SETUP
GearHandler.Setup()
KillLeaderBoardHandler.UpdateLeaderBoard()


-- // TABLES
local PlayerConnections = {}

-- // MISC


-- // FUNCTIONS
local function CharacterAdded(char)
	local Player = Players:GetPlayerFromCharacter(char) if not Player then return end
    GearHandler.CharAdded(char)
	DeathHandler.CharacterAdded(char)
	char.Parent = workspace.Characters

	local Humanoid:Humanoid = char:WaitForChild("Humanoid")

	-- PlayerConnections[Player]["Death"] = Humanoid.Died:Connect(function()
	-- 	DeathHandler.CharDied(char)
	-- end)
end

local function CharacterRemoving(char) 
	local Player = Players:GetPlayerFromCharacter(char) if not Player then return end
	-- PlayerConnections[Player]["Death"]:Disconnect()
end

local function PlayerAdded(player: Player)
	ChatHandler.playerJoined(player.Name)
	
	PlayerConnections[player] = {}

	PlayerConnections[player]["CharAdded"] = player.CharacterAdded:Connect(CharacterAdded)
	if player.Character then
		task.spawn(CharacterAdded, player.Character)
	end
	PlayerConnections[player]["CharRemoving"] = player.CharacterRemoving:Connect(CharacterRemoving)
end

-- // CONNECTIONS
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(PlayerAdded, player)
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	ChatHandler.playerLeft(player.Name)
	
	-- Clear Connections
	local Connections = PlayerConnections[player] 
	if not Connections then return end

	for index, connection in Connections do
		connection:Disconnect()
	end

	PlayerConnections[player] = nil
end)

local function HumanoidAdded(humanoid)
	humanoid:AddTag("tagged")
	local connection = nil

	connection = humanoid.Died:Connect(function()
		DeathHandler.CharDied(humanoid.Parent)
		connection:Disconnect()
		connection = nil
	end)
end

local function SuperAnchor(part:BasePart)
	local CFrame = part.CFrame

	part:GetPropertyChangedSignal("Anchored"):Connect(function()
		part.Anchored = true
	end)
end

workspace.DescendantAdded:Connect(function(descendant)
	if descendant:HasTag("SuperAnchor") then SuperAnchor(descendant) end
	
	if descendant:IsA("Humanoid") and not descendant:HasTag("tagged") then
		HumanoidAdded(descendant)
	end
end)

for _, descendant in workspace:GetDescendants() do
	if descendant:HasTag("SuperAnchor") then SuperAnchor(descendant) end
	if descendant:IsA("Humanoid") and not descendant:HasTag("tagged") then
		HumanoidAdded(descendant)
	end
end

local lastTip = 0
-- Every Game Second
task.spawn(function()
	while task.wait(1) do
		MapHandler.Tick()

		if tick() - lastTip >= math.random(90, 450) then
			ChatHandler.sendTip()
			lastTip = tick()
		end
	end
end)

RunService.Stepped:Connect(function(time, deltaTime)
	PointHandler.Stepped()
end)

print("🏁 Loaded Server v." .. _G.GameVersion .. " in " .. math.floor((tick() - timeStart) * 1000) .. " ms")