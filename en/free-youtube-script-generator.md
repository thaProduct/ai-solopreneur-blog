---
layout: page
title: "Free: n8n Script Generator"
permalink: /en/free-youtube-script-generator/
lang: en
description: "Free n8n workflow: type a topic into a form, Claude writes a structured YouTube script plus 5 title ideas. Import in 3 minutes."
---

**One form, one click, one finished YouTube script.** Free, no email
required.

Enter a topic, the video length and the language. Claude writes a script
with hook, setup, facts, theories and ending, and suggests five titles. The
result shows up right in your browser.

<p><a href="{{ site.baseurl }}/freebies/youtube-script-generator-lite.json" download style="display:inline-block;padding:12px 24px;background:#2a7ae2;color:#fff;border-radius:6px;text-decoration:none;font-weight:bold;">Download workflow (JSON)</a></p>

## Setup in 3 minutes

1. In n8n: **Workflows → Import from File** and pick the JSON file.
2. Create a **Header Auth** credential: name `x-api-key`, value = your
   Anthropic API key.
3. Select that credential in the node **Claude: write script**.
4. Activate the workflow and open the form URL from the first node.

A 10-minute script costs a few cents in Anthropic usage, depending on the
model. You can change the model in the **Build prompt** node.

## Next step: the full pipeline

The Lite version writes one script when you call it. The
[full version]({{ site.baseurl }}/en/n8n-youtube-pipeline-template/) handles
the rest:

| | Lite (free) | Full (€15) |
|---|---|---|
| Script written by Claude | ✓ | ✓ |
| 5 title ideas | ✓ | ✓ + thumbnail idea |
| Topic queue in Google Sheets, processed automatically | – | ✓ |
| Telegram notification and approval | – | ✓ |
| ElevenLabs voice-over per section | – | ✓ |
| MP3s saved to Google Drive | – | ✓ |
| Setup guide | short | detailed, English + German |

[Get the full version for €15]({{ site.baseurl }}/en/n8n-youtube-pipeline-template/)
