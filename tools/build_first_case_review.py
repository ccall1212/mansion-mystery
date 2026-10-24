"""Build the human-facing review from actual Godot captures; no asset processing."""
from pathlib import Path
import html

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'test-results/first-case'
entries = [('seated_idle_east', 'Char — kitchen chair, facing east'),
           ('seated_idle_south', 'Char — library armchair, facing south'),
           ('seated_idle_west', 'Char — foyer armchair, facing west'),
           ('briefing', 'First case — briefing'), ('questioning_char', 'Questioning a suspect'),
           ('floor_clue', 'Room-owned observation'), ('clue_book', 'Statements in the clue book'),
           ('accusation', 'Accusation screen')]
parts = ['''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Sleuth — chairs and first playable case</title><style>body{font:18px system-ui;background:#17242b;color:#e1e9eb;margin:28px;max-width:1280px}a,h1,h2{color:#edce98}img{width:100%;image-rendering:pixelated}article{margin:36px 0}button{font:inherit;padding:8px}.native img{width:auto;max-width:none}summary{cursor:pointer}</style>
<h1>Char's chairs and the first playable case</h1>
<p>Actual Godot captures. Chair offsets and foreground arms are a review draft. Approved character artwork and shared stature are unchanged. Crowding actors were hidden only for these chair captures.</p>
<p>In the game: <b>F4</b> opens the case board; choose <b>Begin the first case</b>. <b>E</b> examines/questions, <b>C</b> collects, <b>M</b> uses the lens, <b>N</b> opens notes, <b>TAB</b> shows routes. <b>F5/F9</b> save/load; <b>F11</b> fullscreen. Start in the foyer. The case uses the ground floor; other floors remain accessible.</p>
<p>One authored mystery, three suspects, a library floor observation, evidence gating, accusation and resolution. Wrong accusations allow retries for this prototype. Final group staging, reveal animation and randomized mysteries are future work.</p>
<button onclick="document.body.classList.toggle('native')">Native pixels / fit to panel</button>
<p><a href="checks.json">Focused integration checks</a></p>''']
for stem, title in entries:
    assert (OUT/(stem+'.png')).is_file(), stem
    parts.append(f'<article><h2>{html.escape(title)}</h2><img src="{stem}.png" alt="{html.escape(title)}"></article>')
parts.append('<details><summary>Show ending screenshot — contains solution spoilers</summary><img src="ending.png" alt="First-case ending"></details></html>')
(OUT/'index.html').write_text('\n'.join(parts), encoding='utf-8')
print(OUT/'index.html')
