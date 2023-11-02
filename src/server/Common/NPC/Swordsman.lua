local RunService = game:GetService("RunService")
local Swordsman = {}
Swordsman.__index = Swordsman

local NPC = require(script.Parent)
setmetatable(Swordsman, NPC)


function Swordsman:MoveToTarget()
    print("Moving to target " .. " at " .. self.Target.Position)
end

function Swordsman:LookForTarget()
    print("Looking for target")
end

function Swordsman.New(name: string, health: number, StartPos: Vector3)
    print(`Creating Swordsman {name} at {StartPos} with {health} health`)
    local self = NPC.New(name, StartPos, "Swordsman")
    setmetatable(self, Swordsman)

    self.Name = name
    self.Target = nil

    self.RenderConnection = RunService.Stepped:Connect(function()
        if self.Target then
            self:MoveToTarget(self.Target)
        else
            self:DefaultWalkCycle() -- defualt walk cycle is a function in NPC
            self:LookForTarget()
        end
    end)

    return self
end

return Swordsman