local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local GearDB = require(ReplicatedStorage:FindFirstChild("Database"):WaitForChild("GearShop"))
local TweenService = game:GetService("TweenService")
local class = {}

local function Ragdoll(Char)
    local d = Char:GetDescendants()
	for i=1,#d do
		local desc = d[i]
		if desc:IsA("Motor6D") then
            local socket = Instance.new("BallSocketConstraint")
            socket.MaxFrictionTorque = 2
			local part0 = desc.Part0
			local joint_name = desc.Name
			local attachment0 = desc.Parent:FindFirstChild(joint_name.."Attachment") or desc.Parent:FindFirstChild(joint_name.."RigAttachment")
			local attachment1 = part0:FindFirstChild(joint_name.."Attachment") or part0:FindFirstChild(joint_name.."RigAttachment")
			if attachment0 and attachment1 then
				socket.Attachment0, socket.Attachment1 = attachment0, attachment1
				socket.Parent = desc.Parent
				desc:Destroy()
			end	
		end
	end
end

local function SetupGear(ID, pos)
    local GearClone: Tool = GearDB.GetTool(ID)
    if not GearClone then warn(ID) end

    GearClone.Parent = workspace.DroppedGears
    GearClone.Handle.Position = pos + Vector3.new(math.random(100,150)/10, -2, math.random(100,150)/10)
    GearClone.Handle.Anchored = true
    
    if GearClone.Handle:FindFirstChildWhichIsA("ParticleEmitter") then GearClone.Handle:FindFirstChildWhichIsA("ParticleEmitter").Enabled = true end

    local info = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out, -1, true)

    local FloatTween = TweenService:Create(GearClone.Handle, info, {Position = GearClone.Handle.Position + Vector3.new(0,2,0)})
    FloatTween:Play()

    -- local Highlight: Highlight = Instance.new("Highlight")
    -- Highlight.FillTransparency = 1
    -- Highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
    -- Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    -- Highlight.Parent = GearClone.Handle


    local connection
    connection = GearClone.Equipped:Connect(function(property)
        local Sound: Sound = Instance.new("Sound")
        Sound.SoundId = "rbxassetid://14794947081"
        Sound.RollOffMode = Enum.RollOffMode.InverseTapered
        Sound.Volume = 5
        Sound.RollOffMinDistance = 30
        Sound.RollOffMaxDistance = 80
        Sound.Parent = GearClone.Handle
        Sound:Play()
        Sound.Played:Connect(function()
            Sound:Destroy()
        end)

        -- Highlight:Destroy()

        GearClone.Handle:FindFirstChildWhichIsA("ParticleEmitter").Enabled = false
        GearClone.Handle.Anchored = false
        FloatTween:Pause()

        connection:Disconnect()
    end)
end

function class.CharDied(char: Model)
    if char:HasTag("KilledDeath") then return end
    char:AddTag("KilledDeath")

    local pos = char:GetPivot().Position
    local Humanoid = char:FindFirstChildWhichIsA("Humanoid")
    local Player = game.Players:GetPlayerFromCharacter(char)
    local HRP: BasePart = Humanoid:FindFirstChild("HumanoidRootPart")

    local BackPackGears, CharGears = nil
    if HRP then HRP.AssemblyLinearVelocity *= 100 end

    if Player then
        BackPackGears, CharGears = Player.Backpack:GetChildren(), char:GetChildren()
    end

    Ragdoll(char)
    local TransparencyTween
    for _, part in char:GetDescendants() do
        local good = false
        if part:IsA("Decal") or part:IsA("BasePart") then good = true end
        if not good then continue end

        TransparencyTween = TweenService:Create(part ,TweenInfo.new(8, Enum.EasingStyle.Linear), {Transparency = 1})
        TransparencyTween:Play()
    end

    if TransparencyTween then
        TransparencyTween.Completed:Connect(function(playbackState)
             char:Destroy()
        end)
    end

    if Player then
        Player.CharacterAdded:Wait()
        for _, gear: Tool in BackPackGears do
            if not gear:IsA("Tool") then continue end
            local ID = gear:GetAttribute("GearID")
            SetupGear(ID, pos)
        end

        for _, gear: Tool in CharGears do
            if not gear:IsA("Tool") then continue end
            local ID = gear:GetAttribute("GearID")
            SetupGear(ID, pos)
        end
    end

end

function class.CharacterAdded(char: Model)
    local Humanoid = char:WaitForChild("Humanoid")
    Humanoid.BreakJointsOnDeath = false
end

return class