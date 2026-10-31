--!strict
--[[
	MonetizationKit - Config
	Everything you need to change lives in this file.

	1. Create your Developer Products and Game Passes in the Creator Hub
	   (Creator Hub > your game > Monetization) and copy their IDs below.
	2. Enable "Studio Access to API Services" in Game Settings > Security if you
	   want data to save while testing in Studio.
	3. Press Play.
]]

export type ProductReward = {
	-- Currency the buyer receives.
	Coins: number?,
	-- Optional custom reward. Runs BEFORE coins are added. If it errors, nothing is
	-- granted and Roblox will retry the purchase later. `data.Custom` is a table
	-- you can freely use to store your own values (it is saved for you).
	Grant: ((player: Player, data: any) -> ())?,
}

export type GamePassPerk = {
	-- Shown in the built-in shop if the pass info can't be loaded.
	Name: string?,
	-- Multiplies coins given through MonetizationKit.AddCoins(player, amount, true).
	-- Several passes stack multiplicatively (2x and 3x = 6x).
	CoinMultiplier: number?,
	-- Called once per session when ownership is detected (on join or right after purchase).
	OnOwned: ((player: Player) -> ())?,
}

export type PromoCode = {
	Coins: number?,
	-- Last valid day in UTC, format "YYYY-MM-DD". Leave out for codes that never expire.
	Expires: string?,
	-- Optional custom reward, same rules as ProductReward.Grant.
	Grant: ((player: Player, data: any) -> ())?,
}

local Config = {}

-- Currency --------------------------------------------------------------------

-- Name shown on the leaderboard and in the built-in UI.
Config.CurrencyName = "Coins"

-- Coins a brand-new player starts with.
Config.StartingCoins = 0

-- Show the currency on the default Roblox leaderboard (leaderstats).
Config.ShowOnLeaderboard = true

-- Saving ------------------------------------------------------------------------

-- Changing this name starts everyone with fresh data. Keep it stable after launch.
Config.DataStoreName = "MonetizationKit_v1"

-- Seconds between automatic saves (minimum 60).
Config.AutoSaveInterval = 90

-- Built-in UI -------------------------------------------------------------------

-- Adds Daily / Codes / Shop buttons on the left side of the screen.
-- Set to false if you build your own UI (see README for the remote API).
Config.UseBuiltInUI = true

-- Developer Products ------------------------------------------------------------
-- [productId] = reward
Config.DeveloperProducts = {
	-- [1234567890] = { Coins = 500 },
	-- [1234567891] = { Coins = 3000 },
	-- [1234567892] = {
	-- 	Grant = function(player, data)
	-- 		data.Custom.Revives = (data.Custom.Revives or 0) + 1
	-- 	end,
	-- },
} :: { [number]: ProductReward }

-- Game Passes -------------------------------------------------------------------
-- [gamePassId] = perks
Config.GamePasses = {
	-- [123456789] = { Name = "2x Coins", CoinMultiplier = 2 },
	-- [123456790] = {
	-- 	Name = "VIP",
	-- 	OnOwned = function(player)
	-- 		player:SetAttribute("VIP", true)
	-- 	end,
	-- },
} :: { [number]: GamePassPerk }

-- Daily Rewards -----------------------------------------------------------------
-- Coins for day 1, day 2, ... of a login streak. After the last day it starts over.
-- Missing a day (UTC) resets the streak. Set to {} to disable daily rewards.
Config.DailyRewards = { 50, 75, 100, 150, 200, 300, 500 } :: { number }

-- Promo Codes -------------------------------------------------------------------
-- Case-insensitive. Each player can redeem each code once.
-- Codes stay on the server and are never sent to players.
Config.PromoCodes = {
	WELCOME = { Coins = 100 },
	-- LAUNCH = { Coins = 250, Expires = "2026-12-31" },
} :: { [string]: PromoCode }

return Config
