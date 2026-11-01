# Strategie & Bewertung (Stand: 1. November 2026)

> Diese Datei liegt im öffentlichen Repo, wird aber nicht auf der Website
> veröffentlicht (`exclude` in `_config.yml`).

## 1. Ehrlicher Ist-Stand

| Kennzahl | Wert | Quelle |
|---|---|---|
| Produkt | n8n-YouTube-Pipeline, 15 €, DE+EN, ZIP über Google Drive | Stripe-Zahlungslink `plink_1UWLqd…` |
| Verkäufe | **0** | Stripe, Checkout-Sessions (live) |
| Checkout-Aufrufe dieses Links | **0** | Stripe, kein einziger Checkout zu diesem Link |
| Website | live, 3 Artikel + Verkaufsseite DE/EN | GitHub Pages, HTTP 200 |
| Sitemap / Canonical-URLs | **fehlten** (`url: ""`, kein Sitemap-Plugin) | eigene Prüfung |
| Einnahmen / Ausgaben / Gewinn | 0 € / 0 € / 0 € | – |

**Diagnose:** Das Produkt ist nicht das Problem, sondern die **Reichweite**.
Niemand hat die Kaufseite bis zum Checkout geklickt, weil (fast) niemand sie
gesehen hat. Google konnte die Seite schlecht indexieren, und es gab keinen
einzigen Vertriebskanal (Marktplatz, Community, Social).

## 2. Marktrecherche: Kernaussagen

- **Vergleichbare Produkte:** Auf Gumroad und Neura Market kosten
  n8n-Vorlagen für faceless Videos mit ElevenLabs meist 25–30 $. Daneben gibt
  es viele Gratis-Varianten. **15 € liegt am unteren Ende, mit Spielraum nach
  oben.**
- **Marktplatz-Realität:** Laut einer Auswertung von 146.271
  Gumroad-Produkten hat 44 % davon nie einen Cent umgesetzt. Ein Listing
  allein bringt also keine Käufer. Was zählt, ist die Verteilung.
- **n8n Creator Hub (n8n.io/workflows):** Das ist der stärkste kostenlose
  Kanal, denn die Vorlagen ranken bei Google und werden in der n8n-App
  angezeigt. Laut Berichten aus der Community muss man vor dem ersten
  Bezahl-Template **3 kostenlose Templates** veröffentlichen, und zu simple
  Einreichungen werden abgelehnt. (Das ist nicht offiziell bestätigt. Die
  Doku sagt nur, das Programm sei „in Arbeit“.)
- **Micro-SaaS:** Laut einer Auswertung liegt der Median bei 145 $ MRR, und
  rund 70 % kommen nie über 1.000 $ MRR. KI-Tools machen etwa 49 % aller neuen
  Micro-SaaS aus, der Markt ist also gesättigt. Der Engpass ist Vertrieb,
  nicht Code.

Quellen: [n8n Docs – Templates](https://docs.n8n.io/workflows/templates/),
[n8n Community – Wo n8n-Workflows verkaufen?](https://community.n8n.io/t/where-can-i-sell-my-n8n-workflow-i-am-looking-for-marketplaces-not-the-creator-hub/212963),
[Neura Market – faceless YouTube Workflow](https://www.neura.market/workflow/an-ai-agent-to-create-faceless-youtube-videos),
[Gumroad-Beispiel 1](https://pandalicious633.gumroad.com/l/dbjpanda),
[Gumroad-Beispiel 2](https://virginai.gumroad.com/l/facelessn8n),
[InsightRaider – Notion-Templates profitabel?](https://insightraider.com/en/answers/is-selling-notion-templates-profitable),
[Preuve – Micro-SaaS 2026](https://preuve.ai/blog/are-micro-saas-ideas-still-profitable-2026),
[Shno – Micro-SaaS-Statistiken](https://www.shno.co/marketing-statistics/micro-saas-launch-statistics).

## 3. Bewertung von 21 Geschäftsmodellen

Gewichtung: Automatisierbarkeit 20 %, Zeit bis zum ersten Umsatz 15 %,
Nachfrage 15 %, Startkosten 10 %, Marge 10 %, Skalierbarkeit 10 %,
Wettbewerbsposition 10 %, Wartung 10 %. Skala 1–10 (10 = am besten,
z. B. 10 bei Startkosten = kostet nichts).

| # | Geschäftsmodell | Auto | Zeit | Nachfr. | Kosten | Marge | Skal. | Wettb. | Wartung | **Score** | Startkapital | lfd. Kosten/Monat | MVP | Erster Kunde | Erlösmodell |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | n8n-/KI-Workflow-Vorlagen (Ausbau des bestehenden Produkts) | 9 | 8 | 7 | 10 | 10 | 8 | 6 | 8 | **8.25** | 0 € | 0–5 € | fertig | 1–4 Wochen | Einmalkauf 15–49 € |
| 2 | Notion-/Sheets-Vorlagen | 9 | 7 | 6 | 10 | 10 | 7 | 3 | 9 | **7.65** | 0 € | 0 € | Tage | 2–8 Wochen | Einmalkauf 9–39 € |
| 3 | Prompt-/KI-Toolkits auf Gumroad/Etsy | 9 | 7 | 5 | 10 | 10 | 7 | 3 | 9 | **7.50** | 0 € | 0 € | Tage | 2–8 Wochen | Einmalkauf 5–20 € |
| 4 | Programmatische SEO-Seite mit Rechnern + Affiliate | 9 | 3 | 7 | 9 | 9 | 9 | 5 | 7 | **7.20** | 0–15 € | 0–10 € | 1–2 Wochen | 3–6 Monate | Affiliate, Werbung |
| 5 | Nischen-Micro-SaaS (z. B. KI-Antworten auf Google-Bewertungen) | 8 | 5 | 7 | 7 | 9 | 9 | 5 | 6 | **7.00** | 0–50 € | 20–60 € | 2–4 Wochen | 1–3 Monate | Abo 19–49 €/Monat |
| 6 | Chrome-Erweiterung mit Premium | 8 | 5 | 6 | 9 | 9 | 8 | 5 | 6 | **6.95** | 5 € Gebühr | 0–20 € | 1–3 Wochen | 1–3 Monate | Freemium/Abo |
| 7 | SEO-Affiliate-Blog (Software, wiederkehrende Provision) | 8 | 3 | 7 | 10 | 9 | 8 | 4 | 7 | **6.90** | 0 € | 0 € | läuft | 3–9 Monate | Affiliate 20–40 % wiederkehrend |
| 8 | MCP-Server/Claude-Skills für Nischen (neu) | 8 | 5 | 4 | 9 | 9 | 7 | 7 | 6 | **6.75** | 0 € | 0–10 € | 1–2 Wochen | 1–3 Monate | Lizenz/Abo |
| 9 | Nischen-Jobbörse / Verzeichnis | 8 | 4 | 6 | 9 | 8 | 7 | 5 | 6 | **6.60** | 0–15 € | 0–20 € | 1–2 Wochen | 2–4 Monate | Listings 49–199 € |
| 10 | Daten-/Recherche-Produkte (öffentliche Daten) | 8 | 4 | 5 | 9 | 9 | 7 | 5 | 6 | **6.55** | 0 € | 0–20 € | 1–2 Wochen | 2–4 Monate | Abo/Einmal |
| 11 | Amazon KDP (Low-/No-Content-Bücher) | 8 | 5 | 5 | 10 | 6 | 6 | 2 | 9 | **6.40** | 0 € | 0 € | Tage | 1–3 Monate | Tantiemen |
| 12 | KI-Automatisierungsagentur (produktisiert) | 5 | 7 | 8 | 10 | 7 | 4 | 6 | 4 | **6.35** | 0 € | 0–30 € | 1 Woche | 2–6 Wochen | Projekt/Retainer |
| 13 | WordPress-Plugin (Freemium) | 7 | 4 | 5 | 9 | 9 | 8 | 4 | 5 | **6.25** | 0 € | 0–10 € | 2–4 Wochen | 2–4 Monate | Pro-Lizenz |
| 14 | Newsletter (Nische) | 7 | 3 | 6 | 10 | 8 | 7 | 4 | 5 | **6.15** | 0 € | 0–30 € | Tage | 3–6 Monate | Sponsoring, Paid-Abo |
| 15 | Print-on-Demand (Etsy/Merch) | 7 | 5 | 6 | 8 | 5 | 7 | 2 | 7 | **5.95** | 0–20 € | 0–15 € | Tage | 1–3 Monate | Marge pro Stück |
| 16 | Faceless-YouTube-Kanal | 7 | 2 | 7 | 9 | 7 | 8 | 3 | 5 | **5.95** | 0 € | 10–40 € | 1 Woche | 6–12 Monate (Partnerprogramm) | Werbung, Affiliate |
| 17 | Kauf & Automatisierung kleiner Websites | 6 | 6 | 6 | 2 | 7 | 6 | 6 | 6 | **5.70** | 500–5000 € | 10–30 € | — | sofort (Bestand) | Bestehende Umsätze |
| 18 | KI-Telefonassistent für lokale Betriebe | 6 | 4 | 7 | 7 | 6 | 6 | 4 | 4 | **5.55** | 0–50 € | 30–150 € | 2–4 Wochen | 1–3 Monate | Abo 49–199 € |
| 19 | Browser-/Indie-Spiel | 6 | 3 | 5 | 9 | 8 | 7 | 2 | 5 | **5.50** | 0 € | 0 € | 4–8 Wochen | 3–6 Monate | Ads, IAP |
| 20 | Roblox-Spiel | 5 | 3 | 6 | 10 | 6 | 8 | 2 | 4 | **5.35** | 0 € | 0 € | 4–8 Wochen | 3–6 Monate | Robux (DevEx ab 30k) |
| 21 | Shopify-Dropshipping | 5 | 4 | 6 | 5 | 3 | 7 | 2 | 4 | **4.60** | 30–300 € | 30–100 € | 1 Woche | 1–2 Monate | Marge minus Ads |

**Hinweise zur Bewertung:** Die Werte sind konservative Schätzungen und keine
Messungen. Die Plätze 1–3 profitieren vom vorhandenen Bestand: Der Shop, der
Blog, das Stripe-Konto und das Impressum existieren schon. Bei Roblox, Spielen
und YouTube scheitert die Automatisierung nicht am Bauen, sondern an der
Monetarisierungsschwelle. Ein Beispiel ist die Robux-Auszahlung, die erst ab
30.000 Robux möglich ist. Bei YouTube muss erst das Partnerprogramm erreicht
werden. Dropshipping braucht Werbebudget und hat Retouren-Risiko.

## 4. Die drei stärksten Optionen

1. **Portfolio an n8n-/KI-Workflow-Vorlagen** (8,25). Das Produkt
   existiert schon, die Grenzkosten liegen bei 0 €, und ich kann 95 % der
   Arbeit selbst machen (Workflows bauen, Doku, Listings, SEO-Artikel). Die
   Plätze 2 und 3 (Notion-/Prompt-Vorlagen) sind dasselbe Modell mit
   schwächerem Wettbewerb. Sie werden daher Teil dieses Portfolios und keine
   separaten Projekte.
2. **Programmatische SEO-Seite mit Rechnern und Affiliate-Links** (7,20).
   Sie lässt sich gut automatisieren, ist aber langsam: Bis Google
   Vertrauen aufbaut, vergehen 3–6 Monate. Sie eignet sich als zweiter
   Vermögenswert.
3. **Nischen-Micro-SaaS mit Abo** (7,00), z. B. KI-Antworten auf
   Google-Bewertungen für lokale Betriebe. Ein Versuch dazu existiert schon:
   eine Stripe-Abo-Session „S.M-Automations“ über 49 €, Status „Test“. Das
   Modell ist wiederkehrend und hochwertig, braucht aber Kundenakquise und
   Support.

## 5. Entscheidung

**Hauptprojekt: Option 1, das Vorlagen-Portfolio, mit Fokus auf Vertrieb.**
Begründung: Die Option hat den kürzesten Weg zum ersten Euro, null
Kapitalbedarf, und das Produkt ist schon fertig. Das einzige fehlende Stück
ist die Reichweite, und genau das wird jetzt gebaut:

| Hebel | Status |
|---|---|
| SEO-Grundlagen: `url`, Sitemap, Canonical, robots.txt, `jekyll-seo-tag` | ✅ erledigt |
| Kostenlose Lite-Vorlage als Lead-Magnet auf der eigenen Seite (DE+EN) | ✅ erledigt |
| Lite-Vorlage für n8n.io Creator Hub (Kanal mit eigener Google-Reichweite) | ✅ vorbereitet, Einreichung braucht deinen Account |
| Marktplatz-Listings Gumroad / Payhip / Neura Market | ✅ Texte fertig (`02-launch-paket.md`) |
| Community-Posts (n8n-Forum, Reddit, LinkedIn) | ✅ Texte fertig, Posten braucht deinen Account |
| Startseite mit klarem Weg Gratis → Bezahlt | ✅ erledigt |

**Abbruchkriterium:** Wenn es 60 Tage nach Einreichung bei n8n.io und den
Community-Posts weniger als 1 Verkauf gibt, liegt das Problem beim Produkt
oder bei der Nische, nicht mehr beim Vertrieb. Dann folgt der Wechsel zu
Option 3 (Abo) oder eine andere Vorlagen-Nische.

## 6. Kosten-Tracking

| Posten | Betrag | Status |
|---|---|---|
| GitHub Pages Hosting | 0 € | aktiv |
| Stripe | 1,5 % + 0,25 € pro EU-Kartenzahlung, sonst 0 € | aktiv |
| Google Drive (Auslieferung) | 0 € | aktiv |
| **Summe fixe Kosten** | **0 €/Monat** | |

Bei 15 € Preis bleiben nach Stripe-Gebühr ca. **14,53 € netto pro
Verkauf**, vor Steuern. Steuerliche Behandlung (Kleinunternehmerregelung
§ 19 UStG, EU-OSS bei Verkäufen ins EU-Ausland) ist eine Entscheidung für
dich bzw. deine Steuerberatung.
