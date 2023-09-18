local class = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RESET_TIME = 5 * 60
local LastReset = os.time()

local Time = require(ReplicatedStorage:WaitForChild("Utils"):FindFirstChild("Time"))
local KillLeaderBoardHandler = require(ServerScriptService.Common.KillLeaderBoardHandler)


local MapBackup = workspace:WaitForChild("Map"):Clone()
MapBackup.Parent = ReplicatedStorage

local function ResetMap()
    local OldMap = workspace:FindFirstChild("Map")
    local NewMap = MapBackup:Clone()

    for _, char in workspace.Characters:GetChildren() do
        local HRP = char:FindFirstChild("HumanoidRootPart") if not HRP then continue end
        HRP.Anchored = true

        task.delay(1, function()
            HRP.Anchored = false
        end)
    end

    NewMap.Parent = workspace
    OldMap:Destroy()
    LastReset = os.time()
end


function class.Tick()
    local TimeRemaining = RESET_TIME - (os.time() - LastReset)
    local ResetBillboard = workspace.Map:FindFirstChild("RemainingTime")
    local Screen = ResetBillboard:FindFirstChild("Screen")

    local UI = Screen:FindFirstChild("SurfaceGui")

    local Amount = UI:FindFirstChild("Amount")
    Amount.Text = Time.secToHMS(TimeRemaining)

    if TimeRemaining <= 0 then
        ResetMap()
        task.delay(2, KillLeaderBoardHandler.UpdateLeaderBoard)
    end
end        



return class