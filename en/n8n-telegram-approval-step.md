---
layout: post
title: "How to add a Telegram approval step to any n8n workflow"
description: "Human-in-the-loop in n8n: pause an AI workflow until you approve it from Telegram, and lock it to your own chat ID so nobody else can trigger it."
topic: "n8n Telegram approval human in the loop"
date: 2026-11-01 12:00:00 +0100
permalink: /en/n8n-telegram-approval-step/
lang: en
---

AI workflows are great until they spend money or publish something you did not
read. A cheap fix is a **human approval step**: the workflow stops, you review
the result, and only your command starts the expensive part. Telegram is a
good fit because it is free and works on your phone.

## The pattern (two workflows)

**Workflow A** produces something (a script, a draft, a report), saves it
where you can read it (Google Sheets, Notion, a file) and sends you a Telegram
message with the row number, for example: `Approve with: /approve 5`.

**Workflow B** starts with a **Telegram Trigger** (updates: `message`) and does
the expensive or irreversible work only after your command.

Splitting it into two workflows avoids a long-running "wait" node and survives
n8n restarts.

## Workflow B step by step

1. **Telegram Trigger**, updates: `message`. Activate the workflow, triggers
   only fire when it is active.
2. **IF node** with two conditions, combinator AND:
   - `{{ $json.message.text }}` starts with `/approve`
   - `{{ String($json.message.chat.id) }}` equals **your** chat ID
3. **Code node** to read the argument:
   ```js
   const text = $input.first().json.message.text;
   const row = parseInt(text.replace('/approve', '').trim(), 10);
   return [{ json: { row } }];
   ```
4. Look up that row (Google Sheets: filter by `row_number`) and continue with
   the expensive part, such as text-to-speech, publishing or sending emails.
5. Send a Telegram confirmation so you know it ran.

## The check people forget

Anyone who finds your bot's username can message it. Without the chat-ID
condition in step 2, a stranger could trigger the workflow and use up your API
credits. Get your chat ID from @userinfobot and hard-code it in the IF node.

## Common problems

- **Nothing happens:** the workflow is not activated, or the message is not
  exactly `/approve <number>`.
- **`NaN` as row:** extra characters in the message; trim and validate the
  number before the lookup.
- **Works in test, not in production:** the test trigger and the production
  trigger use different webhooks, activate the workflow.

## Want the full version?

I use exactly this pattern in my YouTube pipeline: Claude writes the script,
I approve via Telegram, ElevenLabs narrates it. The ready-made workflows are
here: [n8n YouTube Pipeline Template]({{ site.baseurl }}/en/n8n-youtube-pipeline-template/)
(disclosure: that is my own product, the steps above are enough to build the
approval part yourself).
