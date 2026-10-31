--!strict
--[[
	MonetizationKit - server entry point.
	Keep the whole MonetizationKit folder in ServerScriptService.
	You don't need to edit this script: configure everything in Config.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- The folder contains your promo codes, so it must never replicate to players.
if script.Parent.Parent ~= ServerScriptService then
	warn("[MonetizationKit] Please keep the MonetizationKit folder in ServerScriptService. Moving it there now.")
	script.Parent.Parent = ServerScriptService
end

local Config = require(script.Parent.Config)
local Logic = require(script.Parent.Modules.Logic)
local PlayerData = require(script.Parent.Modules.PlayerData)
local MonetizationKit = require(script.Parent.API)

local MAX_PURCHASE_HISTORY = 100

--------------------------------------------------------------------------------
-- Configuration checks (printed once, so mistakes are easy to spot)
--------------------------------------------------------------------------------

local promoCodes, codeProblems = Logic.prepareCodes(Config.PromoCodes)
for _, problem in codeProblems do
	warn(`[MonetizationKit] {problem}`)
end
for productId, reward in Config.DeveloperProducts do
	if Logic.sanitizeAmount(reward.Coins) == nil and reward.Grant == nil then
		warn(`[MonetizationKit] Developer product {productId} gives nothing. Set Coins or Grant in Config.`)
	end
end
for index, amount in Config.DailyRewards do
	if Logic.sanitizeAmount(amount) == nil then
		warn(`[MonetizationKit] Config.DailyRewards[{index}] should be a positive number.`)
	end
end

--------------------------------------------------------------------------------
-- Remotes
--------------------------------------------------------------------------------

local remotes = Instance.new("Folder")
remotes.Name = "MonetizationKitRemotes"

local getStateRemote = Instance.new("RemoteFunction")
getStateRemote.Name = "GetState"
getStateRemote.Parent = remotes

local claimDailyRemote = Instance.new("RemoteFunction")
claimDailyRemote.Name = "ClaimDaily"
claimDailyRemote.Parent = remotes

local redeemCodeRemote = Instance.new("RemoteFunction")
redeemCodeRemote.Name = "RedeemCode"
redeemCodeRemote.Parent = remotes

local stateChangedRemote = Instance.new("RemoteEvent")
stateChangedRemote.Name = "StateChanged"
stateChangedRemote.Parent = remotes

remotes.Parent = ReplicatedStorage

local stateLimiter = Logic.newRateLimiter(10, 10)
local dailyLimiter = Logic.newRateLimiter(3, 10)
local codeLimiter = Logic.newRateLimiter(5, 30)

-- Everything a client needs to draw the UI. Promo codes are never included.
local function buildState(player: Player): { [string]: any }?
	local profile = PlayerData.get(player)
	if profile == nil then
		return nil
	end
	local daily = Logic.evaluateDaily(profile.Data.LastDailyDay, profile.Data.DailyStreak, os.time(), Config.DailyRewards)

	local products = {}
	for productId, reward in Config.DeveloperProducts do
		table.insert(products, { Id = productId, Coins = Logic.sanitizeAmount(reward.Coins) })
	end
	table.sort(products, function(a, b)
		return (a.Coins or 0) < (b.Coins or 0)
	end)

	local passes = {}
	for gamePassId, perk in Config.GamePasses do
		table.insert(passes, { Id = gamePassId, Name = perk.Name, Owned = MonetizationKit.OwnsPass(player, gamePassId) })
	end
	table.sort(passes, function(a, b)
		return a.Id < b.Id
	end)

	return {
		CurrencyName = Config.CurrencyName,
		Coins = profile.Data.Coins,
		DailyEnabled = #Config.DailyRewards > 0,
		DailyRewards = Config.DailyRewards,
		Daily = {
			CanClaim = daily.canClaim,
			Streak = daily.streak,
			Reward = daily.reward,
			SecondsUntilNext = daily.secondsUntilNext,
		},
		CodesEnabled = next(promoCodes) ~= nil,
		Products = products,
		Passes = passes,
	}
end

getStateRemote.OnServerInvoke = function(player: Player)
	if not stateLimiter.allow(player, os.time()) then
		return nil
	end
	return buildState(player)
end

claimDailyRemote.OnServerInvoke = function(player: Player)
	if not dailyLimiter.allow(player, os.time()) then
		return { Ok = false, Message = "Slow down a little!" }
	end
	local profile = PlayerData.get(player)
	if profile == nil then
		return { Ok = false, Message = "Still loading your data..." }
	end
	if #Config.DailyRewards == 0 then
		return { Ok = false, Message = "Daily rewards are turned off." }
	end

	local now = os.time()
	local status = Logic.evaluateDaily(profile.Data.LastDailyDay, profile.Data.DailyStreak, now, Config.DailyRewards)
	if not status.canClaim then
		return { Ok = false, Message = "Already claimed today. Come back tomorrow!", State = buildState(player) }
	end

	profile.Data.LastDailyDay = Logic.dayNumber(now)
	profile.Data.DailyStreak = status.streak
	local reward = Logic.sanitizeAmount(status.reward)
	if reward then
		local dayInCycle = ((status.streak - 1) % #Config.DailyRewards) + 1
		MonetizationKit.AddCoins(player, reward, false, Enum.AnalyticsEconomyTransactionType.TimedReward.Name, `DailyDay{dayInCycle}`)
	end
	return {
		Ok = true,
		Message = `+{reward or 0} {Config.CurrencyName}! Day {status.streak} streak`,
		State = buildState(player),
	}
end

redeemCodeRemote.OnServerInvoke = function(player: Player, input: any)
	if not codeLimiter.allow(player, os.time()) then
		return { Ok = false, Message = "Too many attempts. Wait a moment." }
	end
	local profile = PlayerData.get(player)
	if profile == nil then
		return { Ok = false, Message = "Still loading your data..." }
	end

	local ok, message, code = Logic.checkCode(promoCodes, profile.Data.RedeemedCodes, input, os.time())
	if not ok or code == nil then
		return { Ok = false, Message = message }
	end

	local definition = promoCodes[code]
	if definition.Grant then
		local grantOk, err = pcall(definition.Grant, player, profile.Data)
		if not grantOk then
			warn(`[MonetizationKit] Grant for code {code} failed: {err}`)
			return { Ok = false, Message = "Something went wrong. Please try again later." }
		end
	end
	profile.Data.RedeemedCodes[code] = true

	local coins = Logic.sanitizeAmount(definition.Coins)
	if coins then
		MonetizationKit.AddCoins(player, coins, false, "PromoCode", `Code_{code}`)
		message = `Code redeemed! +{coins} {Config.CurrencyName}`
	else
		MonetizationKit._notifyChanged(player)
	end
	return { Ok = true, Message = message, State = buildState(player) }
end

-- Push state changes to the client, at most 4 times per second per player.
local pushQueued: { [Player]: boolean } = {}
MonetizationKit.OnChanged(function(player: Player)
	if pushQueued[player] then
		return
	end
	pushQueued[player] = true
	task.delay(0.25, function()
		pushQueued[player] = nil
		if player.Parent == Players then
			local state = buildState(player)
			if state then
				stateChangedRemote:FireClient(player, state)
			end
		end
	end)
end)

--------------------------------------------------------------------------------
-- Developer products
--------------------------------------------------------------------------------

local receiptDeps: Logic.ReceiptDeps = {
	getProfile = function(userId: number): Logic.ReceiptProfile?
		local player = Players:GetPlayerByUserId(userId)
		if player == nil then
			return nil
		end
		local profile = PlayerData.waitFor(player, 20)
		return if profile then profile :: any else nil
	end,

	grant = function(userId: number, productId: number, _purchaseId: string): boolean
		local player = Players:GetPlayerByUserId(userId)
		local profile = if player then PlayerData.get(player) else nil
		local reward = Config.DeveloperProducts[productId]
		if player == nil or profile == nil or reward == nil then
			return false
		end
		if reward.Grant then
			local customGrant = reward.Grant
			local ok, err = pcall(function()
				customGrant(player, profile.Data)
			end)
			if not ok then
				warn(`[MonetizationKit] Grant for product {productId} failed: {err}`)
				return false
			end
		end
		local coins = Logic.sanitizeAmount(reward.Coins)
		if coins then
			MonetizationKit.AddCoins(player, coins, false, Enum.AnalyticsEconomyTransactionType.IAP.Name, `Product_{productId}`)
		else
			MonetizationKit._notifyChanged(player)
		end
		return true
	end,

	save = function(userId: number): boolean
		local profile = PlayerData.getByUserId(userId)
		return profile ~= nil and PlayerData.save(profile, false)
	end,

	maxHistory = MAX_PURCHASE_HISTORY,
}

local function processReceipt(receipt: { [string]: any }): boolean
	local ok, result = pcall(Logic.processReceipt, receipt, receiptDeps)
	if not ok then
		warn(`[MonetizationKit] Receipt processing error: {result}`)
		return false
	end
	return result
end

local productIds = {}
for productId in Config.DeveloperProducts do
	table.insert(productIds, productId)
end

if #productIds > 0 then
	-- A filtered handler only receives the products listed in Config, so it works
	-- alongside any ProcessReceipt callback your game already has.
	local bound, bindError = pcall(function()
		MarketplaceService:BindReceiptHandler(Enum.ReceiptType.DeveloperProduct, function(receipt: { [string]: any })
			return if processReceipt(receipt) then Enum.ReceiptDecision.Processed else Enum.ReceiptDecision.NotProcessedYet
		end, productIds)
	end)
	if not bound then
		warn(`[MonetizationKit] BindReceiptHandler unavailable ({bindError}). Using ProcessReceipt instead - don't set ProcessReceipt in other scripts.`)
		MarketplaceService.ProcessReceipt = function(receipt: { [string]: any })
			if Config.DeveloperProducts[receipt.ProductId] == nil then
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
			return if processReceipt(receipt)
				then Enum.ProductPurchaseDecision.PurchaseGranted
				else Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end
end

--------------------------------------------------------------------------------
-- Game passes
--------------------------------------------------------------------------------

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player: Player, gamePassId: number, wasPurchased: boolean)
	if wasPurchased and player.Parent == Players then
		MonetizationKit._markPassOwned(player, gamePassId)
	end
end)

local function refreshGamePasses(player: Player)
	for gamePassId in Config.GamePasses do
		task.spawn(function()
			for attempt = 1, 3 do
				local ok, owns = pcall(function()
					return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamePassId)
				end)
				if ok then
					if owns and player.Parent == Players then
						MonetizationKit._markPassOwned(player, gamePassId)
					end
					return
				end
				task.wait(attempt * 2)
			end
			warn(`[MonetizationKit] Could not check game pass {gamePassId} for {player.Name}.`)
		end)
	end
end

--------------------------------------------------------------------------------
-- Player lifecycle
--------------------------------------------------------------------------------

local function onPlayerAdded(player: Player)
	local profile = PlayerData.load(player)
	if profile == nil then
		if player.Parent == Players then
			player:Kick("We couldn't load your data. Please rejoin in a minute.")
		end
		return
	end
	MonetizationKit._createLeaderstats(player, profile.Data.Coins)
	refreshGamePasses(player)
	MonetizationKit._notifyChanged(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

Players.PlayerRemoving:Connect(function(player: Player)
	stateLimiter.forget(player)
	dailyLimiter.forget(player)
	codeLimiter.forget(player)
	PlayerData.release(player)
	MonetizationKit._forgetPlayer(player)
end)

game:BindToClose(function()
	PlayerData.releaseAll()
end)

PlayerData.startAutoSave()

--------------------------------------------------------------------------------
-- Built-in UI
--------------------------------------------------------------------------------

if Config.UseBuiltInUI then
	-- The template is disabled; only this copy in ReplicatedStorage runs on clients.
	local ui = script.Parent.Client.KitUI:Clone()
	ui.Name = "MonetizationKitUI"
	ui.Enabled = true
	ui.Parent = ReplicatedStorage
end
