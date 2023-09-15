local class = {}

local Player = game.Players.LocalPlayer
local GUI = Player.PlayerGui

local ScreenGUI = "Blank"
local Base,TitleBox, ScrollingFrame, ListLayout = nil

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SFX = ReplicatedStorage:FindFirstChild("SFX")
local MarketPlaceService = game:GetService("MarketplaceService")
local Database = ReplicatedStorage:WaitForChild("Database")

local ShopDB = require(Database:FindFirstChild("GearShop"))

local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local GearShopRemotes = Remotes:FindFirstChild("GearShopRemotes")

-- Remotes:
local PurchaseGearEvent: RemoteFunction = GearShopRemotes:FindFirstChild("PurchaseGear")

function class.OnOpen()
   
end

function class.OnClose()
    
end


local Colors = {
    Melee = Color3.new(1, 0.070588, 0.070588),
    Ranged = Color3.new(1, 0.937254, 0.070588),
    Transport = Color3.new(0.180392, 1, 0.070588),
    Explosive = Color3.new(1, 0.070588, 0.952941),
    -- Color3.new(0.070588, 0.580392, 1),
}

local function MakeDarker(color)
	local H, S, V = color:ToHSV()
	
	V = math.clamp(V - 0.3, 0, 1)
	
	return Color3.fromHSV(H, S, V)
end

local function MakeBrighter(color)
	local H, S, V = color:ToHSV()
	
	V = math.clamp(V + 0.3, 0, 1)
	
	return Color3.fromHSV(H, S, V)
end

local function PointPurchaseGear(Button: ImageButton, ID: number)
    local Response = PurchaseGearEvent:InvokeServer(ID)

    if Response.Success then
        SFX:FindFirstChild("PurchaseComplete"):Play()
    end

    local Label = Button:FindFirstChildWhichIsA("TextLabel")
    local PrevText = Label.Text
    Label.Text = Response.Msg

    task.delay(1, function()
        Label.Text = PrevText
    end)
end


function class.Setup()
    ScreenGUI = GUI:WaitForChild(script.Name)
    
    Base = ScreenGUI:FindFirstChild("Base")

    local SelectedButton = Base:FindFirstChild("Buttons"):FindFirstChild("Ranged")
    SelectedButton.BackgroundColor3 = MakeDarker(SelectedButton.BackgroundColor3)

    -- ScrollingFrame = Base:FindFirstChildWhichIsA("ScrollingFrame")
    -- ListLayout = ScrollingFrame:FindFirstChildWhichIsA("UIListLayout")
    TitleBox = Base:FindFirstChild("Title")

    local Sample: Frame = Base:FindFirstChild("Sample")

    local GearData = ShopDB.Gears
    local Index = 1

    for _, Button: ImageButton in Base:FindFirstChild("Buttons"):GetChildren() do
        if not Button:IsA("ImageButton") then continue end

        local TargetFrame = Base:FindFirstChild(Button.Name) if not TargetFrame then continue end
        if not TargetFrame:IsA("ScrollingFrame") then continue end

        Button.MouseButton1Down:Connect(function(x, y)
            if Button == SelectedButton then return end

            SelectedButton.BackgroundColor3 = MakeBrighter(SelectedButton.BackgroundColor3)
            Base:FindFirstChild(SelectedButton.Name).Visible = false

            SelectedButton = Button
            SelectedButton.BackgroundColor3 = MakeDarker(SelectedButton.BackgroundColor3)
            TargetFrame.Visible = true
        end)
    end

    for ID, DataObj in GearData do
        local GearObject = Base:FindFirstChild("Sample"):Clone()
        local ScrollingFrame = Base:FindFirstChild(DataObj.Category) if not ScrollingFrame then warn(DataObj.Category) continue end

        local Color = Colors[DataObj.Category]
        
        GearObject.Name = ID
        GearObject.UIStroke.Color = Color
        GearObject.Title.Text = DataObj.Name
        GearObject.Title.TextColor3 = Color
        
        GearObject.Desc.Text = DataObj.Desc
        GearObject.Desc.TextColor3 = MakeDarker(Color)
        
        GearObject.Icon.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. tostring(ID).. "&width=420&height=420&format=png"
        
        GearObject.Buy.TextLabel.Text = "Buy: " .. DataObj.PurchaseCost .. "PTs"
        GearObject.LayoutOrder = DataObj.PurchaseCost
        GearObject.Buy.MouseButton1Down:Connect(function()
            PointPurchaseGear(GearObject.Buy, ID)
        end)

        if DataObj.PermanentPurchaseProduct then
            GearObject.Permanent.TextLabel.Text = "Perm: R$" .. DataObj.PermanentPurchaseProductCost

            GearObject.Permanent.MouseButton1Down:Connect(function()
                MarketPlaceService:PromptGamePassPurchase(Player, DataObj.PermanentPurchaseProduct)
            end)
        else
            GearObject.Permanent.Visible = false
            GearObject.Buy.Position = UDim2.fromScale(0.827, 0.5)
        end

        GearObject.Visible = true
        GearObject.Parent = ScrollingFrame

        Index += 1
        if Index > #Colors then Index = 1 end

        -- ScrollingFrame.CanvasSize = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y)
    end
end

return class