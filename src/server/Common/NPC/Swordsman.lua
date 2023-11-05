local RunService = game:GetService("RunService")
local Swordsman = {}
Swordsman.__index = Swordsman

local NPC = require(script.Parent)
setmetatable(Swordsman, NPC)

local Players = game.Players
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gears = ReplicatedStorage:WaitForChild("Gears")

local Sword = Gears:WaitForChild("LinkedSword")

local DISTANCE_THRESHOLD = 20
local ATTACK_THRESHOLD = 5


function Swordsman:MoveToTarget()
    if not self.EnemyTarget then self.EnemyTarget = nil self:ReturnToPilot() return end
    if not self.EnemyTarget.HumanoidRootPart then self.EnemyTarget = nil self:ReturnToPilot() return end

    if self.EnemyTarget.Humanoid then
        if self.EnemyTarget.Humanoid.Health <= 0 then
            self.EnemyTarget = nil
            self:ReturnToPilot()
            return
        end
    else
        self.EnemyTarget = nil
        self:ReturnToPilot()
        return
    end

    local Distance = (self.EnemyTarget.HumanoidRootPart.Position - self.Character.HumanoidRootPart.Position).Magnitude
    if Distance > DISTANCE_THRESHOLD then
        self.EnemyTarget = nil
        self:ReturnToPilot()
        return
    end

    if Distance <= ATTACK_THRESHOLD then
        self.Sword.Trigger:Fire()
    end

    self:PathTo(self.EnemyTarget.HumanoidRootPart)
end

function Swordsman:LookForTarget()
    for _, player in Players:GetPlayers() do
        local Character = player.Character
        if not Character then continue end

        local Humanoid = Character.Humanoid
        if not Humanoid then continue end

        if Humanoid.Health <= 0 then continue end

        local PrimaryPart = Character.HumanoidRootPart
        if not PrimaryPart then continue end

        local Distance = (PrimaryPart.Position - self.Character.HumanoidRootPart.Position).Magnitude
        if Distance <= DISTANCE_THRESHOLD  then
            self.EnemyTarget = Character
            break
        end
    end
end



function Swordsman.New(name: string, health: number, RespawnTime: number,StartPos: Vector3)
    if not StartPos then
        StartPos = Swordsman.GetRandomSpawn().Position + Vector3.new(0, 5, 0)
    end
    
    print(`Creating Swordsman {name} at {StartPos} with {health} health`)
    local self = NPC.New(name, StartPos, "Swordsman")
    setmetatable(self, Swordsman)

    self.Name = name
    self.EnemyTarget = nil

    self.Sword = Sword:Clone()
    local Humanoid: Humanoid = self.Character.Humanoid
    Humanoid:EquipTool(self.Sword)

    self.Checking = false

    self.Connections["Stepped"] = RunService.Stepped:Connect(function()
        if self.EnemyTarget then
            self:MoveToTarget()
            self.Character.Head.Alert.Enabled = true
        else
            self:LookForTarget()
            self.Character.Head.Alert.Enabled = false
        end


        if self.Checking then return end 
        if self.Character.HumanoidRootPart.AssemblyLinearVelocity.Magnitude <= 2 then
            self.Checking = true
            task.delay(4, function()
                if self.Character.HumanoidRootPart.AssemblyLinearVelocity.Magnitude <= 2 then
                    self.Character.HumanoidRootPart.AssemblyLinearVelocity += Vector3.new(0, 10, 0.1)
                    self.Pathfinding.Target = Swordsman.GetRandomSpawn(self.Pathfinding.Target)
                    self.Pathfinding.Path:Run(self.Pathfinding.Target)
                end

                self.Checking = false
            end)
        end
    end)

    self.Connections["Respawn"] = self.Character.Humanoid.Died:Connect(function()
        if RespawnTime then
            task.delay(RespawnTime, function()
                self = Swordsman.New(name, health, RespawnTime)
            end)
        end
    end)

    return self
end

return Swordsman