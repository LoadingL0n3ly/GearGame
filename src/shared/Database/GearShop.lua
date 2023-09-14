local class = {}

local MarketPlaceService = game:GetService("MarketplaceService")

class.Gears = {
    [243790334] = {
        Name = "Fling Glove", 
        Desc = "Fling your friends, awesome!",
        PurchaseCost = 20, -- IN POINTS
        PermanentPurchaseProduct = 189510467, -- GAMEPASS ID
        PermanentPurchaseProductCost = MarketPlaceService:GetProductInfo(189510467, Enum.InfoType.GamePass).PriceInRobux
    },

    [95354288] = {
        Name = "Luger Pistol", 
        Desc = "Shoot your friends, awesome!",
        PurchaseCost = 40, -- IN POINTS
        PermanentPurchaseProduct = false, 
    },

    
    [11377306] = {
        Name = "Ninja Star", 
        Desc = "Throw this at your friends, awesome!",
        PurchaseCost = 60, -- IN POINTS
        PermanentPurchaseProduct = false, 
    }


}

return class