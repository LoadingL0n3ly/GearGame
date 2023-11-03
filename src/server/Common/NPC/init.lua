local class = {}
-- Services
local PathfindingService = game:GetService("PathfindingService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NPCs = ReplicatedStorage.NPCs
class.__index = class

local Storage = Instance.new("Folder")
Storage.Name = "NPCs"
Storage.Parent = workspace

-- Sample Path


-- Pathfinding 
function class:PathTo(target: Part)
    local Data = self.Pathfinding
    Data.Target = target
    Data.Path = PathfindingService:CreatePath()

    
    local success, errorMessage = pcall(function()
		Data.Path:ComputeAsync(self.Character.PrimaryPart.Position, target.CFrame.Position)
	end)

    if success and Data.Path.Status == Enum.PathStatus.Success then
        Data.waypoints = Data.Path:GetWaypoints()

        Data.blockedConnection = Data.Path.Blocked:Connect(function(blockedWaypointIndex)
            if blockedWaypointIndex >= Data.nextWaypointIndex then
                Data.blockedConnection:Disconnect()
                self:PathTo(target)
            end
        end)

        if not Data.reachedConnection then
            Data.reachedConnection = self.Character.Humanoid.MoveToFinished:Connect(function(reached)
                if reached and Data.nextWaypointIndex < #Data.waypoints then
                    Data.nextWaypointIndex += 1
                    self.Character.Humanoid:MoveTo(Data.waypoints[Data.nextWaypointIndex].Position)
                else
                    print("path completed")
                    Data.reachedConnection:Disconnect()
                    Data.blockedConnection:Disconnect()
                end
            end)
        end

        Data.nextWaypointIndex = 2
        self.Character.Humanoid:MoveTo(Data.waypoints[Data.nextWaypointIndex].Position)
    else
        warn("Path not computed!", errorMessage)
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
        Path = nil,
        Target = nil,
        nextWaypointIndex = nil,
        reachedConnection = nil,
        blockedConnection = nil,
        waypoints = nil,
    }

    return self
end


return class