--!strict
-- Unit tests for the engine-independent logic. Run with the Luau CLI:
--   luau tests/run.luau
local Logic = require("../src/Modules/Logic")

local passed, failed = 0, 0

local function check(name: string, condition: boolean)
	if condition then
		passed += 1
	else
		failed += 1
		print("FAIL: " .. name)
	end
end

local DAY = 86400

-- Dates ----------------------------------------------------------------------
check("epoch is day 0", Logic.daysFromCivil(1970, 1, 1) == 0)
check("2000-03-01", Logic.daysFromCivil(2000, 3, 1) == 11017)
check("2026-09-30", Logic.daysFromCivil(2026, 9, 30) == 20726)
check("1969-12-31 is day -1", Logic.daysFromCivil(1969, 12, 31) == -1)
check("dayNumber at midnight", Logic.dayNumber(20726 * DAY) == 20726)
check("dayNumber one second before midnight", Logic.dayNumber(20726 * DAY - 1) == 20725)

check("expiry is end of UTC day", Logic.parseExpiry("2026-12-31") == (Logic.daysFromCivil(2026, 12, 31) + 1) * DAY - 1)
check("leap day valid in 2028", Logic.parseExpiry("2028-02-29") ~= nil)
check("leap day invalid in 2027", Logic.parseExpiry("2027-02-29") == nil)
check("leap day invalid in 2100", Logic.parseExpiry("2100-02-29") == nil)
check("leap day valid in 2000", Logic.parseExpiry("2000-02-29") ~= nil)
check("month 13 invalid", Logic.parseExpiry("2026-13-01") == nil)
check("day 31 in April invalid", Logic.parseExpiry("2026-04-31") == nil)
check("wrong format invalid", Logic.parseExpiry("31.12.2026") == nil)
check("trailing text invalid", Logic.parseExpiry("2026-12-31x") == nil)

-- Amounts --------------------------------------------------------------------
check("sanitize floors", Logic.sanitizeAmount(10.9) == 10)
check("sanitize rejects zero", Logic.sanitizeAmount(0) == nil)
check("sanitize rejects negative", Logic.sanitizeAmount(-5) == nil)
check("sanitize rejects NaN", Logic.sanitizeAmount(0 / 0) == nil)
check("sanitize rejects inf", Logic.sanitizeAmount(math.huge) == nil)
check("sanitize rejects string", Logic.sanitizeAmount("100") == nil)
check("sanitize rejects 0.5", Logic.sanitizeAmount(0.5) == nil)
check("multipliers stack", Logic.combineMultipliers({ 2, 3 }) == 6)
check("no multipliers is 1x", Logic.combineMultipliers({}) == 1)
check("bad multipliers ignored", Logic.combineMultipliers({ 2, -1, 0 / 0 }) == 2)

-- Daily rewards ----------------------------------------------------------------
local rewards = { 10, 20, 30 }
local today = 20726
local noon = today * DAY + DAY // 2

local first = Logic.evaluateDaily(-1, 0, noon, rewards)
check("first claim available", first.canClaim and first.streak == 1 and first.reward == 10)

local consecutive = Logic.evaluateDaily(today - 1, 1, noon, rewards)
check("consecutive day continues streak", consecutive.canClaim and consecutive.streak == 2 and consecutive.reward == 20)

local missed = Logic.evaluateDaily(today - 2, 5, noon, rewards)
check("missed day resets streak", missed.canClaim and missed.streak == 1 and missed.reward == 10)

local claimed = Logic.evaluateDaily(today, 2, noon, rewards)
check("same day not claimable", not claimed.canClaim)
check("shows tomorrow's reward", claimed.reward == 30)
check("countdown to UTC midnight", claimed.secondsUntilNext == DAY // 2)

local cycled = Logic.evaluateDaily(today - 1, 3, noon, rewards)
check("rewards cycle after last entry", cycled.streak == 4 and cycled.reward == 10)

local future = Logic.evaluateDaily(today + 1, 2, noon, rewards)
check("claim day in the future is not claimable", not future.canClaim)

check("empty reward table gives 0", Logic.evaluateDaily(-1, 0, noon, {}).reward == 0)

-- Promo codes ------------------------------------------------------------------
local codes, problems = Logic.prepareCodes({
	welcome = { Coins = 100 },
	[" Launch 2026 "] = { Coins = 250, Expires = "2026-12-31" },
	OLD = { Coins = 5, Expires = "2020-01-01" },
	BROKEN = { Coins = 5, Expires = "tomorrow" },
})
check("codes normalized", codes.WELCOME ~= nil and codes.LAUNCH2026 ~= nil)
check("invalid expiry reported and skipped", #problems == 1 and codes.BROKEN == nil)

local _, duplicateProblems = Logic.prepareCodes({ abc = { Coins = 1 }, ABC = { Coins = 2 } })
check("duplicate codes reported", #duplicateProblems == 1)

local ok1, _, code1 = Logic.checkCode(codes, {}, "  welcome ", noon)
check("case and whitespace insensitive", ok1 and code1 == "WELCOME")

local ok2, message2 = Logic.checkCode(codes, { WELCOME = true }, "WELCOME", noon)
check("already redeemed rejected", not ok2 and string.find(message2, "already") ~= nil)

local ok3, message3 = Logic.checkCode(codes, {}, "OLD", noon)
check("expired code rejected", not ok3 and string.find(message3, "expired") ~= nil)

local lastSecond = Logic.parseExpiry("2026-12-31") :: number
check("code valid on its last second", (Logic.checkCode(codes, {}, "launch2026", lastSecond)))
check("code invalid one second later", not (Logic.checkCode(codes, {}, "launch2026", lastSecond + 1)))

check("unknown code rejected", not (Logic.checkCode(codes, {}, "NOPE", noon)))
check("non-string rejected", not (Logic.checkCode(codes, {}, 12345, noon)))
check("empty rejected", not (Logic.checkCode(codes, {}, "", noon)))
check("very long input rejected", not (Logic.checkCode(codes, {}, string.rep("A", 65), noon)))

-- Rate limiter -----------------------------------------------------------------
local limiter = Logic.newRateLimiter(2, 10)
check("1st call allowed", limiter.allow("p", 0))
check("2nd call allowed", limiter.allow("p", 1))
check("3rd call blocked", not limiter.allow("p", 2))
check("other key independent", limiter.allow("q", 2))
check("allowed again after window", limiter.allow("p", 10))
limiter.forget("p")
check("forget resets", limiter.allow("p", 10) and limiter.allow("p", 10))

-- Receipts -----------------------------------------------------------------------
local function makeWorld()
	local world = {
		profile = { Data = { PurchaseIds = {} :: { string } }, Pending = {} :: { [string]: boolean } },
		coins = 0,
		saves = 0,
		saveWorks = true,
		grantWorks = true,
		loaded = true,
	}
	local deps: Logic.ReceiptDeps = {
		getProfile = function(_userId)
			return if world.loaded then world.profile else nil
		end,
		grant = function(_userId, _productId, _purchaseId)
			if not world.grantWorks then
				return false
			end
			world.coins += 100
			return true
		end,
		save = function(_userId)
			world.saves += 1
			if world.saveWorks then
				table.clear(world.profile.Pending)
				return true
			end
			return false
		end,
		maxHistory = 3,
	}
	return world, deps
end

local receipt = { PlayerId = 1, ProductId = 42, PurchaseId = "abc" }

do
	local world, deps = makeWorld()
	check("receipt granted", Logic.processReceipt(receipt, deps) and world.coins == 100)
	check("duplicate receipt does not grant twice", Logic.processReceipt(receipt, deps) and world.coins == 100)
end

do
	local world, deps = makeWorld()
	world.loaded = false
	check("not loaded -> not processed", not Logic.processReceipt(receipt, deps) and world.coins == 0)
end

do
	local world, deps = makeWorld()
	world.grantWorks = false
	check("failed grant -> not processed, nothing recorded", not Logic.processReceipt(receipt, deps) and #world.profile.Data.PurchaseIds == 0)
	world.grantWorks = true
	check("retry after failed grant works", Logic.processReceipt(receipt, deps) and world.coins == 100)
end

do
	local world, deps = makeWorld()
	world.saveWorks = false
	check("save failure -> not processed", not Logic.processReceipt(receipt, deps) and world.coins == 100)
	check("redelivery while still unsaved -> not processed, no double grant", not Logic.processReceipt(receipt, deps) and world.coins == 100)
	world.saveWorks = true
	check("redelivery after save works -> processed, no double grant", Logic.processReceipt(receipt, deps) and world.coins == 100)
	check("pending cleared", next(world.profile.Pending) == nil)
end

do
	local world, deps = makeWorld()
	for i = 1, 5 do
		Logic.processReceipt({ PlayerId = 1, ProductId = 42, PurchaseId = "id" .. i }, deps)
	end
	check("history trimmed to max", #world.profile.Data.PurchaseIds == 3 and world.profile.Data.PurchaseIds[1] == "id3")
	check("five different receipts grant five times", world.coins == 500)
end

do
	local _, deps = makeWorld()
	check("malformed receipt rejected", not Logic.processReceipt({ PlayerId = "x", ProductId = 42, PurchaseId = "z" }, deps))
end

print(`{passed} passed, {failed} failed`)
if failed > 0 then
	error("tests failed")
end
