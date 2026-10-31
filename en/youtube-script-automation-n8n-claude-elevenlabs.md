---
layout: page
title: "How I Automate YouTube Scripts with n8n, Claude and ElevenLabs"
permalink: /en/youtube-script-automation-n8n-claude-elevenlabs/
lang: en
description: "The n8n pipeline behind a faceless YouTube channel: topic list in Google Sheets, script by Claude, approval via Telegram, narration by ElevenLabs."
---

For a faceless YouTube channel, writing and narrating scripts is most of the
grunt work. I automated it with two n8n workflows, but kept one step manual
on purpose: approval. Here's how it's built.

## The flow at a glance

```
Google Sheet (topic, status "pending")
        │
        ▼
Workflow 1: Claude writes script + titles + thumbnail idea
        │   → Sheet (status "review") + Telegram message
        ▼
You read the script and send /approve <row>
        │
        ▼
Workflow 2: split script into sections → ElevenLabs per section
        │   → MP3s in Google Drive + Telegram message per part
        ▼
Video editing
```

## Workflow 1: The Script Generator

**Nodes:** Manual Trigger → Google Sheets → HTTP Request to the Claude API →
Code → Google Sheets → Telegram

1. **Get next topic:** The Google Sheets node looks for the first row with
   `Status = pending` and returns only that one (*Return first match*).
2. **Generate script:** An HTTP request to the Anthropic API. All the real
   work is in the system prompt: it fixes the structure with timestamps
   (hook, setup, facts, three theories, ending), demands verifiable facts
   only, and targets about 1,700 words. Every section starts with a line like
   `## [0:00-0:15] HOOK`.
3. **Split script & titles:** After the ending, Claude writes a separator
   line `===TITLES & THUMBNAIL===`, followed by 5 title ideas and a thumbnail
   idea. A small Code node splits the response on that line:

   ```js
   const full = $json.content.find(b => b.type === "text").text;
   const [script, meta] = full.split("===TITLES & THUMBNAIL===");
   return [{ json: { script: script.trim(), meta: (meta || "").trim() } }];
   ```

4. **Back to the sheet:** Script and titles go into their own columns, status
   switches to `review`.
5. **Telegram:** The title ideas arrive on my phone, together with the
   ready-made command `/approve 5`.

## Workflow 2: Approval and Narration

**Nodes:** Telegram Trigger → IF → Code → Google Sheets → Code → Loop →
HTTP Request to ElevenLabs → Google Drive → Telegram

1. **Telegram Trigger + IF:** Only reacts to messages that start with
   `/approve` **and** come from my own chat. The second check matters:
   Telegram bots can be found by anyone. Without it, anyone who finds the bot
   could burn through your ElevenLabs credits.
2. **Get the row:** The number after `/approve` is the row number in the
   sheet.
3. **Split into sections:** A regular expression cuts the script at the
   `## [time] NAME` headings. Each section gets a file name like
   `03_facts.mp3`.
4. **Loop over sections:** A *Loop Over Items* node sends one section at a
   time to the ElevenLabs API (`eleven_multilingual_v2`). The response comes
   back as a file.
5. **Drive + Telegram:** Each MP3 is saved to the Drive folder, and every
   finished part triggers a short message.

## Why separate MP3s instead of one long file?

- If one section sounds off, you only regenerate that one.
- In the editor you automatically get cut points at chapter boundaries.
- Shorter requests to ElevenLabs fail less often.

## Things to keep in mind

- **Check the facts:** Even when told to use verifiable facts only, a
  language model can get details wrong. That's what the approval step is
  for: read the script before approving it.
- **Costs:** The Claude API and ElevenLabs bill by usage. On ElevenLabs your
  quota depends on your plan. A 1,700-word script is roughly 10,000
  characters. Check how many characters your plan includes.
- **Voice settings:** With `stability` around 0.6 and `style` around 0.3 the
  voice sounds calm for documentary narration without getting monotonous.

## The template

If you don't want to rebuild this yourself: both workflows are available as
a ready-to-import template with a sheet template and setup guide, in English
and German. Personal IDs are removed.

**[Get the n8n template →]({{ site.baseurl }}/en/n8n-youtube-pipeline-template/)**
