--!strict
--[[
	MonetizationKit API
	Use this from your own server scripts:

		local MonetizationKit = require(game:GetService("ServerScriptService").MonetizationKit.API)

		-- Give coins when a player collects something. `true` applies game pass multipliers.
		MonetizationKit.AddCoins(player, 10, true)

		-- Let players spend coins in your own shop.
		if MonetizationKit.SpendCoins(player, 250, "SpeedCoil") then
			-- give the item
		end

		-- Check a game pass.
		if MonetizationKit.OwnsPass(player, 123456789) then ... end

		-- Store your own values (saved automatically).
		local data = MonetizationKit.WaitForData(player)
		if data then
			data.Custom.Level = (data.Custom.Level or 1) + 1
		end
]]

local AnalyticsService = game:GetService("AnalyticsService")

local Config = require(script.Parent.Config)
local Logic = require(script.Parent.Modules.Logic)
local PlayerData = require(script.Parent.Modules.PlayerData)

export type Data = PlayerData.Data

local MonetizationKit = {}

local changedCallbacks: { (Player) -> () } = {}
local ownedPasses: { [Player]: { [number]: boolean } } = {}

local function notifyChanged(player: Player)
	for _, callback in changedCallbacks do
		task.spawn(callback, player)
	end
end

local function updateLeaderstats(player: Player, coins: number)
	local leaderstats = player:FindFirstChild("leaderstats")
	local value = leaderstats and leaderstats:FindFirstChild(Config.CurrencyName)
	if value and value:IsA("IntValue") then
		value.Value = coins
	end
end

local function logEconomy(player: Player, flowType: Enum.AnalyticsEconomyFlowType, amount: number, endingBalance: number, transactionType: string, sku: string?)
	-- Shows up in Creator Hub > Analytics > Economy. Failing analytics must never break the game.
	pcall(function()
		AnalyticsService:LogEconomyEvent(player, flowType, Config.CurrencyName, amount, endingBalance, transactionType, sku)
	end)
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

-- Calls `callback(player)` whenever coins, streaks, codes or passes change.
function MonetizationKit.OnChanged(callback: (Player) -> ())
	table.insert(changedCallbacks, callback)
end

function MonetizationKit.IsLoaded(player: Player): boolean
	return PlayerData.get(player) ~= nil
end

-- The player's live data table (nil while loading). Changes are saved automatically.
-- Put your own values into `data.Custom` (numbers, strings, booleans and plain tables only).
function MonetizationKit.GetData(player: Player): Data?
	local profile = PlayerData.get(player)
	return if profile then profile.Data else nil
end

-- Like GetData, but waits up to `timeout` seconds (default 30) for the data to load.
function MonetizationKit.WaitForData(player: Player, timeout: number?): Data?
	local profile = PlayerData.waitFor(player, timeout)
	return if profile then profile.Data else nil
end

function MonetizationKit.GetCoins(player: Player): number?
	local profile = PlayerData.get(player)
	return if profile then profile.Data.Coins else nil
end

function MonetizationKit.OwnsPass(player: Player, gamePassId: number): boolean
	local owned = ownedPasses[player]
	return owned ~= nil and owned[gamePassId] == true
end

-- Combined coin multiplier from all owned game passes.
function MonetizationKit.GetCoinMultiplier(player: Player): number
	local multipliers = {}
	local owned = ownedPasses[player]
	if owned then
		for gamePassId in owned do
			local perk = Config.GamePasses[gamePassId]
			if perk and perk.CoinMultiplier then
				table.insert(multipliers, perk.CoinMultiplier)
			end
		end
	end
	return Logic.combineMultipliers(multipliers)
end

-- Adds coins. Returns the new balance, or nil if the data isn't loaded or the amount is invalid.
-- transactionType/sku are optional labels for the Economy analytics dashboard.
function MonetizationKit.AddCoins(player: Player, amount: number, applyMultiplier: boolean?, transactionType: string?, sku: string?): number?
	local profile = PlayerData.get(player)
	local base = Logic.sanitizeAmount(amount)
	if profile == nil or base == nil then
		return nil
	end
	local total = if applyMultiplier then math.floor(base * MonetizationKit.GetCoinMultiplier(player)) else base
	profile.Data.Coins += total
	updateLeaderstats(player, profile.Data.Coins)
	logEconomy(player, Enum.AnalyticsEconomyFlowType.Source, total, profile.Data.Coins, transactionType or Enum.AnalyticsEconomyTransactionType.Gameplay.Name, sku)
	notifyChanged(player)
	return profile.Data.Coins
end

-- Removes coins if the player has enough. Returns true on success.
function MonetizationKit.SpendCoins(player: Player, amount: number, sku: string?, transactionType: string?): boolean
	local profile = PlayerData.get(player)
	local cost = Logic.sanitizeAmount(amount)
	if profile == nil or cost == nil or profile.Data.Coins < cost then
		return false
	end
	profile.Data.Coins -= cost
	updateLeaderstats(player, profile.Data.Coins)
	logEconomy(player, Enum.AnalyticsEconomyFlowType.Sink, cost, profile.Data.Coins, transactionType or Enum.AnalyticsEconomyTransactionType.Shop.Name, sku)
	notifyChanged(player)
	return true
end

--------------------------------------------------------------------------------
-- Internal (used by the kit itself)
--------------------------------------------------------------------------------

function MonetizationKit._notifyChanged(player: Player)
	notifyChanged(player)
end

function MonetizationKit._createLeaderstats(player: Player, coins: number)
	if not Config.ShowOnLeaderboard then
		return
	end
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats == nil then
		local folder = Instance.new("Folder")
		folder.Name = "leaderstats"
		folder.Parent = player
		leaderstats = folder
	end
	local value = Instance.new("IntValue")
	value.Name = Config.CurrencyName
	value.Value = coins
	value.Parent = leaderstats
end

function MonetizationKit._markPassOwned(player: Player, gamePassId: number)
	local perk = Config.GamePasses[gamePassId]
	if perk == nil then
		return
	end
	local owned = ownedPasses[player]
	if owned == nil then
		owned = {}
		ownedPasses[player] = owned
	end
	if owned[gamePassId] then
		return
	end
	owned[gamePassId] = true
	if perk.OnOwned then
		local onOwned = perk.OnOwned
		task.spawn(function()
			local ok, err = pcall(function()
				onOwned(player)
			end)
			if not ok then
				warn(`[MonetizationKit] OnOwned for game pass {gamePassId} failed: {err}`)
			end
		end)
	end
	notifyChanged(player)
end

function MonetizationKit._forgetPlayer(player: Player)
	ownedPasses[player] = nil
end

return MonetizationKit
