-- PurchaseHandler.server.lua — safe developer product + game pass handling (Script in ServerScriptService).
-- Grants ONLY from the receipt handler, idempotent by PurchaseId, returns NotProcessedYet if the player
-- isn't here or saving fails (Roblox retries). One handler for the whole game.
-- Fill PRODUCTS / PASSES, and connect Data.Get/Data.Update to your data module (ProfileStore recommended).

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

-- >>> plug in your data layer (must persist PurchaseIds with the player's data) <<<
local Data = {
	-- returns the player's live data table or nil if not loaded
	Get = function(player) return player:GetAttribute("DataLoaded") and _G.PlayerData and _G.PlayerData[player] end,
	-- persists immediately if your module supports it; return true on success
	Save = function(player) return true end,
}

local PRODUCTS = { -- [productId] = function(player, data) ... end
	-- [123456] = function(player, data) data.Coins += 1000 end,
}
local PASSES = { -- [gamePassId] = function(player) ... end   (apply perk; ownership is checked on join)
	-- [987654] = function(player) player:SetAttribute("VIP", true) end,
}

local function grantFromReceipt(receipt)
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
	local data = Data.Get(player)
	if not data then return Enum.ProductPurchaseDecision.NotProcessedYet end
	data.Purchases = data.Purchases or {}
	if data.Purchases[receipt.PurchaseId] then return Enum.ProductPurchaseDecision.PurchaseGranted end
	local grant = PRODUCTS[receipt.ProductId]
	if not grant then warn("[Purchase] unknown product", receipt.ProductId); return Enum.ProductPurchaseDecision.NotProcessedYet end
	local ok, err = pcall(grant, player, data)
	if not ok then warn("[Purchase] grant failed", err); return Enum.ProductPurchaseDecision.NotProcessedYet end
	data.Purchases[receipt.PurchaseId] = os.time()
	if not Data.Save(player) then return Enum.ProductPurchaseDecision.NotProcessedYet end
	return Enum.ProductPurchaseDecision.PurchaseGranted
end
MarketplaceService.ProcessReceipt = grantFromReceipt

local function checkPasses(player)
	for passId, apply in pairs(PASSES) do
		local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, passId)
		if ok and owns then task.spawn(apply, player) end
	end
end
Players.PlayerAdded:Connect(checkPasses)
for _, p in ipairs(Players:GetPlayers()) do task.spawn(checkPasses, p) end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
	if purchased and PASSES[passId] then PASSES[passId](player) end
end)
