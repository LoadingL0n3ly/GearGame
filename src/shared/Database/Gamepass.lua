local MarkertplaceService = game:GetService("MarketplaceService")

local class = {
    PermanentSpeedCoil = {ID = 652623113, Info = MarkertplaceService:GetProductInfo(652623113, Enum.InfoType.GamePass)},
    PermanentFryingPan = {ID = 651863169, Info = MarkertplaceService:GetProductInfo(651863169, Enum.InfoType.GamePass)},
    PermanentFlingGlove = {ID = 651381155, Info = MarkertplaceService:GetProductInfo(651381155, Enum.InfoType.GamePass)}
}

return class