MONETIZATION KIT - QUICK START

1. Put this whole "MonetizationKit" folder into ServerScriptService.
2. Open "Config" and paste your Developer Product and Game Pass IDs
   (Creator Hub > your game > Monetization).
3. Game Settings > Security > enable "Studio Access to API Services"
   so data saves while testing in Studio.
4. Press Play. Try the code WELCOME and claim your daily reward.

WHAT YOU GET
- Safe developer product purchases: every receipt is granted exactly once,
  even if a server crashes or the player leaves mid-purchase.
- Game passes with coin multipliers and custom perks, applied instantly after purchase.
- Daily rewards with login streaks and a countdown.
- Promo codes (case-insensitive, optional expiry date, one use per player, rate limited,
  never sent to clients).
- Auto-saving player data with session locking (no duplication when players switch servers).
- Economy analytics (Creator Hub > Analytics > Economy) out of the box.
- A clean, mobile-friendly UI (Daily / Codes / Shop) - or turn it off and use your own.

USE IT FROM YOUR SCRIPTS (server)
local MonetizationKit = require(game:GetService("ServerScriptService").MonetizationKit.API)
MonetizationKit.AddCoins(player, 10, true)        -- true = apply game pass multipliers
MonetizationKit.SpendCoins(player, 250, "SpeedCoil")
MonetizationKit.OwnsPass(player, 123456789)
MonetizationKit.GetCoins(player)
local data = MonetizationKit.WaitForData(player)  -- data.Custom is yours, saved automatically

Only one script in your game may handle developer products for the same product ID.
The kit only handles the product IDs listed in Config, so your other products keep working.
