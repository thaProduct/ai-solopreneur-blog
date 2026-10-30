---
layout: page
title: "n8n-Vorlage: YouTube-Pipeline"
permalink: /vorlagen/n8n-youtube-pipeline/
description: "Zwei fertige n8n-Workflows: Claude schreibt dein Video-Skript, du gibst es per Telegram frei, ElevenLabs spricht es ein und legt die MP3s in Google Drive."
---

**Von der Themenliste zur fertigen Sprecherspur, ohne Copy-Paste zwischen fünf Tabs.**

Zwei importfertige n8n-Workflows, die ich selbst für einen faceless
YouTube-Kanal nutze:

1. **Skript-Generator:** Nimmt das nächste offene Thema aus Google Sheets,
   lässt Claude ein komplett gegliedertes Skript schreiben (Hook, Setup,
   Fakten, drei Theorien, Ending) und liefert gleich 5 Titelvorschläge plus
   eine Thumbnail-Idee mit. Du bekommst eine Telegram-Nachricht, sobald es
   fertig ist.
2. **Freigabe & Voice:** Du liest das Skript, schickst deinem Bot
   `/freigeben 5`, und für jeden Abschnitt entsteht eine eigene MP3 mit
   ElevenLabs. Die Dateien liegen sauber benannt in deinem Drive-Ordner und
   sind bereit für den Videoschnitt.

## Was drin ist

- 2 n8n-Workflows (JSON, direkt importierbar)
- Google-Sheet-Vorlage für deine Themenliste
- Schritt-für-Schritt-Anleitung auf Deutsch (ca. 15–20 Minuten Einrichtung)
- Abschnitt zum Anpassen: Sprache, Videolänge, Struktur, Stimme, Zeitplan

## Warum mit Freigabe-Schritt?

Weil KI-Skripte nicht blind vertont werden sollten. Erst wenn du
`/freigeben` schickst, wird ElevenLabs-Guthaben verbraucht. Und nur deine
eigene Telegram-Chat-ID darf das auslösen.

## Was du brauchst

- n8n (selbst gehostet oder n8n Cloud)
- Anthropic-API-Key (für Claude)
- ElevenLabs-Account mit API-Zugang
- Google-Account (Sheets + Drive)
- Telegram

Die Nutzung von Anthropic und ElevenLabs bezahlst du direkt beim Anbieter.
In der Vorlage selbst stecken keine laufenden Kosten.

## Preis: 15 €

<p><a href="https://buy.stripe.com/8x2bJ10KdbmCg1wb7O8IU03" style="display:inline-block;padding:12px 24px;background:#2a7ae2;color:#fff;border-radius:6px;text-decoration:none;font-weight:bold;">Jetzt für 15 € kaufen</a></p>

Nach der Zahlung bekommst du sofort den Download-Link (ZIP mit allen
Dateien). Du darfst die Workflows für eigene und Kundenprojekte nutzen und
beliebig anpassen. Weiterverkauf ist nicht erlaubt.

*Digitaler Inhalt: Mit dem Kauf stimmst du zu, dass die Bereitstellung sofort
beginnt, und nimmst zur Kenntnis, dass dein Widerrufsrecht damit erlischt.*

Wie die Pipeline im Detail funktioniert, steht im Artikel
[YouTube-Skripte automatisch erstellen mit n8n, Claude und ElevenLabs]({{ site.baseurl }}/2026/10/30/youtube-skripte-automatisch-n8n-claude-elevenlabs/).
