local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Common = ServerScriptService:FindFirstChild("Common")

local PointsHandler = require(Common:FindFirstChild("PointHandler"))
local Database = ReplicatedStorage:FindFirstChild("Database")

local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local GearShopRemotes = Remotes:FindFirstChild("GearShopRemotes")

-- Remotes:
local PurchaseGearEvent: RemoteFunction = GearShopRemotes:FindFirstChild("PurchaseGear")

local GearDB = require(Database.GearShop)

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
        local Gear = GearDB.GetTool(GearID)
        Gear.Parent = Player.Backpack
    end
end

function class.GiveGear(player, ID)
    local Gear = GearDB.GetTool(ID)
    Gear.Parent = player.Backpack
end

-- Purchase Gear With Points
function class.PurchaseGear(player: Player, ID: number)
    local Response = {Success = false, Msg = "Initial"}

    local Data = GearDB.Gears[ID] 

    if not Data then
        print(ID)
        print(GearDB.Gears)
        Response.Msg = "GEAR NOT FOUND"
        return Response
    end

    local PurchaseCost = Data.PurchaseCost

    local leaderstats = player:FindFirstChild("leaderstats")
    local Points = leaderstats:FindFirstChild("Points")

    if Points.Value >= PurchaseCost then
        PointsHandler.ModifyPoints(player, -PurchaseCost, true, false)
        class.GiveGear(player, ID)
        Response.Msg = "SUCCESS"
        Response.Success = true
    else
        Response.Msg = "NOT ENOUGH PTS"
        Response.Success = false
    end

    return Response
end

function class.Setup()
    PurchaseGearEvent.OnServerInvoke = class.PurchaseGear
end


return class