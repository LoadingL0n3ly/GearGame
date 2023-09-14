local class = {}

local MarketPlaceService = game:GetService("MarketplaceService")

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

    
    [11377306] = {
        Name = "Ninja Star", 
        Desc = "Throw this at your friends, awesome!",
        Category = "Ranged",
        PurchaseCost = 60, -- IN POINTS
        PermanentPurchaseProduct = false, 
    },

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

}

return class