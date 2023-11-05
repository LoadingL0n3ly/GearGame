local class = {}

local DAMAGE_POINT_MULT = 1
local KILL_BONUS = 20

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GearDB = require(ReplicatedStorage.Database.GearShop)
local MessageEvent = ReplicatedStorage.Remotes.ChatMessage

local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local Common = ServerScriptService:FindFirstChild("Common")

local PointHandler = require(Common:FindFirstChild("PointHandler"))


function class.DamageDoneToHumanoid(Attacker: Player, Victim: Humanoid, DamageDealt: number, ToolId: number)
    if Victim:HasTag("Killed") then return end

    local HRP: BasePart = Victim.Parent:FindFirstChild("HumanoidRootPart")

    if HRP then
        local Sound: Sound = Instance.new("Sound")
        Sound.SoundId = "rbxassetid://14796629812"
        Sound.RollOffMode = Enum.RollOffMode.InverseTapered
        Sound.Volume = 1
        Sound.RollOffMinDistance = 30
        Sound.RollOffMaxDistance = 60
        Sound.Parent = HRP
        Sound:Play()
        Sound.Played:Connect(function()
            Sound:Destroy()
        end)
        
        local DamagePart: Part = ReplicatedStorage.Misc.DamagePart:Clone()
        DamagePart.Position = HRP.Position

        local Billboard: BillboardGui = DamagePart:FindFirstChildWhichIsA("BillboardGui")
        Billboard.DamageText.Text = DamageDealt

        local MoveTween = TweenService:Create(DamagePart, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = DamagePart.Position + (HRP.CFrame.LookVector * 2) + (HRP.CFrame.UpVector * math.random(3,8)) + (HRP.CFrame.RightVector * (math.random(-80,80)/10))})
        DamagePart.Parent = HRP
        MoveTween:Play()

        local TransparencyTween = TweenService:Create(Billboard.DamageText, TweenInfo.new(1, Enum.EasingStyle.Exponential), {TextTransparency = 1})
        local TransparencyTween2 = TweenService:Create(Billboard.DamageText.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Transparency = 1})

        MoveTween.Completed:Connect(function(playbackState)
            TransparencyTween:Play()
            TransparencyTween2:Play()

            TransparencyTween.Completed:Connect(function()
                DamagePart:Destroy()
            end)
        end)
    end

    if Attacker:FindFirstChildWhichIsA("Humanoid") then
        Attacker = game.Players:GetPlayerFromCharacter(Attacker)
    end
    -- warn(Attacker.Name .. " used tool id " .. ToolId .. " to do " .. DamageDealt .. "pts of damage to " .. Victim.Name)


    -- HANDLE ALL THE POINTS
    PointHandler.ModifyPoints(Attacker, DAMAGE_POINT_MULT * DamageDealt, false, false)
    if Victim.Health <= 0  then 
        Victim:AddTag("Killed")
        PointHandler.ModifyPoints(Attacker, KILL_BONUS, false, false, "KILL BONUS:")
        if Attacker then Attacker.leaderstats.Kills.Value += 1 end
        local VictimName = Victim.Parent.Name
        local AttackerName = "NPC"
        if Attacker then AttackerName = Attacker.Name end
        
        local msg = AttackerName .. " just PWNd " .. VictimName
        local GearData = GearDB.Gears[ToolId]

        if GearData then
            msg = GearData.GetDeathMsg(AttackerName, VictimName)
        end

        MessageEvent:FireAllClients(msg, Color3.fromRGB(255, 80, 74):ToHex())
        
        local Sound: Sound = Instance.new("Sound")
        Sound.SoundId = "rbxassetid://14797316101"
        Sound.RollOffMode = Enum.RollOffMode.InverseTapered
        Sound.Volume = 1
        Sound.RollOffMinDistance = 40
        Sound.RollOffMaxDistance = 150
        Sound.Parent = HRP
        Sound:Play()
        Sound.Played:Connect(function()
            Sound:Destroy()
        end)
        
        local DamagePart: Part = ReplicatedStorage.Misc.KillPart:Clone()
        DamagePart.Position = HRP.Position

        local Billboard: BillboardGui = DamagePart:FindFirstChildWhichIsA("BillboardGui")

        local MoveTween = TweenService:Create(DamagePart, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = DamagePart.Position + HRP.CFrame.UpVector * 4})
        DamagePart.Parent = HRP
        MoveTween:Play()

        local TransparencyTween = TweenService:Create(Billboard.DamageText, TweenInfo.new(1, Enum.EasingStyle.Exponential), {TextTransparency = 1})
        local TransparencyTween2 = TweenService:Create(Billboard.DamageText.UIStroke, TweenInfo.new(1, Enum.EasingStyle.Exponential), {Transparency = 1})

        MoveTween.Completed:Connect(function(playbackState)
            TransparencyTween:Play()
            TransparencyTween2:Play()

            TransparencyTween.Completed:Connect(function()
                DamagePart:Destroy()
            end)
        end)
    end
end

return class