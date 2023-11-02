local DataStoreService = game:GetService("DataStoreService")
local class = {}

local KillLeaderboardStore = DataStoreService:GetOrderedDataStore("KillsLeaderboard_" .. _VERSION)

local function RetrieveTopHundred()
    local isAscending = false
    local pageSize = 100
    local pages = KillLeaderboardStore:GetSortedAsync(isAscending, pageSize)
	local topHundred = pages:GetCurrentPage()

    for rank, data in ipairs(topHundred) do
		local name = data.key
		local points = data.value
		-- print(name .. " is ranked #" .. rank .. " with " .. points .. " kills")
	end

    return topHundred
end

function class.UpdatePlayerKills(player: Player, Kills: number)
    KillLeaderboardStore:UpdateAsync(player.Name, function(oldValue)
        if Kills < oldValue then return warn(player.Name .. " had " .. oldValue .. " kills but now only has " .. Kills) end
        return Kills
    end)
end

local function UpdateAllPlayers()
    for _, player in game.Players:GetPlayers() do
        local leaderstats = player:FindFirstChild("leaderstats") 
        if not leaderstats then continue end
        
        local Kills = leaderstats:FindFirstChild("Kills")

        class.UpdatePlayerKills(player, Kills.Value)
    end
end

function class.UpdateLeaderBoard()
    local Leaderboard = workspace:WaitForChild("Map"):WaitForChild("KillLeaderboard")
    local UI = Leaderboard.Screen:WaitForChild("SurfaceGui")

    local Sample = UI:FindFirstChild("Sample")
    UpdateAllPlayers()
    local Result = RetrieveTopHundred()

    for rank, data in ipairs(Result) do
		local name = data.key
		local points = data.value
		
        local leaderboardObj = Sample:Clone()
        leaderboardObj.Place.Text = rank .. ": " .. name
        leaderboardObj.Amount.Text = points

        leaderboardObj.Name = name
        leaderboardObj.Visible = true
        leaderboardObj.LayoutOrder = rank
        leaderboardObj.Parent = UI:FindFirstChild("ScrollingFrame")
	end

end


return class