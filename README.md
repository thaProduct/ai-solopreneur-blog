# KI-Tools & Automatisierung — Blog

Jekyll-Blog, gehostet ueber GitHub Pages (kostenlos). Artikel werden vom
Jarvis Content-Agenten (`content_agent.py`, `_handle_content` in `bridge.py`)
recherchiert und entworfen und landen zuerst in `_drafts/` (nicht oeffentlich
sichtbar). Erst nach ausdruecklicher Freigabe verschiebt `publish_draft()`
einen Entwurf nach `_posts/` und pusht ihn live.

## Lokale Vorschau

```
bundle exec jekyll serve
```

(Benoetigt Ruby + Jekyll; ohne das koennen Entwuerfe auch einfach als
Markdown-Dateien in `_drafts/` gelesen werden.)
