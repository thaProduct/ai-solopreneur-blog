# Launch-Paket: Alles fertig zum Einfügen

Alle Texte sind auf Englisch, weil das n8n-Publikum überwiegend englisch
ist. Deine Aufgaben stehen gesammelt in **Abschnitt 0**.

---

## 0. Was nur du tun kannst (ca. 45 Minuten insgesamt)

| # | Aktion | Warum ich das nicht kann | Zeit |
|---|---|---|---|
| 1 | **PR mergen**, damit Sitemap, SEO-Tags und Gratis-Seite live gehen | Freigabe des Merges liegt bei dir | 1 min |
| 2 | **Google Search Console:** Property `https://thaproduct.github.io/ai-solopreneur-blog/` hinzufügen (Verifizierung per HTML-Tag, den Tag schickst du mir, ich baue ihn ein), dann Sitemap `…/sitemap.xml` einreichen | braucht deinen Google-Login | 10 min |
| 3 | **n8n Creator Hub:** Auf n8n.io als Creator registrieren und `freebies/youtube-script-generator-lite.json` mit Text aus Abschnitt 1 einreichen. Vorher einmal in deinem n8n (thaproduct.app.n8n.cloud) importieren und testen | braucht deinen n8n-Account | 15 min |
| 4 | **Gumroad** (optional, zweiter Kanal): Produkt anlegen, ZIP hochladen, Text aus Abschnitt 2 einfügen | Account und Auszahlungsdaten | 10 min |
| 5 | **Posts absetzen**: n8n-Forum (Abschnitt 3), Reddit r/n8n (Abschnitt 4), LinkedIn (Abschnitt 5) | Posten unter deinem Namen | 10 min |

Danach: Sag mir Bescheid. Dann prüfe ich die Stripe-Verkäufe, baue das
nächste Gratis-Template (n8n Creator Hub will 3, bevor man verkaufen darf)
und erweitere das Portfolio.

---

## 1. n8n Creator Hub: Einreichung der Lite-Vorlage

**Title:** Generate structured YouTube scripts with Claude from a simple form

**Description:**

> ## Who is this for
> Faceless YouTube creators, content marketers and agencies who want a
> structured first draft of a video script in under a minute.
>
> ## What it does
> 1. A **Form Trigger** asks for topic, video length and language.
> 2. A **Code** node builds the prompt and calculates the target word count
>    (~150 spoken words per minute).
> 3. An **HTTP Request** calls the Anthropic Messages API (Claude).
> 4. The script (Hook, Setup, Facts, Theories, Ending + 5 title ideas) is
>    shown directly on the form's completion page, with word count and
>    estimated runtime.
>
> ## How to set up
> 1. Create a **Header Auth** credential: name `x-api-key`, value = your
>    Anthropic API key.
> 2. Select it in the node *Claude: write script*.
> 3. Activate the workflow and open the form URL.
>
> ## How to customize
> - Change the model or `max_tokens` in *Build prompt*.
> - Edit the section structure in the system prompt (same node).
> - Add languages in the form's dropdown.
>
> ## Want more?
> The full pipeline (Google Sheets topic queue, Telegram approval,
> ElevenLabs voice-over per section, MP3s saved to Google Drive) is linked
> in the sticky note.

**Categories:** AI, Content Creation, Marketing

---

## 2. Gumroad / Payhip / Neura Market: Produkt-Listing

**Name:** n8n YouTube Pipeline: Claude Script → Telegram Approval → ElevenLabs Voice-Over

**Price:** €15 (Gumroad: "15+" pay-what-you-want with minimum 15)

**Summary (one line):** Two ready-to-import n8n workflows that turn a
Google Sheets topic list into approved scripts and finished per-section
voice-overs in Google Drive.

**Description:**

> **From topic list to finished voice-over, without copy-pasting between five tabs.**
>
> **Workflow 1: Script Generator**
> Picks the next open topic from Google Sheets, has Claude write a fully
> structured script (hook, setup, facts, three theories, ending), adds 5
> title ideas plus a thumbnail idea, and pings you on Telegram.
>
> **Workflow 2: Approval & Voice**
> Read the script, send `/approve 5` to your bot, and ElevenLabs generates
> one MP3 per section, cleanly named in your Google Drive folder.
> No credits are spent until *you* approve, and only your own Telegram chat
> ID can trigger it.
>
> **Included**
> - 2 n8n workflows (JSON), English and German versions
> - Google Sheet topic template
> - Step-by-step setup guide (15–20 minutes), English + German
> - Customization guide: language, length, structure, voice, schedule
>
> **You need:** n8n (self-hosted or Cloud), Anthropic API key, ElevenLabs
> API access, Google account, Telegram.
>
> **License:** Use and modify for your own and client projects. No resale.
>
> Not sure yet? Try the free Lite version first:
> https://thaproduct.github.io/ai-solopreneur-blog/en/free-youtube-script-generator/

**Tags:** n8n, youtube automation, faceless youtube, elevenlabs, claude, ai automation, workflow template

---

## 3. n8n Community Forum (Kategorie „Built with n8n“)

**Title:** Free workflow: Form → Claude → structured YouTube script (+ the approval/voice pipeline I built around it)

> Hi all, sharing a small workflow I use for a faceless YouTube channel.
>
> **What it does:** a Form Trigger asks for topic, length and language, a
> Code node calculates the target word count (~150 words/minute), an HTTP
> Request calls Claude, and the finished script is shown on the form's
> completion page. Takes about 3 minutes to set up: one Header Auth
> credential.
>
> Two things that made the output much better:
> 1. **Fixed section headers** (`## HOOK`, `## SETUP` …) in the system
>    prompt. That makes it trivial to split the script later, e.g. for one
>    voice-over file per section.
> 2. **Word count instead of "make it 10 minutes"**. LLMs are bad at
>    estimating time but OK at word targets.
>
> JSON download (free, no signup):
> https://thaproduct.github.io/ai-solopreneur-blog/en/free-youtube-script-generator/
>
> Happy to answer questions about the setup. Feedback welcome.

---

## 4. Reddit r/n8n

**Title:** I split my YouTube script workflow into sections so ElevenLabs can voice each part separately: here's the free script half

> Body: same as the forum post (Abschnitt 3), plus at the end:
>
> The bigger version adds a Google Sheets topic queue, Telegram approval
> (`/approve 5`), so no ElevenLabs credits get burned on bad scripts, and
> per-section MP3s in Drive. It's a paid template (€15), linked from the page
> above if anyone's interested. The free one works on its own though.

*Hinweis:* Lies vorher die Regeln von r/n8n zu Eigenwerbung. Der Post ist
bewusst so gebaut, dass der Gratis-Teil im Vordergrund steht.

---

## 5. LinkedIn (Deutsch)

> Ich habe für einen faceless YouTube-Kanal die Skript-Arbeit automatisiert,
> mit n8n und Claude.
>
> Drei Dinge, die den Unterschied gemacht haben:
>
> 1️⃣ Feste Abschnitte (Hook, Setup, Fakten, Theorien, Ending) statt
> Freitext. So lässt sich jedes Kapitel später einzeln vertonen.
> 2️⃣ Wortzahl statt Minutenangabe. 150 Wörter ≈ 1 Minute Sprechzeit.
> 3️⃣ Ein Freigabe-Schritt per Telegram, bevor ElevenLabs Guthaben
> verbraucht.
>
> Den Skript-Teil gibt es als kostenlosen n8n-Workflow:
> https://thaproduct.github.io/ai-solopreneur-blog/kostenlos/
>
> #n8n #Automatisierung #KI #YouTube #Solopreneur

---

## 6. Messen statt raten

| Kennzahl | Wo | Ziel nach 30 Tagen |
|---|---|---|
| Impressionen/Klicks | Google Search Console | > 0, Seiten indexiert |
| Views der Lite-Vorlage | n8n.io Creator Dashboard | > 200 |
| Checkout-Starts | Stripe → Zahlungslinks | ≥ 5 |
| Verkäufe | Stripe | ≥ 1 |
