local class = {}

local Player = game.Players.LocalPlayer
local GUI = Player.PlayerGui

local ScreenGUI = "Blank"
local Base,TitleBox, ScrollingFrame, ListLayout = nil

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketPlaceService = game:GetService("MarketplaceService")
local Database = ReplicatedStorage:WaitForChild("Database")

local ShopDB = require(Database:FindFirstChild("GearShop"))

function class.OnOpen()
   
end

function class.OnClose()
    
end


local Colors = {
    Color3.new(1, 0.070588, 0.070588),
    Color3.new(1, 0.937254, 0.070588),
    Color3.new(0.180392, 1, 0.070588),
    Color3.new(1, 0.070588, 0.952941),
    Color3.new(0.070588, 0.580392, 1),
}

local function MakeDarker(color)
	local H, S, V = color:ToHSV()
	
	V = math.clamp(V - 0.3, 0, 1)
	
	return Color3.fromHSV(H, S, V)
end

function class.Setup()
    ScreenGUI = GUI:WaitForChild(script.Name)

    Base = ScreenGUI:FindFirstChild("Base")
    ScrollingFrame = Base:FindFirstChildWhichIsA("ScrollingFrame")
    ListLayout = ScrollingFrame:FindFirstChildWhichIsA("UIListLayout")
    TitleBox = Base:FindFirstChild("Title")

    local Sample: Frame = ScrollingFrame:FindFirstChild("Sample")

    local GearData = ShopDB.Gears
    local Index = 1

    for ID, DataObj in GearData do
        local GearObject = Base:FindFirstChild("Sample"):Clone()
        
        local Color = Colors[Index]
        
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
            print("Buy Gear!")
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