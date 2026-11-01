---
layout: page
title: "Kostenlos: n8n-Skript-Generator"
permalink: /kostenlos/
description: "Kostenloser n8n-Workflow: Thema ins Formular, Claude schreibt ein gegliedertes YouTube-Skript plus 5 Titelideen. Import in 3 Minuten."
---

**Ein Formular, ein Klick, ein fertiges YouTube-Skript.** Gratis und ohne
E-Mail-Adresse.

Du gibst ein Thema, die gewünschte Videolänge und die Sprache ein. Claude
schreibt ein Skript mit Hook, Setup, Fakten, Theorien und Ending und schlägt
dir fünf Titel vor. Das Ergebnis erscheint direkt im Browser.

<p><a href="{{ site.baseurl }}/freebies/youtube-script-generator-lite.json" download style="display:inline-block;padding:12px 24px;background:#2a7ae2;color:#fff;border-radius:6px;text-decoration:none;font-weight:bold;">Workflow herunterladen (JSON)</a></p>

## Einrichtung in 3 Minuten

1. In n8n: **Workflows → Import from File** und die JSON-Datei wählen.
2. Neue Credential vom Typ **Header Auth** anlegen:
   Name `x-api-key`, Wert = dein Anthropic-API-Key.
3. Im Node **Claude: write script** diese Credential auswählen.
4. Workflow aktivieren und die Formular-URL aus dem ersten Node öffnen.

Ein 10-Minuten-Skript kostet bei Anthropic je nach Modell nur wenige Cent.
Das Modell kannst du im Node **Build prompt** ändern.

## Der nächste Schritt: die komplette Pipeline

Die Lite-Version schreibt ein Skript, wenn du sie aufrufst. Die
[Vollversion]({{ site.baseurl }}/vorlagen/n8n-youtube-pipeline/) übernimmt den
Rest:

| | Lite (gratis) | Vollversion (15 €) |
|---|---|---|
| Skript mit Claude | ✓ | ✓ |
| 5 Titelideen | ✓ | ✓ + Thumbnail-Idee |
| Themenliste in Google Sheets, automatisch abgearbeitet | – | ✓ |
| Benachrichtigung und Freigabe per Telegram | – | ✓ |
| ElevenLabs-Sprachaufnahme pro Abschnitt | – | ✓ |
| MP3s automatisch in Google Drive | – | ✓ |
| Anleitung auf Deutsch und Englisch | kurz | ausführlich |

[Zur Vollversion für 15 €]({{ site.baseurl }}/vorlagen/n8n-youtube-pipeline/)

*[English version]({{ site.baseurl }}/en/free-youtube-script-generator/)*
