--!strict
--[[
	MonetizationKit - built-in player UI (Daily reward, Codes, Shop).
	This template is disabled. The server clones an enabled copy into
	ReplicatedStorage when Config.UseBuiltInUI is true.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

if script.Parent ~= ReplicatedStorage then
	return
end

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("MonetizationKitRemotes")
local getStateRemote = remotes:WaitForChild("GetState") :: RemoteFunction
local claimDailyRemote = remotes:WaitForChild("ClaimDaily") :: RemoteFunction
local redeemCodeRemote = remotes:WaitForChild("RedeemCode") :: RemoteFunction
local stateChangedRemote = remotes:WaitForChild("StateChanged") :: RemoteEvent

local COLORS = {
	panel = Color3.fromRGB(24, 26, 33),
	surface = Color3.fromRGB(38, 41, 52),
	text = Color3.fromRGB(240, 242, 247),
	muted = Color3.fromRGB(160, 166, 180),
	accent = Color3.fromRGB(88, 101, 242),
	good = Color3.fromRGB(67, 181, 129),
	bad = Color3.fromRGB(237, 66, 69),
	gold = Color3.fromRGB(250, 196, 55),
}

--------------------------------------------------------------------------------
-- Small helpers
--------------------------------------------------------------------------------

local function create(className: string, props: { [string]: any }, children: { any }?): any
	local instance = (Instance.new :: any)(className)
	for key, value in props do
		instance[key] = value
	end
	if children then
		for _, child in children do
			child.Parent = instance
		end
	end
	return instance
end

local function corner(radius: number): UICorner
	return create("UICorner", { CornerRadius = UDim.new(0, radius) })
end

local function label(props: { [string]: any }): TextLabel
	local defaults = {
		BackgroundTransparency = 1,
		Font = Enum.Font.BuilderSans,
		TextColor3 = COLORS.text,
		TextSize = 18,
		TextWrapped = true,
	}
	for key, value in props do
		defaults[key] = value
	end
	return create("TextLabel", defaults)
end

local function button(text: string, color: Color3, props: { [string]: any }?): TextButton
	local instance = create("TextButton", {
		Text = text,
		Font = Enum.Font.BuilderSansBold,
		TextSize = 18,
		TextColor3 = COLORS.text,
		BackgroundColor3 = color,
		AutoButtonColor = true,
	}, { corner(10) })
	if props then
		for key, value in props do
			(instance :: any)[key] = value
		end
	end
	return instance
end

local function formatNumber(value: number): string
	local text = tostring(math.floor(value))
	local formatted = text
	repeat
		local count
		formatted, count = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
	until count == 0
	return formatted
end

local function formatDuration(seconds: number): string
	seconds = math.max(0, math.floor(seconds))
	return string.format("%02d:%02d:%02d", seconds // 3600, (seconds % 3600) // 60, seconds % 60)
end

--------------------------------------------------------------------------------
-- Layout
--------------------------------------------------------------------------------

local screen = create("ScreenGui", {
	Name = "MonetizationKitUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

local sidebar = create("Frame", {
	Name = "Sidebar",
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 12, 0.5, 0),
	Size = UDim2.fromOffset(130, 200),
	BackgroundTransparency = 1,
	Parent = screen,
}, {
	create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
})

local coinLabel = label({
	Name = "Coins",
	LayoutOrder = 0,
	Size = UDim2.fromOffset(130, 34),
	BackgroundTransparency = 0.15,
	BackgroundColor3 = COLORS.panel,
	TextColor3 = COLORS.gold,
	Font = Enum.Font.BuilderSansBold,
	Text = "...",
	Parent = sidebar,
})
corner(10).Parent = coinLabel

local dailyButton = button("🎁 Daily", COLORS.accent, { LayoutOrder = 1, Size = UDim2.fromOffset(130, 40), Parent = sidebar })
local codesButton = button("🏷️ Codes", COLORS.surface, { LayoutOrder = 2, Size = UDim2.fromOffset(130, 40), Parent = sidebar })
local shopButton = button("🛒 Shop", COLORS.surface, { LayoutOrder = 3, Size = UDim2.fromOffset(130, 40), Parent = sidebar })

local dailyBadge = create("Frame", {
	Name = "Badge",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(1, -4, 0, 4),
	Size = UDim2.fromOffset(14, 14),
	BackgroundColor3 = COLORS.bad,
	Visible = false,
	Parent = dailyButton,
}, { corner(7) })

local panel = create("Frame", {
	Name = "Panel",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.9, 0.7),
	BackgroundColor3 = COLORS.panel,
	Visible = false,
	Parent = screen,
}, {
	corner(16),
	create("UISizeConstraint", { MaxSize = Vector2.new(440, 380) }),
	create("UIPadding", {
		PaddingTop = UDim.new(0, 14),
		PaddingBottom = UDim.new(0, 14),
		PaddingLeft = UDim.new(0, 16),
		PaddingRight = UDim.new(0, 16),
	}),
})

local titleLabel = label({
	Name = "Title",
	Size = UDim2.new(1, -40, 0, 30),
	Font = Enum.Font.BuilderSansBold,
	TextSize = 24,
	TextXAlignment = Enum.TextXAlignment.Left,
	Text = "",
	Parent = panel,
})

local closeButton = button("✕", COLORS.surface, {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, 0, 0, 0),
	Size = UDim2.fromOffset(32, 32),
	Parent = panel,
})

local function page(name: string): Frame
	return create("Frame", {
		Name = name,
		Position = UDim2.fromOffset(0, 44),
		Size = UDim2.new(1, 0, 1, -44),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = panel,
	})
end

-- Daily page
local dailyPage = page("DailyPage")
local streakLabel = label({ Size = UDim2.new(1, 0, 0, 26), TextSize = 20, Font = Enum.Font.BuilderSansBold, Parent = dailyPage })
local rewardLabel = label({ Position = UDim2.fromOffset(0, 30), Size = UDim2.new(1, 0, 0, 24), TextColor3 = COLORS.muted, Parent = dailyPage })
local dayStrip = create("Frame", {
	Position = UDim2.fromOffset(0, 66),
	Size = UDim2.new(1, 0, 0, 64),
	BackgroundTransparency = 1,
	Parent = dailyPage,
}, {
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
})
local claimButton = button("Claim", COLORS.good, {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, 0),
	Size = UDim2.new(1, 0, 0, 48),
	TextSize = 22,
	Parent = dailyPage,
})

-- Codes page
local codesPage = page("CodesPage")
label({
	Size = UDim2.new(1, 0, 0, 24),
	TextColor3 = COLORS.muted,
	Text = "Got a code? Enter it below.",
	Parent = codesPage,
})
local codeBox = create("TextBox", {
	Position = UDim2.fromOffset(0, 36),
	Size = UDim2.new(1, 0, 0, 48),
	BackgroundColor3 = COLORS.surface,
	TextColor3 = COLORS.text,
	PlaceholderText = "Enter code",
	PlaceholderColor3 = COLORS.muted,
	Font = Enum.Font.BuilderSansBold,
	TextSize = 22,
	Text = "",
	ClearTextOnFocus = false,
	Parent = codesPage,
}, { corner(10) })
local redeemButton = button("Redeem", COLORS.accent, {
	Position = UDim2.fromOffset(0, 96),
	Size = UDim2.new(1, 0, 0, 48),
	TextSize = 22,
	Parent = codesPage,
})
local codeResult = label({ Position = UDim2.fromOffset(0, 154), Size = UDim2.new(1, 0, 0, 48), Text = "", Parent = codesPage })

-- Shop page
local shopPage = page("ShopPage")
local shopList = create("ScrollingFrame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 6,
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	CanvasSize = UDim2.new(),
	Parent = shopPage,
}, {
	create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
})

-- Toast
local toast = label({
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -24),
	Size = UDim2.fromOffset(360, 44),
	BackgroundColor3 = COLORS.panel,
	BackgroundTransparency = 0.1,
	Font = Enum.Font.BuilderSansBold,
	Visible = false,
	Parent = screen,
})
corner(12).Parent = toast

local toastToken = 0
local function showToast(message: string, success: boolean)
	toastToken += 1
	local token = toastToken
	toast.Text = message
	toast.TextColor3 = if success then COLORS.good else COLORS.bad
	toast.TextTransparency = 0
	toast.BackgroundTransparency = 0.1
	toast.Visible = true
	task.delay(2.5, function()
		if token ~= toastToken then
			return
		end
		local info = TweenInfo.new(0.4)
		TweenService:Create(toast, info, { TextTransparency = 1, BackgroundTransparency = 1 }):Play()
		task.wait(0.4)
		if token == toastToken then
			toast.Visible = false
		end
	end)
end

--------------------------------------------------------------------------------
-- State & rendering
--------------------------------------------------------------------------------

local state: { [string]: any }? = nil
local nextDailyAt = 0
local shopSignature = ""
local shopGeneration = 0
local productInfoCache: { [string]: { [string]: any } } = {}

local function renderDaily()
	local current = state
	if current == nil then
		return
	end
	local daily = current.Daily
	local currency = current.CurrencyName
	local rewards: { number } = current.DailyRewards

	if daily.CanClaim then
		streakLabel.Text = if daily.Streak > 1 then `🔥 Day {daily.Streak} streak!` else "Welcome! Claim your daily reward"
		rewardLabel.Text = `Today: {formatNumber(daily.Reward)} {currency}`
	else
		streakLabel.Text = `🔥 {daily.Streak} day streak`
		rewardLabel.Text = `Tomorrow: {formatNumber(daily.Reward)} {currency}`
	end

	for _, child in dayStrip:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	local highlight = if #rewards > 0 then ((if daily.CanClaim then daily.Streak else daily.Streak + 1) - 1) % #rewards + 1 else 0
	local tileWidth = math.min(52, math.floor(380 / math.max(#rewards, 1)) - 6)
	for index, amount in rewards do
		create("Frame", {
			LayoutOrder = index,
			Size = UDim2.fromOffset(tileWidth, 60),
			BackgroundColor3 = if index == highlight then COLORS.accent else COLORS.surface,
			Parent = dayStrip,
		}, {
			corner(8) :: Instance,
			label({ Size = UDim2.new(1, 0, 0, 22), TextSize = 13, TextColor3 = COLORS.muted, Text = `Day {index}` }),
			label({
				Position = UDim2.fromOffset(0, 24),
				Size = UDim2.new(1, 0, 0, 30),
				TextSize = 16,
				Font = Enum.Font.BuilderSansBold,
				TextColor3 = COLORS.gold,
				Text = formatNumber(amount),
			}),
		})
	end

	claimButton.Active = daily.CanClaim
	claimButton.AutoButtonColor = daily.CanClaim
	claimButton.BackgroundColor3 = if daily.CanClaim then COLORS.good else COLORS.surface
	dailyBadge.Visible = daily.CanClaim
end

local function getProductInfo(id: number, infoType: Enum.InfoType): { [string]: any }?
	local key = `{infoType.Name}:{id}`
	if productInfoCache[key] then
		return productInfoCache[key]
	end
	local ok, info = pcall(function()
		return MarketplaceService:GetProductInfoAsync(id, infoType)
	end)
	if ok and type(info) == "table" then
		productInfoCache[key] = info
		return info
	end
	return nil
end

local function shopRow(order: number, title: string, priceText: string, enabled: boolean, onClick: () -> ()): Frame
	local row = create("Frame", {
		LayoutOrder = order,
		Size = UDim2.new(1, -8, 0, 52),
		BackgroundColor3 = COLORS.surface,
	}, { corner(10) })
	label({
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -130, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.BuilderSansBold,
		Text = title,
		Parent = row,
	})
	local buy = button(priceText, if enabled then COLORS.good else COLORS.panel, {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(104, 38),
		Active = enabled,
		AutoButtonColor = enabled,
		Parent = row,
	})
	if enabled then
		buy.Activated:Connect(onClick)
	end
	row.Parent = shopList
	return row
end

local function renderShop()
	local current = state
	if current == nil then
		return
	end
	-- Only rebuild when the product list or pass ownership changes.
	local parts = {}
	for _, product in current.Products do
		table.insert(parts, `p{product.Id}`)
	end
	for _, pass in current.Passes do
		table.insert(parts, `g{pass.Id}{if pass.Owned then "o" else ""}`)
	end
	local signature = table.concat(parts, ",")
	if signature == shopSignature then
		return
	end
	shopSignature = signature
	shopGeneration += 1
	local generation = shopGeneration

	for _, child in shopList:GetChildren() do
		if child:IsA("Frame") or child:IsA("TextLabel") then
			child:Destroy()
		end
	end

	if #current.Products == 0 and #current.Passes == 0 then
		label({ Size = UDim2.new(1, -8, 0, 60), TextColor3 = COLORS.muted, Text = "Nothing for sale yet.", Parent = shopList })
		return
	end

	local order = 0
	for _, pass in current.Passes do
		order += 1
		local rowOrder = order
		task.spawn(function()
			local info = getProductInfo(pass.Id, Enum.InfoType.GamePass)
			if generation ~= shopGeneration then
				return
			end
			local name = if info and info.Name then info.Name else (pass.Name or "Game Pass")
			local price = if info and info.PriceInRobux then `R$ {info.PriceInRobux}` else "Buy"
			shopRow(rowOrder, `⭐ {name}`, if pass.Owned then "Owned" else price, not pass.Owned, function()
				MarketplaceService:PromptGamePassPurchase(player, pass.Id)
			end)
		end)
	end
	for _, product in current.Products do
		order += 1
		local rowOrder = order
		task.spawn(function()
			local info = getProductInfo(product.Id, Enum.InfoType.Product)
			if generation ~= shopGeneration then
				return
			end
			local name = if info and info.Name
				then info.Name
				elseif product.Coins then `{formatNumber(product.Coins)} {current.CurrencyName}`
				else "Item"
			local price = if info and info.PriceInRobux then `R$ {info.PriceInRobux}` else "Buy"
			shopRow(rowOrder, name, price, true, function()
				MarketplaceService:PromptProductPurchase(player, product.Id)
			end)
		end)
	end
end

local function applyState(newState: { [string]: any }?)
	if newState == nil then
		return
	end
	state = newState
	coinLabel.Text = `💰 {formatNumber(newState.Coins)}`
	dailyButton.Visible = newState.DailyEnabled
	codesButton.Visible = newState.CodesEnabled
	shopButton.Visible = #newState.Products > 0 or #newState.Passes > 0
	nextDailyAt = os.clock() + newState.Daily.SecondsUntilNext
	renderDaily()
	renderShop()
end

local function refresh()
	local ok, result = pcall(function()
		return getStateRemote:InvokeServer()
	end)
	if ok and type(result) == "table" then
		applyState(result :: { [string]: any })
	end
end

--------------------------------------------------------------------------------
-- Interaction
--------------------------------------------------------------------------------

local pages: { [string]: Frame } = { Daily = dailyPage, Codes = codesPage, Shop = shopPage }
local titles: { [string]: string } = { Daily = "Daily Reward", Codes = "Codes", Shop = "Shop" }
local openPage: string? = nil

local function open(name: string?)
	openPage = name
	panel.Visible = name ~= nil
	for pageName, frame in pages do
		frame.Visible = pageName == name
	end
	if name then
		titleLabel.Text = titles[name]
	end
end

local function toggle(name: string)
	open(if openPage == name then nil else name)
end

dailyButton.Activated:Connect(function()
	toggle("Daily")
end)
codesButton.Activated:Connect(function()
	toggle("Codes")
end)
shopButton.Activated:Connect(function()
	toggle("Shop")
end)
closeButton.Activated:Connect(function()
	open(nil)
end)

local busy = false
local function callRemote(remote: RemoteFunction, ...: any): { [string]: any }?
	if busy then
		return nil
	end
	busy = true
	local args = table.pack(...)
	local ok, result = pcall(function()
		return remote:InvokeServer(table.unpack(args, 1, args.n))
	end)
	busy = false
	if not ok or type(result) ~= "table" then
		showToast("Couldn't reach the server. Try again.", false)
		return nil
	end
	return result
end

claimButton.Activated:Connect(function()
	local current = state
	if current == nil or not current.Daily.CanClaim then
		return
	end
	local result = callRemote(claimDailyRemote)
	if result then
		showToast(result.Message, result.Ok)
		applyState(result.State)
	end
end)

local function redeem()
	local result = callRemote(redeemCodeRemote, codeBox.Text)
	if result then
		codeResult.Text = result.Message
		codeResult.TextColor3 = if result.Ok then COLORS.good else COLORS.bad
		if result.Ok then
			codeBox.Text = ""
			showToast(result.Message, true)
			applyState(result.State)
		end
	end
end
redeemButton.Activated:Connect(redeem)
codeBox.FocusLost:Connect(function(enterPressed: boolean)
	if enterPressed then
		redeem()
	end
end)

stateChangedRemote.OnClientEvent:Connect(applyState)

screen.Parent = player:WaitForChild("PlayerGui")

-- Countdown until the next daily reward.
task.spawn(function()
	while true do
		task.wait(1)
		local current = state
		if current and current.DailyEnabled and not current.Daily.CanClaim then
			local remaining = nextDailyAt - os.clock()
			if remaining <= 0 then
				refresh()
			else
				claimButton.Text = `Next reward in {formatDuration(remaining)}`
			end
		elseif current then
			claimButton.Text = "Claim"
		end
	end
end)

-- The server pushes state once data has loaded; also ask directly in case we missed it.
refresh()
task.delay(3, function()
	if state == nil then
		refresh()
	end
end)
