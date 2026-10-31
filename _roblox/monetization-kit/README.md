# MonetizationKit for Roblox

A drop-in folder that turns a Roblox game into one that earns money. It handles purchases safely, saves player data and includes a UI.

| Feature | Details |
|---|---|
| Developer products | Idempotent receipt handling via `BindReceiptHandler` (falls back to `ProcessReceipt`). Each receipt is granted exactly once and closed only after the grant is saved. |
| Game passes | Checked on join and granted right after purchase. Coin multipliers stack. Custom `OnOwned` perks are supported. |
| Daily rewards | Login streak based on UTC days, a configurable reward cycle and a live countdown. |
| Promo codes | Case-insensitive, with optional `YYYY-MM-DD` expiry. Each player can redeem a code once. Attempts are rate limited and codes stay on the server. |
| Player data | Session-locked `UpdateAsync` saves, autosave and `BindToClose`. Kicks the player instead of overwriting data when loading fails. |
| Analytics | Every coin source and sink is logged with `AnalyticsService:LogEconomyEvent`. |
| UI | Mobile-friendly Daily, Codes and Shop panels. Set `UseBuiltInUI = false` to use your own. |

## Install

1. Drag `MonetizationKit.rbxm` into Studio and move the `MonetizationKit` folder to **ServerScriptService**.
2. Edit `Config`: add your developer product and game pass IDs, daily rewards and promo codes.
3. Enable **Game Settings → Security → Studio Access to API Services** to test saving in Studio.
4. Press Play. Redeem `WELCOME`, then claim the daily reward.

## Server API

```lua
local MonetizationKit = require(game:GetService("ServerScriptService").MonetizationKit.API)

MonetizationKit.AddCoins(player, 10, true)          -- true = apply game pass multipliers
MonetizationKit.SpendCoins(player, 250, "SpeedCoil") -- false if not enough coins
MonetizationKit.GetCoins(player)
MonetizationKit.OwnsPass(player, gamePassId)
MonetizationKit.GetCoinMultiplier(player)
MonetizationKit.OnChanged(function(player) end)

local data = MonetizationKit.WaitForData(player)    -- data.Custom is saved automatically
```

## Remotes (for a custom UI)

`ReplicatedStorage.MonetizationKitRemotes` contains:

- `GetState` (RemoteFunction) returns the coins, the daily status, products and passes.
- `ClaimDaily` (RemoteFunction) returns `{ Ok, Message, State }`.
- `RedeemCode(code)` (RemoteFunction) returns `{ Ok, Message, State }`.
- `StateChanged` (RemoteEvent) is pushed whenever something changes.

## Development

Source is written for [Rojo](https://rojo.space) (`emitLegacyScripts: false`).

```
rojo build default.project.json -o build/MonetizationKit.rbxm   # build the model
luau tests/run.luau                                              # 64 unit tests for the core logic
```

The core logic (receipts, streaks, codes, dates, rate limiting) is in `src/Modules/Logic.luau`. It has no engine dependencies and is unit tested. The whole project type-checks in `--!strict` against the Roblox API definitions.
