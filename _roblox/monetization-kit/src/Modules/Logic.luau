--!strict
--[[
	Logic
	Pure, engine-independent logic used by MonetizationKit.
	No Roblox services are used here, so everything in this module is unit tested
	outside of Studio (see tests/run.luau in the source repository).
]]

local Logic = {}

local SECONDS_PER_DAY = 86400

--------------------------------------------------------------------------------
-- Dates (UTC)
--------------------------------------------------------------------------------

-- Whole days since 1970-01-01 (UTC) for a unix timestamp.
function Logic.dayNumber(unixTime: number): number
	return unixTime // SECONDS_PER_DAY
end

-- Days since 1970-01-01 for a civil date (proleptic Gregorian calendar, UTC).
-- Algorithm: Howard Hinnant, "days_from_civil".
function Logic.daysFromCivil(year: number, month: number, day: number): number
	local y = if month <= 2 then year - 1 else year
	local era = (if y >= 0 then y else y - 399) // 400
	local yoe = y - era * 400
	local mp = (month + 9) % 12
	local doy = (153 * mp + 2) // 5 + day - 1
	local doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
	return era * 146097 + doe - 719468
end

local DAYS_IN_MONTH = { 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

-- Parses "YYYY-MM-DD" and returns the unix timestamp of the LAST second of that
-- UTC day (so a code with Expires = "2026-12-31" works all of Dec 31st).
-- Returns nil for malformed dates.
function Logic.parseExpiry(dateString: string): number?
	local ys, ms, ds = string.match(dateString, "^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
	if ys == nil or ms == nil or ds == nil then
		return nil
	end
	local year, month, day = tonumber(ys), tonumber(ms), tonumber(ds)
	if year == nil or month == nil or day == nil then
		return nil
	end
	if month < 1 or month > 12 or day < 1 or day > DAYS_IN_MONTH[month] then
		return nil
	end
	local isLeap = (year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0
	if month == 2 and day == 29 and not isLeap then
		return nil
	end
	return (Logic.daysFromCivil(year, month, day) + 1) * SECONDS_PER_DAY - 1
end

--------------------------------------------------------------------------------
-- Amounts
--------------------------------------------------------------------------------

-- Returns a positive whole number, or nil if the value is not a usable amount
-- (non-number, NaN, infinite, zero or negative).
function Logic.sanitizeAmount(value: any): number?
	if type(value) ~= "number" then
		return nil
	end
	if value ~= value or value == math.huge or value == -math.huge then
		return nil
	end
	local whole = math.floor(value)
	if whole <= 0 then
		return nil
	end
	return whole
end

-- Multipliers from several game passes stack multiplicatively (2x and 3x = 6x).
function Logic.combineMultipliers(multipliers: { number }): number
	local total = 1
	for _, multiplier in multipliers do
		if type(multiplier) == "number" and multiplier > 0 and multiplier == multiplier then
			total *= multiplier
		end
	end
	return total
end

--------------------------------------------------------------------------------
-- Daily rewards
--------------------------------------------------------------------------------

export type DailyStatus = {
	canClaim: boolean,
	-- Streak the player will have after claiming (or currently has, if already claimed today).
	streak: number,
	-- Reward for the claim that is available now, or for tomorrow's claim if already claimed.
	reward: number,
	-- Seconds until the next claim becomes available (0 if claimable now).
	secondsUntilNext: number,
}

function Logic.dailyRewardFor(streak: number, rewards: { number }): number
	if #rewards == 0 or streak < 1 then
		return 0
	end
	return rewards[((streak - 1) % #rewards) + 1]
end

-- lastClaimDay is the UTC day number of the last claim (-1 if never claimed).
-- A claim on the day right after the last claim continues the streak; missing a
-- day resets it to 1. Rewards cycle after the last entry of the table.
function Logic.evaluateDaily(lastClaimDay: number, streak: number, now: number, rewards: { number }): DailyStatus
	local today = Logic.dayNumber(now)
	if lastClaimDay >= today then
		return {
			canClaim = false,
			streak = streak,
			reward = Logic.dailyRewardFor(streak + 1, rewards),
			secondsUntilNext = (today + 1) * SECONDS_PER_DAY - now,
		}
	end
	local newStreak = if lastClaimDay == today - 1 then streak + 1 else 1
	return {
		canClaim = true,
		streak = newStreak,
		reward = Logic.dailyRewardFor(newStreak, rewards),
		secondsUntilNext = 0,
	}
end

--------------------------------------------------------------------------------
-- Promo codes
--------------------------------------------------------------------------------

-- Codes are case-insensitive and ignore whitespace: " launch 2026 " == "LAUNCH2026".
function Logic.normalizeCode(input: string): string
	return string.upper((string.gsub(input, "%s+", "")))
end

-- Returns a copy of the configured codes keyed by their normalized form, plus a
-- list of human-readable problems found in the configuration.
function Logic.prepareCodes(codes: { [string]: any }): ({ [string]: any }, { string })
	local prepared: { [string]: any } = {}
	local problems: { string } = {}
	for rawCode, definition in codes do
		local code = Logic.normalizeCode(rawCode)
		if code == "" then
			table.insert(problems, "Empty promo code name in Config.PromoCodes")
		elseif prepared[code] ~= nil then
			table.insert(problems, `Duplicate promo code "{code}" in Config.PromoCodes`)
		elseif type(definition) ~= "table" then
			table.insert(problems, `Promo code "{code}" must be a table like \{ Coins = 100 \}`)
		elseif definition.Expires ~= nil and (type(definition.Expires) ~= "string" or Logic.parseExpiry(definition.Expires) == nil) then
			table.insert(problems, `Promo code "{code}" has an invalid Expires value (use "YYYY-MM-DD")`)
		else
			prepared[code] = definition
		end
	end
	return prepared, problems
end

-- Checks whether `input` can be redeemed. `codes` must come from prepareCodes.
-- Returns success, a message for the player and the normalized code on success.
function Logic.checkCode(codes: { [string]: any }, redeemed: { [string]: boolean }, input: any, now: number): (boolean, string, string?)
	if type(input) ~= "string" or #input == 0 or #input > 64 then
		return false, "Please enter a code.", nil
	end
	local code = Logic.normalizeCode(input)
	local definition = codes[code]
	if definition == nil then
		return false, "That code doesn't exist.", nil
	end
	if redeemed[code] then
		return false, "You already redeemed this code.", nil
	end
	if definition.Expires ~= nil then
		local expiry = Logic.parseExpiry(definition.Expires)
		if expiry == nil or now > expiry then
			return false, "This code has expired.", nil
		end
	end
	return true, "Code redeemed!", code
end

--------------------------------------------------------------------------------
-- Rate limiting
--------------------------------------------------------------------------------

export type RateLimiter = {
	allow: (key: any, now: number) -> boolean,
	forget: (key: any) -> (),
}

-- Allows at most `maxCalls` per `windowSeconds` for each key.
function Logic.newRateLimiter(maxCalls: number, windowSeconds: number): RateLimiter
	local history: { [any]: { number } } = {}

	local function allow(key: any, now: number): boolean
		local calls = history[key]
		if calls == nil then
			calls = {}
			history[key] = calls
		end
		local index = 1
		while index <= #calls do
			if now - calls[index] >= windowSeconds then
				table.remove(calls, index)
			else
				index += 1
			end
		end
		if #calls >= maxCalls then
			return false
		end
		table.insert(calls, now)
		return true
	end

	local function forget(key: any)
		history[key] = nil
	end

	return { allow = allow, forget = forget }
end

--------------------------------------------------------------------------------
-- Developer product receipts
--------------------------------------------------------------------------------

export type ReceiptProfile = {
	Data: { PurchaseIds: { string } },
	-- Purchase ids that were granted in memory but not yet written to the DataStore.
	Pending: { [string]: boolean },
}

export type ReceiptDeps = {
	-- The buyer's loaded profile, or nil if it isn't loaded (or is being released).
	getProfile: (userId: number) -> ReceiptProfile?,
	-- Grants the product. Must either grant everything and return true, or grant
	-- nothing and return false.
	grant: (userId: number, productId: number, purchaseId: string) -> boolean,
	-- Writes the buyer's profile to the DataStore. Clears saved ids from Pending.
	save: (userId: number) -> boolean,
	maxHistory: number,
}

-- Idempotent receipt processing. The purchase id is stored in the SAME record as
-- the granted currency, so "granted" and "remembered as granted" are always
-- saved together. Returns true only once the grant is safely persisted, which
-- is when Roblox may close the receipt. Redelivered receipts never grant twice.
function Logic.processReceipt(receipt: { [string]: any }, deps: ReceiptDeps): boolean
	local userId = receipt.PlayerId
	local productId = receipt.ProductId
	local purchaseId = tostring(receipt.PurchaseId)
	if type(userId) ~= "number" or type(productId) ~= "number" then
		return false
	end

	local profile = deps.getProfile(userId)
	if profile == nil then
		return false
	end

	local history = profile.Data.PurchaseIds
	if table.find(history, purchaseId) ~= nil then
		-- Already granted. Only confirm once that grant has been persisted.
		if profile.Pending[purchaseId] then
			return deps.save(userId)
		end
		return true
	end

	if not deps.grant(userId, productId, purchaseId) then
		return false
	end

	table.insert(history, purchaseId)
	while #history > deps.maxHistory do
		table.remove(history, 1)
	end
	profile.Pending[purchaseId] = true

	return deps.save(userId)
end

return Logic
