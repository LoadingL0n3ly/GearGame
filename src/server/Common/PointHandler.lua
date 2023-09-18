local class = {}

-- CONSTANTS
local FREE_POINT_TIME = 5 -- SECONDS
local FREE_POINTS = 10 -- POINTS TO GIVE

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local WinRemotes = Remotes:FindFirstChild("CurrencyRemotes")

local ModifyPoints: RemoteEvent = WinRemotes:FindFirstChild("ModifyPoints")

function class.LoadData(player, PointsData)
    local leaderstats = player:WaitForChild("leaderstats")

    local PointValue = Instance.new("IntValue")
    PointValue.Name = "Points"
    PointValue.Value = PointsData
    PointValue.Parent = leaderstats
end

function class.FetchData(player)
    local leaderstats = player:FindFirstChild("leaderstats") if not leaderstats then return 0 end
    local Points = leaderstats:FindFirstChild("Points") if not Points then return end

    return Points.Value
end

function class.ModifyPoints(player: Player, amount: number, IGNORE_MULT: boolean, HIDE_NOTIF: boolean, msg: string)
    if not msg then msg = "" end
    if amount == 0 then return end
    
    local leaderstats = player:FindFirstChild("leaderstats") if not leaderstats then return 0 end
    local Points = leaderstats:FindFirstChild("Points") if not Points then return end

    Points.Value += amount
    ModifyPoints:FireClient(player, amount, HIDE_NOTIF, msg)
end

local lastAward = os.time()

function class.Stepped()
    if os.time() - lastAward >= FREE_POINT_TIME then
        for _, player in Players:GetPlayers() do
            class.ModifyPoints(player, FREE_POINTS, true, true)
        end

        lastAward = os.time()
    end
end



return class