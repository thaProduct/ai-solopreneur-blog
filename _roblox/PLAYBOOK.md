# Roblox-Geld-Plan: Werkzeug verkaufen + Einbau als Auftrag

**Das Modell:** Du verkaufst an Roblox-Entwickler (die haben Budget) statt auf einen eigenen Hit zu hoffen.
Ein Produkt, zwei Einnahmequellen, beide in **echtem Geld (USD)**, ohne DevEx und ohne 30.000-Robux-Hürde.

| | Produkt im Creator Store | Einbau als Auftrag |
|---|---|---|
| Was | `MonetizationKit.rbxm` (fertig, in diesem Ordner) | Du baust das Kit in fremde Spiele ein und passt es an |
| Preis | 9,99 $ (für Models sind 2,99–49,99 $ erlaubt) | 59 / 129 / 249 $ pro Paket |
| Du erhältst | 100 % netto (nur Steuern und Stripe-Gebühren gehen ab) | 100 % per PayPal |
| Auszahlung | monatlich am 1., nach 30 Tagen Sperrfrist | sofort |
| Aufwand | einmalig | ca. 1–3 Std. pro Auftrag (mit Claude) |

---

## Tag 1: Konten vorbereiten (ca. 1 Std.)

- [ ] **Roblox-Konto verifizieren:** Alterscheck oder Ausweis-Verifizierung (Einstellungen → Konto-Info). Eine Handynummer reicht nicht.
- [ ] **2-Schritt-Verifizierung** aktivieren (Pflicht für Verkäufer).
- [ ] **Als Verkäufer anmelden:** Creator Hub → Settings → Eligibility → *Priced assets* → Stripe-Formular ausfüllen (Bankkonto, W-8BEN mit deiner Steuer-ID). Deutschland wird unterstützt.
- [ ] **PayPal-Geschäftskonto** für Aufträge (Zahlungsart „Waren & Dienstleistungen“, damit du geschützt bist).
- [ ] **Gewerbe anmelden**, bevor das erste Geld kommt (online, meist 20–60 €). Die Kleinunternehmerregelung lohnt sich meist. Die Details klärst du mit deinem Steuerberater.

## Tag 2: Kit testen (ca. 30 Min.)

1. **Roblox Studio** installieren und ein neues Spiel mit Vorlage *Baseplate* öffnen.
2. `monetization-kit/build/MonetizationKit.rbxm` in das Studio-Fenster ziehen und den Ordner nach **ServerScriptService** verschieben.
3. Das Spiel einmal veröffentlichen, dann *Game Settings → Security → Studio Access to API Services* einschalten.
4. **Play** drücken und diese Punkte prüfen:
   - [ ] Links erscheinen die Buttons *Daily*, *Codes* und *Shop*.
   - [ ] Die tägliche Belohnung lässt sich abholen, danach läuft der Countdown.
   - [ ] Der Code `WELCOME` gibt +100, ein zweiter Versuch wird abgelehnt.
   - [ ] Nach Stop und erneutem Play sind die Coins noch da (Speichern funktioniert).
   - [ ] Im Creator Hub ein Developer Product anlegen (z. B. „500 Coins“ für 25 Robux), die ID in `Config` eintragen und im Shop kaufen. In Studio ist das ein kostenloser Testkauf.
5. **Screenshots** der drei Panels machen und ein **Video von ca. 30 Sek.** aufnehmen (Daily, Code einlösen, Kauf). Das ist dein Verkaufsmaterial und zugleich dein Portfolio.

## Tag 3: Im Creator Store veröffentlichen

1. In Studio im Explorer: Rechtsklick auf den Ordner `MonetizationKit` → **Save / Export → Save to Roblox...** → *Content Type* **Development Item**, *Asset Category* **Model** → **Save**.
2. Den angezeigten Link zum Creator Hub öffnen. Dort Name und Beschreibung aus dem Abschnitt „Listing-Text“ unten einfügen.
3. Screenshots und Video hinzufügen (maximal 5 Bilder und 1 Video, nur für verifizierte Konten).
4. Unter *Distribution* **Distribute on Creator Store** einschalten, unter **USD Pricing** 9,99 $ eintragen → **Save Changes**.

## Ab Woche 1: Aufträge holen (bringt das erste Geld)

**Wo die Kunden sind:**
1. **HiddenDevs** (Discord, größte Auftragsbörse für Roblox, Budget im Schnitt ca. 134 $): Dort als *Scripter* ein Portfolio einreichen. Das Kit samt Video ist dein Nachweis.
2. **Roblox Talent Hub** (im Creator Hub): einen Portfolio-Beitrag und einen „For Hire“-Beitrag anlegen.
3. **Täglich 15 Minuten** Stellengesuche durchsehen. Suchbegriffe: `gamepass`, `dev product`, `datastore`, `daily rewards`, `codes`, `monetization`, `shop`.

**Pakete (Preise öffentlich sichtbar angeben, nicht „DM for price“):**

| Paket | Inhalt | Preis | Lieferung |
|---|---|---|---|
| Basic | Kit einbauen, bis zu 5 Produkte oder Pässe einrichten, Test | 59 $ | 48 h |
| Standard | + an Währung und UI des Spiels angepasst, eigene Vorteile (VIP-Tür, Tools, Boosts) | 129 $ | 3 Tage |
| Pro | + Shop-UI im Stil des Spiels, zusätzliche Produkte (Revives, Skips), Einrichtung der Economy-Analytics | 249 $ | 5 Tage |

**Zahlung:** 50 % im Voraus per PayPal, den Rest bei Lieferung. USD bevorzugen.

**Ablauf pro Auftrag (mit Claude):**
Wünsche des Kunden und `Config.luau` in eine Claude-Session geben → Claude schreibt die `Grant`-Funktionen, Vorteile und UI-Anpassungen → in Studio testen → dem Kunden eine `.rbxm`-Datei und ein kurzes Video liefern.

### Nachrichten-Vorlagen (Englisch, der Markt ist englischsprachig)

**Antwort auf ein Stellengesuch:**
> Hi! I build monetization systems for Roblox games: dev products with safe receipt handling (no lost or double purchases), game passes, daily rewards, promo codes and session-locked data saving.
> Here's a 30-second demo: [VIDEO-LINK]
> For your game I'd [KONKRET: z. B. "set up your 4 coin packs + 2x Coins pass and match the shop to your UI"]. Fixed price $[PREIS], delivered in [X] days.
> Happy to do a quick call or answer questions first.

**Beitrag „For Hire“ (Talent Hub und HiddenDevs):**
> **Monetization Setup for your Roblox game: fixed prices, fast delivery**
> Dev products (idempotent receipts), game passes, daily login streaks, promo codes, auto-saving data with session locking, economy analytics and a clean mobile UI.
> Basic $59 · Standard $129 · Pro $249. Demo: [VIDEO-LINK]. Payment: PayPal (50% upfront).

## Listing-Text für den Creator Store (Englisch)

**Titel:** `Monetization Kit: Dev Products, Game Passes, Daily Rewards, Codes, Auto-Save`

**Beschreibung:**
> Make money from your game in 5 minutes. Drop this folder into ServerScriptService, paste your product IDs and press Play.
>
> ✅ Dev products that can't be lost or granted twice (receipts are closed only after data is saved)
> ✅ Game passes with stacking coin multipliers and custom perks, granted instantly after purchase
> ✅ Daily rewards with login streaks and a countdown
> ✅ Promo codes: case-insensitive, expiry dates, one use per player, never sent to clients
> ✅ Auto-saving player data with session locking (no duplication when players switch servers)
> ✅ Economy analytics in Creator Hub out of the box
> ✅ Clean, mobile-friendly UI (or use your own via remotes)
> ✅ Simple API: AddCoins, SpendCoins, OwnsPass, GetData
>
> Fully typed (--!strict), 64 unit tests for the core logic, one config file.

## Nächste Produkte (gleiches Muster, jeweils 9,99–19,99 $)

1. Rebirth- und Upgrade-System (Simulatoren sind das größte Genre)
2. Globale Bestenliste (OrderedDataStore, Top 100, mit Anzeigetafel)
3. Quests und Erfolge (täglich, wöchentlich, mit Belohnungen)
4. Sicheres Handelssystem zwischen Spielern
5. Danach ein Bundle „Simulator Starter Pack“ aus allen Kits für 39,99 $

Jedes neue Kit ist zugleich ein neues Auftragspaket. Wiederkehrende Kundenwünsche werden zum nächsten Produkt.

## Ziel Monat 1

- 3–5 Einbau-Aufträge = **ca. 200–600 $**
- Kit im Store live, erste Verkäufe und Bewertungen
- Nächstes Kit (Rebirth-System) aus den häufigsten Kundenwünschen bauen
