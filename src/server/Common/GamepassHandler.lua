local class = {}

local MarketplaceService = game:GetService("MarketplaceService")
local Notification = game.ReplicatedStorage.Remotes.ClientNotification
local PurchaseComplete = game.ReplicatedStorage.Remotes.PurchaseComplete

local playerGamepassInfo = {}

local SkinsHandler = require(script.Parent.SkinsHandler)

function class.loadPlayerGamepasses(plr, data)
	local GamepassFolder = Instance.new("Folder")
	GamepassFolder.Name = "Gamepasses"
	GamepassFolder.Parent = plr

	playerGamepassInfo[plr] = data

	-- VIP 
	local VipObj = Instance.new("BoolValue")
	VipObj.Name = "VIP"
	VipObj.Value = data["260886252"] == "Granted"
	VipObj.Parent = GamepassFolder

	-- Speed 
	local SpeedObj = Instance.new("BoolValue")
	SpeedObj.Name = "Speed"
	SpeedObj.Value = data["260886132"] == "Granted"
	SpeedObj.Parent = GamepassFolder

	-- Wins 
	local WinsObj = Instance.new("BoolValue")
	WinsObj.Name = "Wins"
	WinsObj.Value = data["260886013"] == "Granted"
	WinsObj.Parent = GamepassFolder

	-- Popups
	local PopupObj = Instance.new("BoolValue")
	PopupObj.Name = "Popup"
	PopupObj.Value = data["670090893"] == "Granted"
	PopupObj.Parent = GamepassFolder
end

function class.getPlayerGamepasses(plr)
	return playerGamepassInfo[plr]
end


local productFunctions = {}

-- VIP
productFunctions[260886252] = function(player)
	if player then 
		player.Gamepasses.VIP.Value = true
		SkinsHandler.GiveChair(player, "VIPChair")
		return true
	else
		warn("Error Proccessing")
	end
end

-- NEON CHAIR
productFunctions[261053918] = function(player)
	if player then 
		SkinsHandler.GiveChair(player, "NeonChair")
		return true
	else
		warn("Error Proccessing")
	end
end

-- ROCKET CHAIR 
productFunctions[270491914] = function(player)
	if player then 
		SkinsHandler.GiveChair(player, "RocketChair")
		return true
	else
		warn("Error Proccessing")
	end
end

-- 2xSpeed
productFunctions[260886132] = function(player)
	if player then 
		player.Gamepasses.Speed.Value = true
		return true
	else
		warn("Error Proccessing")
	end
end

-- 2xWins
productFunctions[260886013] = function(player)
	if player then 
		player.Gamepasses.Wins.Value = true
		return true
	else
		warn("Error Proccessing")
	end
end

-- No Popup 670090893
productFunctions[670090893] = function(player)
	if player then 
		player.Gamepasses.Popup.Value = true
		return true
	else
		warn("Error Proccessing")
	end
end

local function onPromptPurchaseFinished(player, purchasedPassID, purchaseSuccess)
	if purchaseSuccess then
		if not playerGamepassInfo[player][tostring(purchasedPassID)] or playerGamepassInfo[player][tostring(purchasedPassID)] == "NotGranted" then
			local handler = productFunctions[purchasedPassID]
			local success, result = pcall(handler, player)
			
			if success then
				playerGamepassInfo[player][tostring(purchasedPassID)] = "Granted"
			else
				warn("something went wrong buying the gamepass, tough luck honestly? ", result)
				playerGamepassInfo.player.purchasedPassID = "NotGranted"
			end
		end
		PurchaseComplete:FireClient(player, true)
	else
		PurchaseComplete:FireClient(player, false)
	end

end

function class.checkForOwnedPasses(player)
	for ID, handler in pairs(productFunctions) do
		if MarketplaceService:UserOwnsGamePassAsync(player.UserId, ID) and playerGamepassInfo[player][tostring(ID)] ~= "Granted" then
			playerGamepassInfo[player][tostring(ID)] = "NotGranted"
		end

		if playerGamepassInfo[player][tostring(ID)] == "NotGranted" then
			onPromptPurchaseFinished(player, ID, true)
		end
	end
end

function class.Setup()
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(onPromptPurchaseFinished)
end

return class
