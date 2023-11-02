local class = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NPCs = ReplicatedStorage.NPCs
class.__index = class

local Storage = Instance.new("Folder")
Storage.Name = "NPCs"
Storage.Parent = workspace

-- Default NPC Fallbacks
function class:DefaultWalkCycle()
    local Character = self.Character
    print("Falling Back to Default Cycle!")

    
end

function class:fun()
    print("Fun Time!")
end

function class.New(Name: string, StartPos: Vector3 , Type: string)
    local self = {}
    setmetatable(self, class)

    local Char = NPCs:FindFirstChild(Type) assert(Char, `NPC type {Type} does not exist`)
    self.Character = Char:Clone()

    self.Character.Name = Name
    self.Character.HumanoidRootPart.Position = StartPos
    self.Character.Parent = Storage

    return self
end


return class