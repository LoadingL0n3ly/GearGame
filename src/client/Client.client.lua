--  _____ _ _            _      _____           _       _    
-- / ____| (_)          | |    / ____|         (_)     | |   
-- | |    | |_  ___ _ __ | |_  | (___   ___ _ __ _ _ __ | |_  
-- | |    | | |/ _ \ '_ \| __|  \___ \ / __| '__| | '_ \| __| 
-- | |____| | |  __/ | | | |_   ____) | (__| |  | | |_) | |_  
-- \_____|_|_|\___|_| |_|\__| |_____/ \___|_|  |_| .__/ \__| 
--                                               | |         
--                                               |_|         
-- Property of Rodef Games; Written by Fedor Khaldin 
-- If you decompiled this you should go outside more often.


-- CODE UP HERE IS FIRST THING TO RUN; AVOID PUTTING STUFF HERE 
workspace.ChildAdded:Connect(function(child: BasePart)
    
end)



local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local timeStart = tick()

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

local Common = ReplicatedStorage:WaitForChild("Shared")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- // REMOTES

-- // MODULES
local UI = require(ReplicatedStorage.UI)
local DeathHandler = require(Common.DeathHandler)
local FallDamageHandler = require(Common.FallDamageHandler)
local ChatHandler = require(Common.ChatClient)

-- // SETUP
if not game:IsLoaded() then
	game.Loaded:Wait()
end

UI.Setup()

-- // FUNCTIONS
local function CharacterAdded(character)
    FallDamageHandler.CharAdded(character)
end

-- // CONNECTIONS
TextChatService.OnIncomingMessage = ChatHandler.OnIncomingMessage

if Player.Character then CharacterAdded(Player.Character) end
Player.CharacterAdded:Connect(CharacterAdded)

Player.CharacterRemoving:Connect(function(character)
      
end)

RunService.RenderStepped:Connect(function(deltaTime)
   UI.RenderStepped()
end)


print("✅ Loaded Client in " .. math.floor((tick() - timeStart) * 1000) .. " ms")