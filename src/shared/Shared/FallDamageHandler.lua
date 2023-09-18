local SoundService = game:GetService("SoundService")
local class = {}

local player = game.Players.LocalPlayer

function class.CharAdded(Char)
    local Humanoid: Humanoid = Char:WaitForChild("Humanoid")
    local HRP = Char:FindFirstChild("HumanoidRootPart") if not HRP then return end

    Humanoid.StateChanged:Connect(function(old, new)
        if new == Enum.HumanoidStateType.Landed and old ~= Enum.HumanoidStateType.Landed then
            local Velocity = HRP.AssemblyLinearVelocity.Y * -1

            if Velocity < 90 then return end
            Humanoid:TakeDamage(Velocity/2)

            local FallSFX = Instance.new("Sound")
            FallSFX.SoundId = "rbxassetid://9114395530"
            SoundService:PlayLocalSound(FallSFX)


            if Humanoid.Health > 0 then return end
            local DamageSFX = Instance.new("Sound")
            DamageSFX.SoundId = "rbxassetid://8029615457"
            SoundService:PlayLocalSound(DamageSFX)
        end
    end)
end

function class.RenderStepped()
    
end


return class