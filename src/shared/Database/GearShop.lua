local class = {}

local MarketPlaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Gears = ReplicatedStorage:FindFirstChild("Gears")

class.Gears = {
    [243790334] = {
        Name = "Fling Glove", 
        Desc = "Fling your friends, awesome!",
        Category = "Melee",
        PurchaseCost = 20, -- IN POINTS
        PermanentPurchaseProduct = 189510467, -- GAMEPASS ID
        PermanentPurchaseProductCost = MarketPlaceService:GetProductInfo(189510467, Enum.InfoType.GamePass).PriceInRobux
    },

    [95354288] = {
        Name = "Luger Pistol", 
        Desc = "Shoot your friends, awesome!",
        Category = "Ranged",
        PurchaseCost = 40, -- IN POINTS
        PermanentPurchaseProduct = false, 
    },

    
    -- [11377306] = {
    --     Name = "Ninja Star", 
    --     Desc = "Throw this at your friends, awesome!",
    --     Category = "Ranged",
    --     PurchaseCost = 60, -- IN POINTS
    --     PermanentPurchaseProduct = false, 
    -- },

    [225921000] = {
        Name = "Magic Carpet", 
        Desc = "Fly at your friends, awesome!",
        Category = "Transport",
        PurchaseCost = 80, -- IN POINTS
        PermanentPurchaseProduct = false, 
    },

    [11999247] = {
        Name = "Subspace Tripmine", 
        Desc = "Explode your friends, awesome!",
        Category = "Explosive",
        PurchaseCost = 100, -- IN POINTS
        PermanentPurchaseProduct = false, 
    },

    [01010] = {
        Name = "RPG", 
        Desc = "Explode your friends at a distance, awesome!",
        Category = "Ranged",
        PurchaseCost = 100, -- IN POINTS
        PermanentPurchaseProduct = false, 
    },

}




function class.GetTool(ID)
   local SelectedItem = nil

   for _, Gear in Gears:GetChildren() do
        if Gear:GetAttribute("GearID") == ID then
            SelectedItem = Gear
            continue
        end
   end

   return SelectedItem:Clone() or "Unable to find gear " .. ID
end

return class