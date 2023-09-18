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
		print(name .. " is ranked #" .. rank .. " with " .. points .. " kills")
	end

    return topHundred
end

function class.UpdatePlayerKills(player: Player, kills: number)
    KillLeaderboardStore:SetAsync(player.Name, kills)
end

local function UpdateAllPlayers()
    for _, player in game.Players:GetPlayers() do
        local leaderstats = player:FindFirstChild("leaderstats") if not leaderstats then continue end
        local Kills = leaderstats:FindFirstChild("Kills")

        class.UpdatePlayerKills(player, Kills.Value)
    end
end

function class.UpdateLeaderBoard()
    local Leaderboard = workspace:FindFirstChild("Map"):FindFirstChild("KillLeaderboard")
    local UI = Leaderboard:FindFirstChildWhichIsA("SurfaceGui")

    local Sample = UI:FindFirstChild("Sample")
    UpdateAllPlayers()
    local Result = RetrieveTopHundred()

    for rank, data in ipairs(Result) do
		local name = data.key
		local points = data.value
		
        local leaderboardObj = Sample:Clone()
        leaderboardObj.
	end

end


return class