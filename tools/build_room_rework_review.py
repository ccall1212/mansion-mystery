"""Build a clean/annotated draft gallery without altering source image pixels."""

import html

import json

from pathlib import Path



ROOT=Path(__file__).resolve().parents[1]

OUT=ROOT/'assets/rooms/revisions/2026-10-24-room-rework'

batch=json.loads((OUT/'manifest.json').read_text(encoding='utf-8'))

esc=html.escape

parts=['''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Mansion Mystery — room rework drafts</title>

<style>body{font:18px system-ui;background:#17242b;color:#e1e9eb;margin:24px}a,h1,h2,h3{color:#edce98}nav{display:flex;flex-wrap:wrap;gap:14px}article{margin:40px 0;border-top:1px solid #53636b;padding-top:16px}img{display:block;width:100%;image-rendering:pixelated}.compare{display:grid;grid-template-columns:1fr 1fr;gap:18px}.frame{position:relative}.overlay{position:absolute;inset:0;width:100%;height:100%;pointer-events:none}.clean .overlay{display:none}.badge{padding:9px;background:#263941;border-left:4px solid #e4c48b}button{font:inherit;padding:9px;cursor:pointer}summary{cursor:pointer;color:#edce98}figure{margin:0}figcaption{margin:8px 0}.note{color:#ffd4a9}@media(max-width:1000px){.compare{grid-template-columns:1fr}}</style>

<h1>Room rework — nine drafts for your review</h1>

<p>Eight approved replacements now integrated into the compact mansion, plus one future bar concept. Foyer remains unchanged. Door labels are separate overlays; runtime art has no text.</p>

<p>The current game uses the approved replacement backgrounds and updated door/stair collision. Furniture tags remain provisional; Char has four approved library seat fits. Other staging/masks need calibration.</p>

<button onclick="document.body.classList.toggle('clean')">Show / hide door labels</button>

<p><a href="manifest.json">Exact prompts, reference/output hashes and draft status</a> · <a href="../../../../test-results/reworked-furniture/index.html">Furniture IDs and tagged screenshots</a></p><nav>''']

for j in batch['jobs']:parts.append(f'<a href="#{j["id"]}">{esc(j["id"])}</a>')

parts.append('</nav>')

for j in batch['jobs']:

    image=Path(j['path']).name

    before='../../../'+j['source'].removeprefix('assets/')

    sides=' · '.join(s.upper()+': '+str(n) for s,n in j['doors'].items())

    review_status='ART APPROVED / FIT PENDING' if j.get('approval')=='approved' else 'DRAFT / AWAITING REVIEW'

    parts.append(f'<article id="{j["id"]}"><h2>{esc(j["id"])} — {esc(j["name"])}</h2><p class="badge">{sum(j["doors"].values())} openings — {sides} · {review_status}</p><div class="compare"><figure><figcaption>Current reference</figcaption><img src="{before}" alt="{esc(j["id"])} original reference"></figure><figure><figcaption>New candidate — {image}</figcaption><div class="frame"><img src="{image}" alt="{esc(j["name"])} draft"><svg class="overlay" viewBox="0 0 480 320" aria-label="Cardinal doorway labels">')

    for door in j['door_positions']:

        x,y=door['position']; label=door['side'].upper()

        lx=max(3,min(397,x-35));ly=max(19,min(302,y))

        parts.append(f'<circle cx="{x}" cy="{y}" r="5" fill="#f3c77c" stroke="#101d28"/><rect x="{lx}" y="{ly-17}" width="80" height="16" fill="#101d28"/><text x="{lx+3}" y="{ly-5}" fill="#ffe2a6" font-size="10">{label} OPENING</text>')

    parts.append('</svg></div></figure></div>')

    parts.append(f'<details><summary>Room requirements and exact generation prompt</summary><p>{esc(j["brief"])}</p><pre style="white-space:pre-wrap">{esc(j["prompt"])}</pre></details>')

    parts.append('<p class="note">Furniture IDs, contact landmarks, collision and occlusion are not calibrated for this draft. Door count is visually reviewed; final usability awaits game integration.</p>')

    if j['id']=='g_main_stair':parts.append('<p>One straight flight to the north door; west library doorway and south foyer threshold. The new stair axis requires new trigger/arrival coordinates.</p>')

    if j['id']=='g_kitchen':parts.append('<p>The approved kitchen includes a low work stool, tagged separately from tall bar stools.</p>')

    if j['id']=='future_bar':parts.append('<p>Four north-facing public-side stools. This is a future-room asset concept; it does not add a room to the compact mansion.</p>')

    parts.append('</article>')

parts.append('<p>Review room IDs individually: approve, request a specific change, or reject. Artwork approval is separate from runtime fit and integration. All nine current artworks are approved; eight replacements are integrated. General furniture staging remains provisional.</p></html>')

(OUT/'index.html').write_text('\n'.join(parts),encoding='utf-8')

print(OUT/'index.html')

