local class = {}
-- Services
local PathfindingService = game:GetService("PathfindingService")

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

function GetRandomSpawn()
    return SpawnFolder:GetChildren()[math.random(1, #SpawnFolder:GetChildren())]
end


-- Pathfinding 
function class:PathTo(target: Part)
    print("Recalculating Path!!!!!")
    local Data = self.Pathfinding

    if Data.reachedConnection then
        Data.reachedConnection:Disconnect()
        Data.reachedConnection = nil
    end

    if Data.blockedConnection then
        Data.blockedConnection:Disconnect()
        Data.blockedConnection = nil
    end

    Data.waypoints = nil
    Data.Path = nil
    Data.nextWaypointIndex = nil

    if not Data.Override then 
        local newTarget = GetRandomSpawn()
        repeat
            newTarget = GetRandomSpawn()
        until newTarget ~= Data.Target
        
        Data.Target = newTarget
        print(Data.Target)
    else
        Data.Target = target
    end

    Data.Path = PathfindingService:CreatePath(
        {
            AgentRadius = 2,
            AgentHeight = 4,
            AgentCanJump = true,
            AgentCanClimb = true,

            Costs = {
                Air = 0,
            }
        }
    )

    
    local success, errorMessage = pcall(function()
		Data.Path:ComputeAsync(self.Character.PrimaryPart.Position, Data.Target.CFrame.Position)
	end)

    if success and Data.Path.Status == Enum.PathStatus.Success then
        Data.waypoints = Data.Path:GetWaypoints()

        Data.blockedConnection = Data.Path.Blocked:Connect(function(blockedWaypointIndex)
            if blockedWaypointIndex >= Data.nextWaypointIndex - 1 then
                Data.blockedConnection:Disconnect()
                Data.reachedConnection:Disconnect()
                self.Character.Humanoid:MoveTo(self.Character.HumanoidRootPart.Position)
                self:PathTo(Data.Target)
                return
            end
        end)

        if not Data.reachedConnection then
            Data.reachedConnection = self.Character.Humanoid.MoveToFinished:Connect(function(reached)
                if reached and Data.nextWaypointIndex < #Data.waypoints then
                    local currentWaypoint = Data.waypoints[Data.nextWaypointIndex]
                    Data.nextWaypointIndex += 1
                    
                    local nextWaypoint = Data.waypoints[Data.nextWaypointIndex]
                    self.Character.Humanoid:MoveTo(nextWaypoint.Position)
                    
                    -- Check if the next waypoint requires jumping
                    if nextWaypoint.Action == Enum.PathWaypointAction.Jump or currentWaypoint.Action == Enum.PathWaypointAction.Jump then
                        print("Jumping!")
                        self.Character.Humanoid.Jump = true
                    end
                else
                    print("path completed")
    

                    if not Data.Override then
                        print("Recalculating Path!!!!!")
                        self:PathTo()
                    end
                end
            end)
        end

        Data.nextWaypointIndex = 2
        print("Moving!")
        self.Character.Humanoid:MoveTo(Data.waypoints[Data.nextWaypointIndex].Position)
    else
        warn("Path not computed!", errorMessage)
        self:PathTo()
    end
end


function class.New(Name: string, StartPos: Vector3 , Type: string)
    local self = {}
    setmetatable(self, class)

    local Char = NPCs:FindFirstChild(Type) assert(Char, `NPC type {Type} does not exist`)
    self.Character = Char:Clone()

    self.Character.Name = Name
    self.Character.HumanoidRootPart.Position = StartPos
    self.Character.Parent = Storage

    -- Pathfinding Stuff
    self.Pathfinding = {
        Override = false,
        Path = nil,
        Target = nil,
        nextWaypointIndex = nil,
        reachedConnection = nil,
        blockedConnection = nil,
        waypoints = nil,
    }

    -- Connections
    self.Animations = Animations
    self.Connections = {}

    for key, id in pairs(self.Animations) do
        self.Animations[key] = Instance.new("Animation")
        self.Animations[key].AnimationId = id
    end

    local Humanoid: Humanoid = self.Character.Humanoid

    self.Connections["animation"] = Humanoid.StateChanged:Connect(function(oldState, newState)
        for i,v in pairs(Humanoid:GetPlayingAnimationTracks()) do
            v:Stop()
        end

        print(newState)
           
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

function class:Destroy()
    print("Destroyin!")

    for _, connection in pairs(self.Connections) do
        connection:Disconnect()
    end
end


return class