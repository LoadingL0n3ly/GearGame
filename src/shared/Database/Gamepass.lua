local MarkertplaceService = game:GetService("MarketplaceService")

local class = {
    PermanentSpeedCoil = {ID = 652623113, ToolID = 99119158, Info = MarkertplaceService:GetProductInfo(652623113, Enum.InfoType.GamePass)},
    PermanentFryingPan = {ID = 651863169, ToolID = 24346755, Info = MarkertplaceService:GetProductInfo(651863169, Enum.InfoType.GamePass)},
    PermanentFlingGlove = {ID = 651381155, TooldId = 243790334, Info = MarkertplaceService:GetProductInfo(651381155, Enum.InfoType.GamePass)}
}

return class