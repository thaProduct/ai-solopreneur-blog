#!/usr/bin/env python3
"""Kontaktbogen mit Bildkandidaten pro Abschnitt, damit Bilder gezielt per ID gewählt werden.

Aufruf: python pick_images.py skripte/04-voynich.json bogen.jpg [Kandidaten pro Abschnitt]
Danach im Skript-JSON pro Abschnitt "image": "<openverse-id>" setzen.
Eine Liste der IDs wird als bogen.jpg.txt geschrieben.
"""
import io, json, sys
from PIL import Image, ImageDraw, ImageFont
from make_short import OV, LIC, get

TW, TH = 220, 160


def main(script, out, n=6):
    spec = json.load(open(script, encoding="utf-8"))
    rows, ids = [], []
    font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 16)
    for si, seg in enumerate(spec["segments"]):
        q = seg.get("pick_query", seg["query"])
        res = get(OV, params={"q": q, "license": ",".join(LIC), "page_size": n * 2, "mature": "false"}).json()
        row = Image.new("RGB", (TW * n, TH), "black")
        k = 0
        for p in res.get("results", []):
            if k >= n or (p.get("width") or 0) < 500:
                continue
            try:
                im = Image.open(io.BytesIO(get(p["thumbnail"], tries=1).content)).convert("RGB")
            except Exception:
                continue
            im.thumbnail((TW, TH))
            row.paste(im, (k * TW + (TW - im.width) // 2, (TH - im.height) // 2))
            ImageDraw.Draw(row).text((k * TW + 4, 2), f"{si}-{k}", fill="yellow", font=font,
                                     stroke_width=2, stroke_fill="black")
            ids.append(f"{si}-{k} {p['id']} {p['source']} {p['license']} | {(p.get('title') or '')[:70]}")
            k += 1
        rows.append(row)
    sheet = Image.new("RGB", (TW * n, TH * len(rows)))
    for i, r in enumerate(rows):
        sheet.paste(r, (0, i * TH))
    sheet.save(out, quality=85)
    open(out + ".txt", "w").write("\n".join(ids) + "\n")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2], int(sys.argv[3]) if len(sys.argv) > 3 else 6)
