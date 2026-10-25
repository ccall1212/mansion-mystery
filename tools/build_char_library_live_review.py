"""Publish native captures and controls for the isolated Char library test."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
fit=json.loads((ROOT/'assets/characters/poses/char/library-fit-review.json').read_text())
out=ROOT/'test-results/char-library-live'
parts=['''<!doctype html><html lang="en"><meta charset="utf-8"><title>Char library — live test</title><style>body{background:#14232b;color:#e5edf0;font:18px system-ui;margin:24px}h1,h2,a{color:#edce98}img{max-width:100%;height:auto}article{margin-top:32px;border-top:1px solid #536773}</style><h1>Char library — live test</h1><p>The separate Godot test window lets you walk around the approved library and cycle through four approved seating fits.</p><p><strong>F8</strong> next seat · <strong>F7</strong> focus Char · <strong>WASD / arrows</strong> walk · <strong>Z</strong> overview · <strong>F6</strong> furniture IDs · <strong>F10</strong> return to the main game.</p><p>Exactly one Char. Saving and case start are disabled. These four screenshots show separate test states. East/south door travel, other rooms and full furniture depth/occlusion remain integration work; this is an isolated library test, not the rebuilt mansion.</p><p>Reopen with <code>python tools/open_char_library_live.py</code> from the project folder.</p><p><a href="../char-library-fit/index.html">Approved contact and mask review</a></p>''']
for sample in fit['samples']:
    path=out/(sample['id']+'.png');assert path.exists()
    parts.append(f'<article><h2>{sample["label"]}</h2><p>{sample["contact_id"]}</p><img src="{path.name}" alt="Char live library test: {sample["label"]}"></article>')
(out/'index.html').write_text('\n'.join(parts)+'</html>',encoding='utf-8')
print(out/'index.html')
