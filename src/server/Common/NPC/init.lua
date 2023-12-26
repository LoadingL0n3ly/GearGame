local class = {}
-- Services
local SimplePath = require(script.SimplePath)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NPCs = ReplicatedStorage.NPCs
class.__index = class

local Storage = Instance.new("Folder")
Storage.Name = "NPCs"
Storage.Parent = workspace


-- Util
local SpawnFolder = workspace:WaitForChild("Spawns")

-- Standard Animations
local Animations = {
    Climbing = "http://www.roblox.com/asset/?id=10921257536",
    Jumping = "http://www.roblox.com/asset/?id=10921263860",
    Freefall = "http://www.roblox.com/asset/?id=10921262864",
    Running = "http://www.roblox.com/asset/?id=10921269718",
}

for key, id in pairs(Animations) do
    Animations[key] = Instance.new("Animation")
    Animations[key].AnimationId = id
end


function class.GetRandomSpawn(currentTarget)
    local target = nil

    repeat
        target = SpawnFolder:GetChildren()[math.random(1, #SpawnFolder:GetChildren())]
    until target ~= currentTarget

    return target
end


-- Pathfinding 
function class:PathTo(target: Part)
   self.Pathfinding.Override = true

--    if self.Pathfinding.Target == target then
--        return
--    end

   self.Pathfinding.Target = target
   self.Pathfinding.Path:Run(target)
end

function class:ReturnToPilot()
    self.Pathfinding.Override = false
    self.Pathfinding.Target = class.GetRandomSpawn(self.Pathfinding.Target)
    self.Pathfinding.Path:Run(self.Pathfinding.Target)
end

function class.New(Name: string, StartPos: Vector3 , Type: string)
    local self = {}
    setmetatable(self, class)

    local Char = NPCs:FindFirstChild(Type) assert(Char, `NPC type {Type} does not exist`)
    self.Character = Char:Clone()

    self.Character.Name = Name
    self.Character.HumanoidRootPart.Position = StartPos
    self.Character.Parent = Storage

    -- Connections
    self.Animations = Animations
    self.Connections = {}

    -- Pathfinding Stuff
    self.Pathfinding = {
        Override = false,
        Target = class.GetRandomSpawn(),
    }

    self.Pathfinding.Path = SimplePath.new(self.Character)
    self.Pathfinding.Path.Visualize = false
    self.Pathfinding.Path:Run(self.Pathfinding.Target, {AgentCanClimb = true})

    -- Pathfinding Events
    self.Connections["PathBlocked"] = self.Pathfinding.Path.Blocked:Connect(function()
       --print("Path Blocked, Recalculating!")
       self.Pathfinding.Path:Run(self.Pathfinding.Target)
    end)

    self.Connections["PathError"] = self.Pathfinding.Path.Error:Connect(function(errorType)
        --print("Path Error, Recalculating!")
        self.Pathfinding.Path:Run(self.Pathfinding.Target)
    end)

    self.Connections["PathReached"] = self.Pathfinding.Path.Reached:Connect(function()
        --print("Reached Target, Recalculating!")
        if not self.Pathfinding.Override then
            self.Pathfinding.Target = class.GetRandomSpawn(self.Pathfinding.Target)
            self.Pathfinding.Path:Run(self.Pathfinding.Target)
        end
    end)

    -- Animation Setup

    local Humanoid: Humanoid = self.Character.Humanoid

    self.Connections["animation"] = Humanoid.StateChanged:Connect(function(oldState, newState)
        for i,v in pairs(Humanoid:GetPlayingAnimationTracks()) do
            v:Stop()
        end
           
        if newState == Enum.HumanoidStateType.Climbing then
            Humanoid:LoadAnimation(self.Animations.Climbing):Play()
        elseif newState == Enum.HumanoidStateType.Jumping then
            Humanoid:LoadAnimation(self.Animations.Jumping):Play()
        elseif newState == Enum.HumanoidStateType.Freefall then
            Humanoid:LoadAnimation(self.Animations.Freefall):Play()
        elseif newState == Enum.HumanoidStateType.Running then
            Humanoid:LoadAnimation(self.Animations.Running):Play()
        end
    end)

    self.Connections["died"] = Humanoid.Died:Connect(function()
        self:Destroy()
    end)

    return self
end

function class:Destroy(instant: boolean)
    --print("Destroyin!")

    for _, connection in pairs(self.Connections) do
        connection:Disconnect()
    end

    if instant then
        self.Character:Destroy()
        return
    end
    
    task.delay(7, function()
        self.Character:Destroy()
    end)
end


return class