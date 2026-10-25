"""Human-readable active-room, connection and deferred-art review."""
import html
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'test-results/compact-mansion'
data = json.loads((ROOT/'assets/mansion/fixed-mansion.json').read_text())
rooms = data['rooms']
door_catalog = json.loads((ROOT/'assets/rooms/doorway-catalog.json').read_text())['backgrounds']
esc = html.escape
parts = ['''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Sleuth — compact mansion room review</title>
<style>body{background:#17242b;color:#e1e9eb;font:18px system-ui;margin:28px;max-width:1280px}a,h1,h2,h3{color:#edce98}img{width:100%;image-rendering:pixelated}table{border-collapse:collapse;width:100%}td,th{padding:10px;border:1px solid #52626b;text-align:left}article{margin:40px 0}.gap{color:#ffc4a5}nav{display:flex;gap:16px;flex-wrap:wrap}li{margin:8px 0}</style>
<h1>Compact mansion — room and connection review</h1>
<p><b>Seven main rooms:</b> four ground-floor, two upstairs, one basement. Two circulation screens bring the playable total to nine. Every active background is unique. Unused room assets and furniture tags are retained for expansion.</p>
<p>These are actual current-engine overview captures. Door markers identify active routes. Painted openings without markers are not active exits. This is a compact traversal layout, not a finished architectural floor plan.</p>
<h2>Routes</h2><p>Foyer ↔ Main Stair Hall ↔ Library ↔ Dining Room ↔ Kitchen ↔ Basement Storage<br>Main Stair Hall ↔ Upstairs Landing ↔ Bedroom / Study</p>
<p class="gap">Eight approved room revisions are now integrated with updated collision and reciprocal door/stair endpoints. The foyer remains unchanged and the bar is reserved for future expansion. The library south-to-dining east link is a turning passage; the foyer vestibule and basement service stair also run offscreen.</p>
<p>Future top-of-screen map: current floor, highlighted current room and main-room count, generated from this same room graph. Not implemented yet; TAB remains the directory.</p>''']
for floor, name in [(0,'Ground floor'),(1,'Upstairs'),(-1,'Basement')]:
    active = [(key,room) for key,room in rooms.items() if room['floor'] == floor]
    count = sum(room['role'] == 'room' for _,room in active)
    parts.append(f'<h2>{name}: {count} main rooms, {len(active)-count} circulation spaces</h2><nav>')
    parts.extend(f'<a href="#{key}">{esc(room["name"])}</a>' for key,room in active)
    parts.append('</nav>')
    for key,room in active:
        assert (OUT/(key+'.png')).is_file(), key
        parts.append(f'<article id="{key}"><h3>{esc(room["name"])} — {key}</h3><img src="{key}.png" alt="{esc(room["name"])} overview"><p>{esc(room["asset"])}</p>')
        entry = door_catalog[room['asset']]
        review = entry['room_reviews'][key]
        badges = ' · '.join(side.upper()+': '+str(entry['door_counts'][side]) for side in ['north','east','south','west'])
        targets = ' · '.join(side.upper()+': '+str(review['target_door_counts'][side]) for side in ['north','east','south','west'])
        parts.append(f'<p><b>PAINTED OPENINGS: {entry["door_count"]}</b> — {badges}<br><b>REPLACEMENT TARGET: {review["target_door_count"]}</b> — {targets}<br>Active routes: {len(room["portals"])} (stairs counted separately from painted doors).</p>')
        parts.append(f'<p class="gap"><b>{esc(review["status"].replace("_"," ").upper())}</b> — {esc(review["user_notes"])}</p>')
        parts.append('<p>Door labels are visual estimates pending your confirmation. N is top/back wall, E right, S bottom, W left. A northern door can sit on the right half of the back wall.</p>')
        # Review-only code overlay. Source artwork is never labeled or overwritten.
        parts.append('<div style="position:relative"><img src="../../'+esc(room['asset'].removeprefix('res://'))+'" alt="'+esc(room['name'])+' clean background with door labels"><svg viewBox="0 0 480 320" style="position:absolute;inset:0;width:100%;height:100%;pointer-events:none" aria-label="Door direction overlay">')
        for door in entry['doors']:
            x,y=door['position']; side=door['side'].upper()
            label_x=max(4,min(400,x-36)); label_y=max(15,min(301,y))
            parts.append(f'<circle cx="{x}" cy="{y}" r="5" fill="#f0ba6a" stroke="#14232b"/><rect x="{label_x}" y="{label_y-14}" width="76" height="15" fill="#14232b"/><text x="{label_x+3}" y="{label_y-3}" fill="#ffe4ad" font-size="10">{side} DOOR</text>')
        for flight in entry['stair_flights']:
            x,y=flight['position']
            parts.append(f'<text x="{x-38}" y="{y}" fill="#90edec" stroke="#14232b" paint-order="stroke" stroke-width="2" font-size="11">STAIRS {flight["travel"].upper()}</text>')
        parts.append('</svg></div>')
        if room['art_note']:
            parts.append(f'<p class="gap">{esc(room["art_note"])}</p>')
        parts.append('<table><tr><th>Destination</th><th>Type</th><th>Exit position → arrival position</th><th>Art note</th></tr>')
        for p in room['portals']:
            parts.append(f'<tr><td><a href="#{p["target"]}">{esc(rooms[p["target"]]["name"])}</a></td><td>{p["kind"]}</td><td>{p["at"]} → {p["arrival"]}</td><td>{esc(p["passage_note"])}</td></tr>')
        parts.append('</table></article>')
parts.append('<h2>Removed from the playable route, retained for later</h2><ul>')
for key,room in data['deferred_rooms'].items():
    duplicate = [r['name'] for r in rooms.values() if r['asset'] == room['asset']]
    reason = 'Shared the active '+', '.join(duplicate)+' background.' if duplicate else 'Deferred to keep the first house small.'
    parts.append(f'<li>{esc(room["name"])} ({key}) — {esc(reason)}</li>')
parts.append('</ul><h2>All background doorway labels, including inactive variants</h2><p>Painted openings only; stair flights and outdoor paths are separate. Counts are provisional visual tags, not route authorization.</p><table><tr><th>Background</th><th>Doors</th><th>NORTH</th><th>EAST</th><th>SOUTH</th><th>WEST</th><th>Flights</th></tr>')
for entry in door_catalog.values():
    count=entry['door_counts']
    parts.append(f'<tr><td>{esc(entry["background_id"])}</td><td>{entry["door_count"]}</td><td>{count["north"]}</td><td>{count["east"]}</td><td>{count["south"]}</td><td>{count["west"]}</td><td>{len(entry["stair_flights"])}</td></tr>')
parts.append('</table><p><a href="../../assets/rooms/doorway-catalog.json">Machine-readable doorway catalog</a> · <a href="../../docs/ROOM_ART_REWORK.md">Full rework brief</a></p><p>Older mansion saves are retained but do not load into layout compact-2. Start a fresh case; F5 saves it explicitly.</p></html>')
(OUT/'index.html').write_text('\n'.join(parts),encoding='utf-8')
print(OUT/'index.html')
