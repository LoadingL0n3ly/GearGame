local RunService = game:GetService("RunService")
local Swordsman = {}
Swordsman.__index = Swordsman

local NPC = require(script.Parent)
setmetatable(Swordsman, NPC)

local Players = game.Players
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gears = ReplicatedStorage:WaitForChild("Gears")
local NPCs = ReplicatedStorage:WaitForChild("NPCs")
local Weapons = NPCs:WaitForChild("Weapons")

local Sword = Weapons:WaitForChild("LinkedSword")
local HttpsService = game:GetService("HttpService")

local Store = {}

local function GetRandomFriend(player: Player)
    local success, friends = pcall(function() return Players:GetFriendsAsync(player.UserId) end)
    if not success then return math.random(1000, 1045324707) end

    local ids = table.create(200) -- max friends limit
    local count = 0

    while true do
        for _, item in ipairs(friends:GetCurrentPage()) do
            count += 1
            ids[count] = item.Id
        end
        
        if friends.IsFinished then
            break
        end
        
        friends:AdvanceToNextPageAsync()
    end

    local randomFriendId = ids[math.random(1,count)]
    return randomFriendId
end

local function GetRandomCharId()
    local RandomPlayer: Player = Players:GetPlayers()[math.random(1, #Players:GetPlayers())]
    local RandomFriendId = GetRandomFriend(RandomPlayer)

    return RandomFriendId
end

local DISTANCE_THRESHOLD = 20
local ATTACK_THRESHOLD = 5
local STAB_COOLDOWN = 1

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
        if tick() - self.LastStab >= STAB_COOLDOWN then
            self.LastStab = tick()
            self.Sword.Trigger:Fire()
        end
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

function Swordsman:PermDestroy()
    self.RespawnTime = nil
    self:Destroy()
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

    self.LastStab = tick()

    self.Sword = Sword:Clone()
    local Humanoid: Humanoid = self.Character.Humanoid
    Humanoid:EquipTool(self.Sword)
    
    task.spawn(function()
        local FriendId = GetRandomCharId()
        local desc = Players:GetHumanoidDescriptionFromUserId(FriendId)
        self.Character.Humanoid:ApplyDescription(desc)

        local name = Players:GetNameFromUserIdAsync(FriendId)
        self.Character.Name = name
    end)

    self.Checking = false

    self.Connections["Stepped"] = RunService.Stepped:Connect(function()
        local Alert = self.Character.Head:FindFirstChild("Alert")
        if not Alert then
            Alert = ReplicatedStorage.NPCs.Alert:Clone()
            Alert.Parent = self.Character.Head
        end

        if self.EnemyTarget then
            self:MoveToTarget()
            Alert.Enabled = true
        else
            self:LookForTarget()
            Alert.Enabled = false
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