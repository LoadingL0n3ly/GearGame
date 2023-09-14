local class = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SFX = ReplicatedStorage:WaitForChild("SFX")
local Player = game.Players.LocalPlayer

local GUI = Player:WaitForChild("PlayerGui")

local TweenService = game:GetService("TweenService")
local InputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ControllersFolder = script:WaitForChild("Controllers")

-- Modules 

local ActivatedElements = {}

-- UTILS:
function class.IsVisible(UI)
    local Visible = false

    for VisibleUI, _ in ActivatedElements do
        if VisibleUI == UI then Visible = true break end
    end

    return Visible
end

-- Core Functions: 

function class.Close(UI, playAnim)
    if not UI then return end

    local Controller = require(ControllersFolder:FindFirstChild(UI.Name))
    Controller.OnClose()

    
    if playAnim then
        local Base = UI:FindFirstChild("Base")
        local InitialSize = Base.Size

        local scaleDownTweenInfo = TweenInfo.new(0.1,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out)
	    local scaleDownTween: Tween = TweenService:Create(Base, scaleDownTweenInfo, {Size = UDim2.new(0.01,0, 0.01, 0)})
        scaleDownTween:Play()

        local CloseSFX = SFX:FindFirstChild("WindowClose")
        if CloseSFX then CloseSFX:Play() end

        scaleDownTween.Completed:Wait()
        Base.Size = InitialSize
    end

    UI.Enabled = false
    ActivatedElements[UI] = nil
end

function class.Open(UI, playAnim, HIDE_EXISTING)
    if not UI then return end
 
    if HIDE_EXISTING then
        for VisibleUI, equipped in ActivatedElements do
            class.Close(VisibleUI, true)
        end
    end

    local Controller = require(ControllersFolder:FindFirstChild(UI.Name))
    if not Controller then warn("Controller for UI " .. UI.Name .. " not found.") end

    Controller.OnOpen()
    UI.Enabled = true
    ActivatedElements[UI] = true

    if playAnim then
        local Base = UI:FindFirstChild("Base")
        local InitialSize = Base.Size

        Base.Size = UDim2.new(0,0,0,0)
        local scaleUpTweenInfo = TweenInfo.new(0.1,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out)
	    local scaleUpTween = TweenService:Create(Base, scaleUpTweenInfo, {Size = InitialSize})
        scaleUpTween:Play()

        local OpenSFX = SFX:FindFirstChild("WindowOpen")
        if OpenSFX then OpenSFX:Play() end

        scaleUpTween.Completed:Wait()
    end
end

-- CUSTOM BEHAVIOR
function class.navButtonSetup(button)
    local target = GUI:WaitForChild(button:GetAttribute("Open"))
	if target == nil then warn("Opening nothing or something, this is a really weird issue, target below but its nil") end
	local playAnim = button:GetAttribute("PlayAnim") or false
	
	button.Activated:Connect(function()
		if class.IsVisible(target) then
			class.Close(target, playAnim)
		else
			class.Open(target, playAnim)
		end
	end)
end

function class.Button1Setup(button: ImageButton)
	local NormalSize = button.Size
	local Color 
	
	if button:IsA("ImageButton") then
		Color = button.ImageColor3
	else
		Color = button.BackgroundColor3
	end

	button.Activated:Connect(function()
		local goal = {Size = UDim2.new(NormalSize.X.Scale * 1.1, 0, NormalSize.Y.Scale * 1.1, 0)}
		local TweenUp = TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Exponential), goal)
		TweenUp:Play()
		
		local Click = SFX:FindFirstChild("Click")
        if Click then Click:Play() end
		TweenUp.Completed:Wait()
		
		local TweenDown = TweenService:Create(button, TweenInfo.new(0.07, Enum.EasingStyle.Exponential), {Size = NormalSize})
		TweenDown:Play()
	end)
	
	local SCALE_MULT = 1.1
	button.MouseEnter:Connect(function()
		local NewSize = UDim2.new(NormalSize.X.Scale * SCALE_MULT, 0, NormalSize.Y.Scale * SCALE_MULT, 0)
		local TweenScale = TweenService:Create(button, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0), {Size = NewSize})
		TweenScale:Play()
		
		local Hover = SFX:FindFirstChild("Hover")
        if Hover then Hover:Play() end
	end)
	
	button.MouseLeave:Connect(function()
		local TweenScale = TweenService:Create(button, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, false, 0), {Size = NormalSize})
		TweenScale:Play()
	end)
end

local ScrollingFrames = {}

local function DefineBehavior(elem)
    -- BUTTON 1 BEHAVIOR
    if elem:HasTag("Button1") then
        class.Button1Setup(elem)
    end

    -- NAV BUTTON SETUP
    if elem:GetAttribute("Open") then
        if elem:GetAttribute("Open") ~= "" then
            class.navButtonSetup(elem)
        end
    end

    -- STROKE SCALE STUFF
    if elem:IsA("UIStroke") then
        local studiosize = Vector2.new(1920,1080)
        elem:SetAttribute("Thickness", elem:GetAttribute("Thickness") or elem.Thickness)
        elem.Thickness = elem:GetAttribute("Thickness") * (workspace.CurrentCamera.ViewportSize.Y/ studiosize.Y) * 1.2
        --print(elem.Thickness)
    end

    -- CLOSE BUTTON STUFF
    local ScreenToClose = elem:GetAttribute("CloseButton") 
    if ScreenToClose then
        local CloseButton: TextButton = elem
        
        local Interest = GUI:FindFirstChild(ScreenToClose) if not Interest then return end
        CloseButton.MouseButton1Down:Connect(function(x, y)
            class.Close(Interest, true)
        end)
    end

end

function class.Setup()
    for i, elem: Instance in GUI:GetDescendants() do        
        DefineBehavior(elem)
	end

    GUI.DescendantAdded:Connect(DefineBehavior)

    for _, ModuleScript in ControllersFolder:GetChildren() do
        if not ModuleScript:IsA("ModuleScript") then return end
        local Controller = require(ModuleScript)
        Controller.Setup()
    end

    print("🎨 UI Setup")
end

function class.RenderStepped()

end


return class