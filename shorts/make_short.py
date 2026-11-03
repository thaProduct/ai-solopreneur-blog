#!/usr/bin/env python3
"""Erzeugt ein vertikales Kurzvideo (1080x1920) aus einem Skript-JSON.

Ablauf: Sprachausgabe pro Abschnitt (edge-tts, Wort-Zeitstempel) ->
frei lizenzierte Bilder von Wikimedia Commons -> Ken-Burns-Zoom ->
Untertitel (ASS, Wortgruppen) -> leiser, selbst erzeugter Klangteppich ->
MP4 + Beschreibungstext mit Bildnachweisen.

Aufruf: python make_short.py skripte/01-kaspar-hauser.json ausgabe/
"""
import asyncio, html, json, re, subprocess, sys, tempfile, time
from pathlib import Path

import edge_tts
import requests
from PIL import Image, ImageFilter, ImageEnhance

W, H, FPS = 1080, 1920, 30
VOICE, RATE = "de-DE-ConradNeural", "+6%"
GAP = 0.25  # Pause zwischen Abschnitten (s)
UA = {"User-Agent": "ShortsMaker/1.0 (https://github.com/thaProduct/ai-solopreneur-blog)"}
API = "https://commons.wikimedia.org/w/api.php"
OK_LICENSE = re.compile(r"^(public domain|pd|cc0|cc[- ]by)", re.I)
FONT = "Inter Display"


def get(url, **kw):
    """GET mit Pausen und Wiederholung bei 429/5xx (Wikimedia-Regeln)."""
    for attempt in range(6):
        time.sleep(1.0)
        r = requests.get(url, headers=UA, timeout=60, **kw)
        if r.status_code == 200:
            return r
        wait = int(r.headers.get("Retry-After", 0) or 0) or 5 * 2 ** attempt
        print(f"  {r.status_code} von {url[:60]}, warte {wait}s", file=sys.stderr)
        time.sleep(wait)
    r.raise_for_status()


def run(cmd):
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)


# ---------- Sprachausgabe ----------
async def tts(text, mp3):
    words = []
    com = edge_tts.Communicate(text, VOICE, rate=RATE, boundary="WordBoundary")
    with open(mp3, "wb") as f:
        async for c in com.stream():
            if c["type"] == "audio":
                f.write(c["data"])
            elif c["type"] == "WordBoundary":
                words.append((c["offset"] / 1e7, (c["offset"] + c["duration"]) / 1e7, c["text"]))
    return words


def duration(path):
    out = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration",
                          "-of", "csv=p=0", str(path)], capture_output=True, text=True).stdout
    return float(out.strip())


# ---------- Bilder ----------
def commons_images(query, used, limit=12):
    r = get(API, params={
        "action": "query", "format": "json", "generator": "search", "gsrsearch": query,
        "gsrnamespace": 6, "gsrlimit": limit, "prop": "imageinfo",
        "iiprop": "url|extmetadata|mime|size", "iiurlwidth": 1600})
    pages = sorted(r.json().get("query", {}).get("pages", {}).values(), key=lambda p: p.get("index", 99))
    for p in pages:
        ii = (p.get("imageinfo") or [{}])[0]
        meta = ii.get("extmetadata", {})
        lic = meta.get("LicenseShortName", {}).get("value", "")
        if ii.get("mime") not in ("image/jpeg", "image/png") or not OK_LICENSE.match(lic):
            continue
        if ii.get("width", 0) < 500 or p["title"] in used:
            continue
        artist = re.sub(r"<[^>]+>", "", html.unescape(meta.get("Artist", {}).get("value", "unbekannt"))).strip()
        yield {"title": p["title"], "url": ii.get("thumburl") or ii["url"], "license": lic,
               "artist": artist[:120], "page": ii.get("descriptionurl", "")}


def fetch_image(query, used, dest):
    for cand in commons_images(query, used):
        try:
            data = get(cand["url"]).content
            dest.write_bytes(data)
            Image.open(dest).verify()
            used.add(cand["title"])
            return cand
        except Exception:
            continue
    return None


def compose(src, dest):
    """Bild hochkant: unscharfer, abgedunkelter Hintergrund + Bild in voller Breite."""
    im = Image.open(src).convert("RGB")
    sw, sh = int(W * 1.25), int(H * 1.25)
    bg = im.copy()
    s = max(sw / bg.width, sh / bg.height)
    bg = bg.resize((int(bg.width * s) + 1, int(bg.height * s) + 1))
    bg = bg.crop(((bg.width - sw) // 2, (bg.height - sh) // 2, (bg.width - sw) // 2 + sw, (bg.height - sh) // 2 + sh))
    bg = ImageEnhance.Brightness(bg.filter(ImageFilter.GaussianBlur(40))).enhance(0.45)
    s = min(sw / im.width, sh * 0.62 / im.height)
    fg = im.resize((int(im.width * s), int(im.height * s)))
    fg = ImageEnhance.Contrast(ImageEnhance.Color(fg).enhance(0.75)).enhance(1.08)
    bg.paste(fg, ((sw - fg.width) // 2, int(sh * 0.40) - fg.height // 2))
    bg.save(dest, quality=93)


def clip(img, dur, out, idx):
    n = max(1, int(round(dur * FPS)))
    zin = idx % 2 == 0  # abwechselnd rein- und rauszoomen
    z = f"1+0.10*on/{n}" if zin else f"1.10-0.10*on/{n}"
    vf = (f"zoompan=z='{z}':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d={n}:s={W}x{H}:fps={FPS},"
          "vignette=PI/4,format=yuv420p")
    run(["ffmpeg", "-y", "-loop", "1", "-i", str(img), "-vf", vf, "-frames:v", str(n),
         "-c:v", "libx264", "-preset", "veryfast", "-crf", "18", str(out)])


# ---------- Untertitel ----------
def ass_time(t):
    h, m = int(t // 3600), int(t % 3600 // 60)
    return f"{h}:{m:02d}:{t % 60:05.2f}"


def make_ass(words, path):
    head = f"""[Script Info]
ScriptType: v4.00+
PlayResX: {W}
PlayResY: {H}

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Sub,{FONT},86,&H00FFFFFF,&H00FFFFFF,&H00000000,&H64000000,-1,0,0,0,100,100,0,0,1,6,2,5,70,70,0,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
"""
    lines, group = [], []
    def flush():
        if not group:
            return
        txt = " ".join(w[2] for w in group)
        lines.append(f"Dialogue: 0,{ass_time(group[0][0])},{ass_time(group[-1][1] + 0.05)},Sub,,0,0,0,,"
                     f"{{\\pos({W // 2},{int(H * 0.74)})\\fad(60,0)}}{txt}")
        group.clear()
    for w in words:
        group.append(w)
        if len(group) >= 3 or re.search(r"[.,:?!]$", w[2]) or len(" ".join(x[2] for x in group)) > 18:
            flush()
    flush()
    path.write_text(head + "\n".join(lines) + "\n", encoding="utf-8")


# ---------- Hauptablauf ----------
def main(script_path, out_dir):
    spec = json.loads(Path(script_path).read_text(encoding="utf-8"))
    out_dir = Path(out_dir); out_dir.mkdir(parents=True, exist_ok=True)
    slug = Path(script_path).stem
    tmp = Path(tempfile.mkdtemp(prefix=slug + "-"))
    used, credits, clips, words_all, audio_parts = set(), [], [], [], []
    t0, last_img = 0.0, None
    for i, seg in enumerate(spec["segments"]):
        mp3 = tmp / f"s{i}.mp3"
        words = asyncio.run(tts(seg["text"], mp3))
        d = duration(mp3) + GAP
        words_all += [(a + t0, b + t0, w) for a, b, w in words]
        audio_parts.append((mp3, d))
        raw = tmp / f"raw{i}"
        info = fetch_image(seg["query"], used, raw)
        if info:
            credits.append(info)
            comp = tmp / f"img{i}.jpg"; compose(raw, comp); last_img = comp
        elif last_img is None:
            raise SystemExit(f"Kein frei lizenziertes Bild für: {seg['query']}")
        clips.append((last_img, d))
        t0 += d
    # Video
    lst = tmp / "clips.txt"
    for i, (img, d) in enumerate(clips):
        c = tmp / f"c{i}.mp4"; clip(img, d, c, i)
    lst.write_text("".join(f"file '{tmp / f'c{i}.mp4'}'\n" for i in range(len(clips))))
    run(["ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", str(lst), "-c", "copy", str(tmp / "video.mp4")])
    # Sprache mit Pausen zusammenfügen
    inputs, filt = [], []
    for i, (mp3, d) in enumerate(audio_parts):
        inputs += ["-i", str(mp3)]
        filt.append(f"[{i}:a]apad=whole_dur={d:.3f}[a{i}]")
    filt.append("".join(f"[a{i}]" for i in range(len(audio_parts))) + f"concat=n={len(audio_parts)}:v=0:a=1[voice]")
    run(["ffmpeg", "-y", *inputs, "-filter_complex", ";".join(filt), "-map", "[voice]", str(tmp / "voice.wav")])
    total = duration(tmp / "voice.wav")
    # Klangteppich: tiefes, gefiltertes Rauschen + leiser Sinuston (selbst erzeugt, lizenzfrei)
    run(["ffmpeg", "-y", "-f", "lavfi", "-i", f"anoisesrc=color=brown:amplitude=0.6:d={total:.2f}",
         "-f", "lavfi", "-i", f"sine=frequency=55:d={total:.2f}",
         "-filter_complex", "[0]lowpass=f=180,volume=0.10[n];[1]volume=0.04[s];[n][s]amix=2,"
         f"afade=t=in:d=1.5,afade=t=out:st={max(0, total - 2):.2f}:d=2[bed]",
         "-map", "[bed]", str(tmp / "bed.wav")])
    make_ass(words_all, tmp / "subs.ass")
    out = out_dir / f"{slug}.mp4"
    run(["ffmpeg", "-y", "-i", str(tmp / "video.mp4"), "-i", str(tmp / "voice.wav"), "-i", str(tmp / "bed.wav"),
         "-filter_complex", f"[0:v]ass={tmp / 'subs.ass'}[v];[1:a][2:a]amix=2:normalize=0,loudnorm=I=-14:TP=-1.5[a]",
         "-map", "[v]", "-map", "[a]", "-c:v", "libx264", "-preset", "medium", "-crf", "20",
         "-c:a", "aac", "-b:a", "160k", "-shortest", "-movflags", "+faststart", str(out)])
    # Beschreibung mit Bildnachweisen
    desc = [spec["title"], "", " ".join("#" + t for t in spec.get("tags", [])), "", "Bildnachweise (Wikimedia Commons):"]
    desc += [f"- {c['title'].removeprefix('File:')}: {c['artist']}, {c['license']}, {c['page']}" for c in credits]
    desc += ["", "Stimme: KI-generiert."]
    (out_dir / f"{slug}.txt").write_text("\n".join(desc) + "\n", encoding="utf-8")
    print(f"{out}  {total:.1f}s  {len(credits)} Bilder")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
