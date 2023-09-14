local class = {}

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

function class.ModifyPoints(player, amount, HIDE_NOTIF)
    if amount == 0 then return end
    
    local leaderstats = player:FindFirstChild("leaderstats") if not leaderstats then return 0 end
    local Points = leaderstats:FindFirstChild("Points") if not Points then return end

    Points.Value += amount
    ModifyPoints:FireClient(player, amount, HIDE_NOTIF)
end

return class