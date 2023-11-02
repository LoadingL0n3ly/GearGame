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
        PermanentPurchaseProductCost = MarketPlaceService:GetProductInfo(189510467, Enum.InfoType.GamePass).PriceInRobux,
        GetDeathMsg = function(playerName, victimName)
            local num = math.random(1,3)
            if num == 1 then return playerName .. " just flung " .. victimName .."to death!" end
            if num == 2 then return playerName .. " flung " .. victimName end
            if num == 3 then return victimName .. " was flung into the void by " .. playerName end
        end,
    },

    [16688968] = {
        Name = "Gravity Coil", 
        Desc = "Jump, but higher!",
        Category = "Transport",
        PurchaseCost = 20, -- IN POINTS
    },

    [78730532] = {
        Name = "Body Swap Potion", 
        Desc = "Be your Friends!",
        Category = "Misc",
        PurchaseCost = 20, -- IN POINTS
    },

    [95354288] = {
        Name = "Luger Pistol", 
        Desc = "Shoot your friends, awesome!",
        Category = "Ranged",
        PurchaseCost = 40, -- IN POINTS
        PermanentPurchaseProduct = false, 
        GetDeathMsg = function(playerName, victimName)
            if playerName == victimName then return playerName .. " pointed the gun in the wrong direction" end
            
            local num = math.random(1,3)
            if num == 1 then return playerName .. " just shot " .. victimName .." to death!" end
            if num == 2 then return playerName .. " no-scoped " .. victimName end
            if num == 3 then return victimName .. " had their mind blown by " .. playerName end
        end,
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
        GetDeathMsg = function(playerName, victimName)
            if playerName == victimName then return playerName .. " didn't know bombs kill you when they explode." end

            local num = math.random(1,3)
            if num == 1 then return playerName .. " just blew up " .. victimName end
            if num == 2 then return playerName .. " turned " .. victimName .. " into a pink mist" end
            if num == 3 then return victimName .. " has been blown up by " .. playerName end
        end,
    },

    [01010] = {
        Name = "RPG", 
        Desc = "Explode your friends at a distance, awesome!",
        Category = "Ranged",
        PurchaseCost = 100, -- IN POINTS
        PermanentPurchaseProduct = false, 
        GetDeathMsg = function(playerName, victimName)
            if playerName == victimName then return playerName .. " tried to rocket jump." end

            local num = math.random(1,3)
            if num == 1 then return playerName .. " just got PWnd " .. victimName .."to death!" end
            if num == 2 then return playerName .. " rocketed " .. victimName end
            if num == 3 then return victimName .. " didn't see " .. playerName .. "'s rocket coming!" end
        end,
    },

    [88885539] = {
        Name = "Airstrike", 
        Desc = "44th President shouts out",
        Category = "Ranged",
        PurchaseCost = 100, -- IN POINTS
        PermanentPurchaseProduct = false, 
        GetDeathMsg = function(playerName, victimName)
            local num = math.random(1,3)
            if num == 1 then return playerName .. " just bombed " .. victimName end
            if num == 2 then return playerName .. " obliterated " .. victimName end
            if num == 3 then return victimName .. " didn't see " .. playerName .. "'s plane coming!" end
        end,
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