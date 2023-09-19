local RunService = game:GetService("RunService")
local SwordEnemyClass = {}
SwordEnemyClass.__index = SwordEnemyClass

local NPC = require(script.Parent.NPC)

function SwordEnemyClass:MoveToTarget()
    print("Moving to target " .. " at " .. self.Target.Position)
end

function SwordEnemyClass:LookForTarget()
    print("Looking for target")
end

function SwordEnemyClass.New(name: string, health: number)
    local self = NPC.New(name, health)
    setmetatable(NPC, SwordEnemyClass)

    self.Name = name
    self.Health = health
    self.Target = nil

    self.RenderConnection = RunService.RenderStepped:Connect(function()
        if self.Target then
            self:MoveToTarget(self.Target)
        else
            self:DefualtWalkCycle() -- defualt walk cycle is a function in NPC
            self:LookForTarget()
        end
    end)

    return self
end

return SwordEnemyClass