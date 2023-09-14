local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")
local class = {}

-- Permanent Gear Data Stuff
local PlayerData = {}

function class.LoadData(player, PermanentGearData)
    PlayerData[player] = PermanentGearData
end

function class.FetchData(player, DELETE_DATA)
    local Data = PlayerData[player] or nil
    if DELETE_DATA then PlayerData[player] = nil end

    return Data
end

-- Actual Setup Stuff
function class.CharAdded(char)
    local Player = Players:GetPlayerFromCharacter(char)
    
    repeat
        task.wait()
    until PlayerData[Player]
    local Data = PlayerData[Player]

    for _, GearID in Data do
        local GearModel = InsertService:LoadAsset(GearID)
        local Gear = GearModel:FindFirstChildWhichIsA("Tool") if not Gear then warn(GearID .. " is not a gear??") end
        Gear.Parent = Player.Backpack
    end
end



return class