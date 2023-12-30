local class = {}

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = game:GetService("ServerScriptService"):WaitForChild("Common")
local GearHandler = require(Common.GearHandler)

local Database = ReplicatedStorage.Database
local Gamepasses = require(Database.Gamepass)

local playerGamepassInfo = {}

function class.loadPlayerGamepasses(plr, data)
	local GamepassFolder = Instance.new("Folder")
	GamepassFolder.Name = "Gamepasses"
	GamepassFolder.Parent = plr

	playerGamepassInfo[plr] = data
end

function class.getPlayerGamepasses(plr)
	return playerGamepassInfo[plr]
end


local productFunctions = {}

-- VIP
productFunctions[Gamepasses.PermanentFlingGlove.ID] = function(player)
	if player then 
		GearHandler.AddPermanentGear(player, Gamepasses.PermanentFlingGlove.TooldIdID)
		return true
	else
		warn("Error Proccessing")
	end
end

productFunctions[Gamepasses.PermanentFryingPan.ID] = function(player)
	print("skibidi")
	if player then 
		GearHandler.AddPermanentGear(player, Gamepasses.PermanentFryingPan.TooldIdID)
		return true
	else
		warn("Error Proccessing")
	end
end

productFunctions[Gamepasses.PermanentSpeedCoil.ID] = function(player)
	if player then 
		GearHandler.AddPermanentGear(player, Gamepasses.PermanentSpeedCoil.TooldIdID)
		return true
	else
		warn("Error Proccessing")
	end
end

local function onPromptPurchaseFinished(player, purchasedPassID, purchaseSuccess)
	if purchaseSuccess then
		print(purchasedPassID)
			print(Gamepasses.PermanentFryingPan.ID)
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
		--PurchaseComplete:FireClient(player, true)
	else
		--PurchaseComplete:FireClient(player, false)
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
