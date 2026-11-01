# Werbe-Entwürfe n8n YouTube-Pipeline (nicht veröffentlicht, Jekyll ignoriert _drafts)

Regeln: Nichts automatisch posten. Selbst posten, Zugehörigkeit offenlegen ("ich habe das gebaut"), keine Einkommensversprechen, Link nur wo erlaubt (Subreddit- und Forenregeln vorher lesen).
Links: Artikel EN https://thaproduct.github.io/ai-solopreneur-blog/en/youtube-script-automation-n8n-claude-elevenlabs/ · Vorlage EN https://thaproduct.github.io/ai-solopreneur-blog/en/n8n-youtube-pipeline-template/ · Vorlage DE https://thaproduct.github.io/ai-solopreneur-blog/vorlagen/n8n-youtube-pipeline/

---

## 1) r/n8n: Anleitung (kein Verkaufspost)

**Titel:** How I split YouTube script writing from voice-over in n8n, with a Telegram approval step

I run a small faceless channel and got tired of copy-pasting between tabs. My setup is two workflows:

1. Schedule/manual trigger -> Google Sheets (next row with status `pending`) -> Claude API (system prompt forces `## [time] SECTION` headings) -> write draft back to the sheet -> Telegram message.
2. Telegram Trigger -> IF (message starts with `/approve` AND chat ID equals mine) -> read row -> Code node splits the script on the headings -> loop -> ElevenLabs TTS (HTTP Request, response as file) -> Google Drive -> Telegram confirmation per part.

Things that bit me:
- Check the chat ID in the IF node, otherwise anyone who finds your bot can burn your ElevenLabs credits.
- ElevenLabs via HTTP Request needs a Header Auth credential named exactly `xi-api-key`.
- If sections are not split, your headings do not match the regex.
- Keep the approval step: reading the script before paying for audio saves a lot.

Happy to answer questions about the Code node or the prompt. Full write-up: <Artikel-Link>. (Disclosure: I also sell the ready-made JSON files, link in the article; the write-up above is enough to rebuild it yourself.)

---

## 2) n8n-Community-Forum, Kategorie "Built with n8n"

**Titel:** Faceless YouTube pipeline: Claude script -> Telegram approval -> ElevenLabs voice -> Drive

Kurzbeschreibung (2 Sätze), Screenshot beider Workflows (nach dem Import selbst machen), die vier Stolpersteine aus Post 1, Hinweis auf Modell/Kosten pro Video (selbst nachmessen, keine Zahl erfinden), Link zum Artikel, Offenlegung dass es eine Vorlage zu kaufen gibt.

---

## 3) YouTube-Video (ca. 6-8 Min.) "Von der Themenliste zur fertigen Sprecherstimme"

0:00 Hook: "Ich schreibe kein Skript mehr von Hand. Ich gebe ein Thema ein, lese Probe, tippe /approve und bekomme die MP3s."
0:20 Überblick: Sheet -> Claude -> Telegram -> ElevenLabs -> Drive (Diagramm)
1:00 Workflow 1 live: Thema, Skript, Titelvorschläge im Sheet
3:00 Workflow 2 live: /approve 2, Teile erscheinen im Drive-Ordner
5:00 Stolpersteine: Chat-ID-Prüfung, xi-api-key, Überschriftenformat
6:00 Grenzen: Skripte immer gegenlesen, Fakten prüfen, API-Kosten fallen an
6:30 CTA: "Die fertigen Workflows gibt es als Vorlage, Link in der Beschreibung (Werbung/eigenes Produkt)."

Beschreibungstext: Kapitel, Link Artikel, Link Vorlage, Hinweis "Eigenes Produkt".
Titelideen: "YouTube-Skripte automatisieren mit n8n + Claude" · "Faceless YouTube: Skript und Stimme auf Autopilot (mit Freigabe)"
