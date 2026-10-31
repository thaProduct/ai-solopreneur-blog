---
layout: page
title: "English: n8n Template"
permalink: /en/n8n-youtube-pipeline-template/
lang: en
description: "Two ready-to-import n8n workflows: Claude writes your video script, you approve it via Telegram, ElevenLabs narrates it and saves the MP3s to Google Drive."
---

**From topic list to finished voice-over, without copy-pasting between five tabs.**

Two ready-to-import n8n workflows I use for a faceless YouTube channel:

1. **Script Generator:** Takes the next open topic from Google Sheets, has
   Claude write a fully structured script (hook, setup, facts, three
   theories, ending) and adds 5 title ideas plus a thumbnail idea. You get a
   Telegram message as soon as it's done.
2. **Approval & Voice:** You read the script, send your bot `/approve 5`, and
   ElevenLabs generates one MP3 per section. The files land in your Drive
   folder, cleanly named and ready for editing.

## What's included

- 2 n8n workflows (JSON, import directly), **English and German versions**
- Google Sheet template for your topic list
- Step-by-step setup guide (about 15–20 minutes)
- Customization section: language, video length, structure, voice, schedule

## Why an approval step?

Because AI scripts shouldn't be narrated blindly. ElevenLabs credits are
only spent after you send `/approve`, and only your own Telegram chat ID can
trigger it.

## What you need

- n8n (self-hosted or n8n Cloud)
- Anthropic API key (for Claude)
- ElevenLabs account with API access
- Google account (Sheets + Drive)
- Telegram

You pay Anthropic and ElevenLabs usage directly to those providers. The
template itself has no running costs.

## Price: €15

<p><a href="https://buy.stripe.com/8x2bJ10KdbmCg1wb7O8IU03" style="display:inline-block;padding:12px 24px;background:#2a7ae2;color:#fff;border-radius:6px;text-decoration:none;font-weight:bold;">Buy now for €15</a></p>

Right after payment you get the download link (ZIP with all files). You may
use and modify the workflows for your own and your clients' projects.
Reselling is not allowed.

*Digital content: by purchasing you agree that delivery starts immediately
and acknowledge that you thereby lose your right of withdrawal.*

Curious how it works under the hood? Read
[How I automate YouTube scripts with n8n, Claude and ElevenLabs]({{ site.baseurl }}/en/youtube-script-automation-n8n-claude-elevenlabs/).

[Legal notice (Impressum)]({{ site.baseurl }}/impressum/) ·
[Privacy policy (German)]({{ site.baseurl }}/datenschutz/)
