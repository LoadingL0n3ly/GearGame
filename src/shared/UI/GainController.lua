local class = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SFX = ReplicatedStorage:WaitForChild("SFX")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CurrencyRemotes = Remotes:WaitForChild("CurrencyRemotes")

-- // REMOTES
local ModifyPoints: RemoteEvent = CurrencyRemotes:WaitForChild("ModifyPoints")

local Player = Players.LocalPlayer
local leaderstats = Player:WaitForChild("leaderstats")
local GUI = Player.PlayerGui

local GainUI = GUI:WaitForChild("Gain")
local Main = GUI:WaitForChild("Main")

local MainFrame = Main:WaitForChild("MainFrame")
local PointsDisplay = MainFrame:FindFirstChild("PointsFrame")
-- // UTILS
local function GetProperty(Object)
	if Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox") then
		return "TextTransparency"
	elseif Object:IsA("ViewportFrame") or Object:IsA("ImageButton") or Object:IsA("ImageLabel") then
		return "ImageTransparency"
	elseif Object:IsA("Frame") then
		return "BackgroundTransparency"
	elseif Object:IsA("UIStroke") then
		return "Transparency"
	end
	
end

local function FadeIn(Object, FadeTime,Transparency)
	local TI = TweenInfo.new(FadeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local Table = Object:GetDescendants()
	Table[#Table + 1] = Object
	for i,v in pairs(Table) do
		local Property = GetProperty(v)

		if Property then
			if v:FindFirstChild("DefaultTransparencyValue") then
				TweenService:Create(v, TI, {[Property] = Transparency}):Play()
			else
				local DefaultTransparencyValue = Instance.new("NumberValue")
				DefaultTransparencyValue.Name = "DefaultTransparencyValue"
				DefaultTransparencyValue.Value = v[Property]
				DefaultTransparencyValue.Parent = v

				v[Property] = 1
				TweenService:Create(v, TI, {[Property] = v:FindFirstChild("DefaultTransparencyValue").Value}):Play()
			end
		end
		Property = nil
	end
	TI = nil
	Table = nil
end

TIME = 1

local function formatNumberWithCommas(number)
	local formattedNumber = string.format("%d", number)
	local left, num, right = string.match(formattedNumber, '^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end
-- just for tweening the wins amt nicely
PointsDisplay.Amt.Value.Changed:Connect(function()
    PointsDisplay.Amt.Text = formatNumberWithCommas(PointsDisplay.Amt.Value.Value)
end)

local MouseObj: Mouse = Player:GetMouse()

function class.Setup()
	-- // CONNECTIONS
	PointsDisplay:WaitForChild("Amt").Text = formatNumberWithCommas(PointsDisplay.Amt.Value.Value)

	ModifyPoints.OnClientEvent:Connect(function(amt, HIDE_NOTIF, msg)
		local PointsDisplayText = PointsDisplay:FindFirstChild("Amt").Value
		local TweenToValue = TweenService:Create(PointsDisplayText,TweenInfo.new(1,Enum.EasingStyle.Linear),{Value = game.Players.LocalPlayer.leaderstats.Points.Value}) if not TweenToValue then return end
		TweenToValue:Play()

        if HIDE_NOTIF then return end

		local Gain = game.Players.LocalPlayer.PlayerGui.Gain

		SFX:FindFirstChild("GainCoins"):Play()
		
		local obj = Gain.GainPoints:Clone()
		obj.Visible = true
		obj.Amount.Text = msg .. formatNumberWithCommas(amt)
		obj.Position = UDim2.fromOffset(MouseObj.X, MouseObj.Y)
		obj.Parent = Gain.Points

		if msg == "KILL BONUS:" then
			obj.ImageLabel.Image = "rbxassetid://14798368984"
			obj.Amount.TextColor3 = Color3.fromRGB(253, 231, 84)
		end
		
		local AbsoluteSize = Main.AbsoluteSize
		local X = math.random(70, 90)/100
		local Y = math.random(10, 90)/100

		local goal = {Position = UDim2.fromScale(X,Y)}
		local SlideTween = TweenService:Create(obj, TweenInfo.new(TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out), goal)
		
		SlideTween:Play()
		FadeIn(obj, TIME, 0)
	
		task.wait(TIME + TIME * 2)
		
		FadeIn(obj, TIME/2, 1)
		obj:Destroy()
	end)
end

return class