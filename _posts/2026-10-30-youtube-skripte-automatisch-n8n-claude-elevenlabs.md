---
layout: post
title: "YouTube-Skripte automatisch erstellen mit n8n, Claude und ElevenLabs"
description: "So ist meine n8n-Pipeline für einen faceless YouTube-Kanal aufgebaut: Themenliste in Google Sheets, Skript von Claude, Freigabe per Telegram, Vertonung mit ElevenLabs."
topic: "YouTube Skripte automatisch erstellen n8n"
date: 2026-10-30 12:00:00 +0100
---

Für einen faceless YouTube-Kanal ist das Schreiben und Vertonen der Skripte
die meiste Fleißarbeit. Ich habe das mit zwei n8n-Workflows automatisiert.
Ein Schritt bleibt aber bewusst manuell: die Freigabe. Hier ist der Aufbau.

## Der Ablauf im Überblick

```
Google Sheet (Thema, Status "pending")
        │
        ▼
Workflow 1: Claude schreibt Skript + Titel + Thumbnail-Idee
        │   → Sheet (Status "review") + Telegram-Nachricht
        ▼
Du liest das Skript und schickst /freigeben <Zeile>
        │
        ▼
Workflow 2: Skript in Abschnitte teilen → ElevenLabs pro Abschnitt
        │   → MP3s in Google Drive + Telegram-Meldung pro Teil
        ▼
Videoschnitt
```

## Workflow 1: Der Skript-Generator

**Nodes:** Manueller Start → Google Sheets → HTTP-Request an die Claude-API →
Code → Google Sheets → Telegram

1. **Nächstes Thema holen:** Der Google-Sheets-Node sucht die erste Zeile mit
   `Status = pending` und gibt nur diese zurück (*Return first match*).
2. **Skript generieren:** Ein HTTP-Request an die Anthropic-API. Die ganze
   Arbeit steckt im System-Prompt. Er legt die Gliederung mit Zeitmarken fest
   (Hook, Setup, Fakten, drei Theorien, Ending), verlangt nur überprüfbare
   Fakten und eine Länge von etwa 1.700 Wörtern. Jeder Abschnitt beginnt mit
   einer Zeile im Format `## [0:00-0:15] HOOK`.
3. **Skript & Titel trennen:** Nach dem Ending schreibt Claude eine
   Trennzeile `===TITEL & THUMBNAIL===` und danach 5 Titelvorschläge plus eine
   Thumbnail-Idee. Ein kleiner Code-Node teilt die Antwort an dieser Zeile:

   ```js
   const full = $json.content.find(b => b.type === "text").text;
   const [script, meta] = full.split("===TITEL & THUMBNAIL===");
   return [{ json: { script: script.trim(), meta: (meta || "").trim() } }];
   ```

4. **Zurück ins Sheet:** Skript und Titel landen in eigenen Spalten, der
   Status springt auf `review`.
5. **Telegram:** Ich bekomme die Titelideen direkt aufs Handy, zusammen mit
   dem fertigen Befehl `/freigeben 5`.

## Workflow 2: Freigabe und Vertonung

**Nodes:** Telegram-Trigger → IF → Code → Google Sheets → Code → Loop →
HTTP-Request an ElevenLabs → Google Drive → Telegram

1. **Telegram-Trigger + IF:** Reagiert nur auf Nachrichten, die mit
   `/freigeben` beginnen und aus meinem eigenen Chat kommen. Der zweite Teil
   ist wichtig: Telegram-Bots sind öffentlich auffindbar. Ohne diese Prüfung
   könnte jeder, der den Bot findet, ElevenLabs-Guthaben verbrauchen.
2. **Zeile holen:** Die Zahl hinter `/freigeben` ist die Zeilennummer im Sheet.
3. **Skript in Abschnitte teilen:** Ein regulärer Ausdruck schneidet an den
   `## [Zeit] NAME`-Überschriften. Jeder Abschnitt bekommt einen Dateinamen
   wie `03_fakten.mp3`.
4. **Loop über die Abschnitte:** Ein *Loop Over Items*-Node schickt einen
   Abschnitt nach dem anderen an die ElevenLabs-API (`eleven_multilingual_v2`).
   Die Antwort kommt als Datei zurück.
5. **Drive + Telegram:** Jede MP3 landet im Drive-Ordner, und für jeden
   fertigen Teil kommt eine kurze Meldung.

## Warum einzelne MP3s statt einer langen Datei?

- Wenn ein Abschnitt schlecht klingt, vertonst du nur diesen neu.
- Im Schnitt hast du automatisch Schnittmarken an den Kapitelgrenzen.
- Kürzere Anfragen an ElevenLabs schlagen seltener fehl.

## Was du beachten solltest

- **Fakten prüfen:** Auch mit der Anweisung „nur verifizierbare Fakten“
  kann ein Sprachmodell Details falsch wiedergeben. Deshalb gibt es den
  Freigabe-Schritt. Lies das Skript, bevor du es freigibst.
- **Kosten:** Claude-API und ElevenLabs rechnen nach Nutzung ab. Bei
  ElevenLabs hängt das Kontingent vom Tarif ab. Ein 1.700-Wörter-Skript sind
  grob 10.000 Zeichen. Prüf vorher, wie viele Zeichen dein Tarif enthält.
- **Stimmen-Einstellungen:** Mit `stability` um 0,6 und `style` um 0,3 klingt
  die Stimme bei dokumentarischen Texten ruhig, ohne monoton zu werden.

## Die Vorlage

Wenn du die Pipeline nicht selbst nachbauen willst: Beide Workflows gibt es
als importfertige Vorlage mit Sheet-Vorlage und deutscher Einrichtungsanleitung.
Persönliche IDs habe ich daraus entfernt.

**[Zur n8n-Vorlage →]({{ site.baseurl }}/vorlagen/n8n-youtube-pipeline/)**
