--!strict
--[[
	PlayerData
	Loads and saves one record per player with a session lock, so a player who
	quickly switches servers can't load stale data (no item/coin duplication or
	loss). Every write uses UpdateAsync.

	Stored record: { Data = Data, Lock = { JobId, Time }?, Version = 1 }
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Config = require(script.Parent.Parent.Config)

export type Data = {
	Coins: number,
	DailyStreak: number,
	LastDailyDay: number,
	RedeemedCodes: { [string]: boolean },
	PurchaseIds: { string },
	Custom: { [string]: any },
}

export type Profile = {
	Player: Player,
	Key: string,
	Data: Data,
	-- Purchase ids granted in memory but not yet confirmed as saved.
	Pending: { [string]: boolean },
	-- True while the final save runs; nothing may change the data anymore.
	Releasing: boolean,
	-- True in Studio without API access: data lives in memory only.
	InMemoryOnly: boolean,
}

local PlayerData = {}

local RECORD_VERSION = 1
local LOAD_ATTEMPTS = 6
local LOAD_RETRY_DELAY = 7
local RELEASE_ATTEMPTS = 3
local AUTOSAVE_INTERVAL = math.max(Config.AutoSaveInterval, 60)
-- A lock not refreshed for this long belongs to a server that died.
local LOCK_EXPIRY = AUTOSAVE_INTERVAL * 3

local isStudio = RunService:IsStudio()
local profiles: { [Player]: Profile } = {}
local store: DataStore? = nil

do
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore(Config.DataStoreName)
	end)
	if ok then
		store = result
	elseif isStudio then
		warn(`[MonetizationKit] DataStores unavailable in Studio ({result}). Data will not be saved. Publish the game and enable "Studio Access to API Services" to test saving.`)
	else
		warn(`[MonetizationKit] Could not open DataStore: {result}`)
	end
end

local function newData(): Data
	return {
		Coins = Config.StartingCoins,
		DailyStreak = 0,
		LastDailyDay = -1,
		RedeemedCodes = {},
		PurchaseIds = {},
		Custom = {},
	}
end

-- Copies saved values over the defaults, ignoring anything of the wrong type.
local function reconcile(saved: any): Data
	local data = newData()
	if type(saved) ~= "table" then
		return data
	end
	if type(saved.Coins) == "number" and saved.Coins == saved.Coins then
		data.Coins = saved.Coins
	end
	if type(saved.DailyStreak) == "number" then
		data.DailyStreak = saved.DailyStreak
	end
	if type(saved.LastDailyDay) == "number" then
		data.LastDailyDay = saved.LastDailyDay
	end
	if type(saved.RedeemedCodes) == "table" then
		for code, value in saved.RedeemedCodes do
			if type(code) == "string" and value == true then
				data.RedeemedCodes[code] = true
			end
		end
	end
	if type(saved.PurchaseIds) == "table" then
		for _, purchaseId in saved.PurchaseIds do
			if type(purchaseId) == "string" then
				table.insert(data.PurchaseIds, purchaseId)
			end
		end
	end
	if type(saved.Custom) == "table" then
		data.Custom = saved.Custom
	end
	return data
end

local function isLockedByOtherServer(record: any, now: number): boolean
	-- Studio test sessions always take the data, so testing is never blocked by a
	-- lock left behind by a live server or a crashed test session.
	if isStudio or type(record) ~= "table" or type(record.Lock) ~= "table" then
		return false
	end
	if record.Lock.JobId == game.JobId then
		return false
	end
	return type(record.Lock.Time) == "number" and now - record.Lock.Time < LOCK_EXPIRY
end

local function newProfile(player: Player, key: string, data: Data, inMemoryOnly: boolean): Profile
	local profile: Profile = {
		Player = player,
		Key = key,
		Data = data,
		Pending = {},
		Releasing = false,
		InMemoryOnly = inMemoryOnly,
	}
	profiles[player] = profile
	return profile
end

-- Loads and locks the player's data. Yields. Returns nil if the player left or
-- the data could not be loaded (the caller should kick the player in that case,
-- so default data never overwrites real data).
function PlayerData.load(player: Player): Profile?
	local key = `Player_{player.UserId}`
	local dataStore = store
	if dataStore == nil then
		return if isStudio then newProfile(player, key, newData(), true) else nil
	end

	for attempt = 1, LOAD_ATTEMPTS do
		local outcome = "error"
		local ok, result = pcall(function()
			return dataStore:UpdateAsync(key, function(old: any)
				if isLockedByOtherServer(old, os.time()) then
					outcome = "locked"
					return nil
				end
				local record = if type(old) == "table" then old else {}
				record.Lock = { JobId = game.JobId, Time = os.time() }
				record.Version = RECORD_VERSION
				outcome = "loaded"
				return record
			end)
		end)

		if player.Parent ~= Players then
			-- Left while loading. If we took the lock, give it back.
			if ok and outcome == "loaded" then
				pcall(function()
					dataStore:UpdateAsync(key, function(old: any)
						if type(old) == "table" and type(old.Lock) == "table" and old.Lock.JobId == game.JobId then
							old.Lock = nil
							return old
						end
						return nil
					end)
				end)
			end
			return nil
		end

		if ok and outcome == "loaded" then
			local record: any = result
			return newProfile(player, key, reconcile(if type(record) == "table" then record.Data else nil), false)
		end

		if not ok then
			warn(`[MonetizationKit] Loading data for {player.Name} failed (attempt {attempt}/{LOAD_ATTEMPTS}): {result}`)
			if isStudio then
				warn(`[MonetizationKit] Using temporary data in Studio. Enable "Studio Access to API Services" to test saving.`)
				return newProfile(player, key, newData(), true)
			end
		end

		if attempt < LOAD_ATTEMPTS then
			task.wait(LOAD_RETRY_DELAY)
		end
	end

	return nil
end

-- Writes the profile. With `release = true` the session lock is removed so the
-- next server can load the data immediately. Returns true on success.
function PlayerData.save(profile: Profile, release: boolean): boolean
	if profile.InMemoryOnly then
		table.clear(profile.Pending)
		return true
	end
	local dataStore = store
	if dataStore == nil then
		return false
	end

	local lostLock = false
	local savedPending: { string } = {}
	local ok, err = pcall(function()
		dataStore:UpdateAsync(profile.Key, function(old: any)
			if not isStudio and type(old) == "table" and type(old.Lock) == "table" and old.Lock.JobId ~= game.JobId then
				-- Another server took over this player's data. Never overwrite it.
				lostLock = true
				return nil
			end
			lostLock = false
			table.clear(savedPending)
			for purchaseId in profile.Pending do
				table.insert(savedPending, purchaseId)
			end
			return {
				Data = profile.Data,
				Lock = if release then nil else { JobId = game.JobId, Time = os.time() },
				Version = RECORD_VERSION,
			}
		end)
	end)

	if not ok then
		warn(`[MonetizationKit] Saving data for {profile.Player.Name} failed: {err}`)
		return false
	end
	if lostLock then
		warn(`[MonetizationKit] {profile.Player.Name}'s data is owned by another server. This server stopped saving it.`)
		profile.Releasing = true
		profiles[profile.Player] = nil
		if profile.Player.Parent == Players then
			profile.Player:Kick("Your data was loaded on another server. Please rejoin.")
		end
		return false
	end

	for _, purchaseId in savedPending do
		profile.Pending[purchaseId] = nil
	end
	return true
end

-- Final save + unlock when a player leaves or the server shuts down. Yields.
function PlayerData.release(player: Player)
	local profile = profiles[player]
	if profile == nil or profile.Releasing then
		return
	end
	profile.Releasing = true
	for attempt = 1, RELEASE_ATTEMPTS do
		if PlayerData.save(profile, true) then
			break
		end
		if attempt < RELEASE_ATTEMPTS then
			task.wait(2 ^ attempt)
		end
	end
	profiles[player] = nil
end

-- The loaded profile, or nil while loading / after the player left.
function PlayerData.get(player: Player): Profile?
	local profile = profiles[player]
	if profile == nil or profile.Releasing then
		return nil
	end
	return profile
end

function PlayerData.getByUserId(userId: number): Profile?
	local player = Players:GetPlayerByUserId(userId)
	return if player then PlayerData.get(player) else nil
end

-- Waits until the player's profile is loaded. Returns nil on timeout or leave.
function PlayerData.waitFor(player: Player, timeout: number?): Profile?
	local deadline = os.clock() + (timeout or 30)
	while player.Parent == Players and os.clock() < deadline do
		local profile = PlayerData.get(player)
		if profile then
			return profile
		end
		task.wait(0.25)
	end
	return PlayerData.get(player)
end

function PlayerData.all(): { Profile }
	local list = {}
	for _, profile in profiles do
		if not profile.Releasing then
			table.insert(list, profile)
		end
	end
	return list
end

-- Periodically saves everyone (this also keeps the session locks fresh).
function PlayerData.startAutoSave()
	task.spawn(function()
		while true do
			task.wait(AUTOSAVE_INTERVAL)
			for _, profile in PlayerData.all() do
				task.spawn(PlayerData.save, profile, false)
			end
		end
	end)
end

-- Saves and unlocks every player. Used from game:BindToClose.
function PlayerData.releaseAll()
	local remaining = 0
	for player in profiles do
		remaining += 1
		task.spawn(function()
			PlayerData.release(player)
			remaining -= 1
		end)
	end
	local deadline = os.clock() + 25
	while remaining > 0 and os.clock() < deadline do
		task.wait(0.1)
	end
end

return PlayerData
