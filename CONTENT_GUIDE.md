# Content-Leitfaden

Regeln für jeden Artikel, egal ob von Hand oder von einem KI-Agenten geschrieben.
Ein Artikel, der eine dieser Regeln verletzt, wird nicht veröffentlicht.

## Fakten

- Jede Preisangabe, Zahl und Funktionsangabe stammt aus einer Quelle, die beim Schreiben geprüft wurde. Ist die offizielle Preisseite nicht erreichbar, mindestens zwei unabhängige Quellen abgleichen.
- Preise immer mit „ca.“ und dem Stand angeben (z. B. „Stand Oktober 2026“) und auf die Preisseite des Anbieters verweisen.
- Keine eingestellten Produkte empfehlen (Beispiel: Ivona gibt es seit der Übernahme durch Amazon nicht mehr).
- Keine erfundene Erfahrung: „Wir haben getestet“ nur, wenn es wirklich getestet wurde. Sonst „laut Anbieter“ oder „nach Nutzerberichten“.

## Sprache

- Deutsch, Du-Form, kurze Sätze. Keine englischen Satzreste („Over 500“).
- Der Leser soll nach dem ersten Absatz wissen, ob der Artikel seine Frage beantwortet.
- Jeder Vergleich endet mit einer klaren Empfehlung: welches Tool für wen.

## Aufbau

- Front Matter: `title`, `description` (max. ca. 155 Zeichen), `date`, bei Überarbeitung `last_modified_at`.
- Dateiname: `JJJJ-MM-TT-kurzer-slug.md`, nur Kleinbuchstaben, Ziffern und Bindestriche, keine Umlaute.
- Einstieg mit „Kurz gesagt“-Liste, dann eine Vergleichstabelle, dann ein Abschnitt pro Tool mit Stärken, Schwächen, Preis und „Für wen“.
- Abschluss mit Empfehlung und „Häufige Fragen“.
- Mindestens 900 Wörter, aber nur so lang wie nötig.

## Affiliate-Links

- Nie Platzhalter wie `[[AFFILIATE: …]]` im sichtbaren Text. Bis ein echter Link existiert, als HTML-Kommentar markieren: `<!-- affiliate: elevenlabs -->`.
- Echte Affiliate-Links mit Sternchen kennzeichnen (`ElevenLabs*`) und unter dem Artikel auf den [Werbehinweis](/werbehinweis/) verlinken.
- Tools ohne Partnerprogramm genauso fair behandeln wie Tools mit.

## Vor dem Veröffentlichen

- Keine Platzhalter, kein `TODO`, keine eckigen Klammern im sichtbaren Text.
- Alle Links funktionieren.
- `date` liegt nicht in der Zukunft (sonst blendet Jekyll den Artikel aus, falls `future: true` entfernt wird).
