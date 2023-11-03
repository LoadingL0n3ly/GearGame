local ServerScriptService = game:GetService("ServerScriptService")
local Common = ServerScriptService.Common

local Swordsman = require(Common.NPC.Swordsman)
print("Creating a swordsman!")
local guy = Swordsman.New("Bob", 100, Vector3.new(-96.3, 120, -397.1))

task.wait(2)
guy:PathTo()