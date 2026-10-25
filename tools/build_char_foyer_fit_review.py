"""Publish two isolated seat-fit previews; approval remains an explicit user step."""
import hashlib
import html
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONFIG = ROOT/'assets/characters/poses/char/foyer-fit-review.json'
config = json.loads(CONFIG.read_text(encoding='utf-8'))
out = ROOT/'test-results/char-foyer-fit'
parts = ['''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Foyer shared seating calibration — Char</title><style>body{font:18px system-ui;background:#14232b;color:#e5edf0;margin:24px}a,h1,h2{color:#edce98}img{max-width:1440px;width:100%;height:auto}article{margin:36px 0}code{overflow-wrap:anywhere}</style>
<h1>Foyer shared seating calibration</h1><p>Char demonstrates two reusable furniture anchors at the shared 80-unit adult scale. Each image contains an overview and enlarged detail of one placement. Existing character artwork is unchanged.</p>
<p>The furniture owns the seat position, facing and foreground mask. Future characters reuse these through their pose landmarks and shared stature rules; they do not receive separate chair coordinates. Unusual builds, clothing or poses may need a compatibility exception.</p>
<p><b>Visual fits approved (2026-10-24: “1 is approved”).</b> These contacts are disabled for automatic staging. No foreground mask is applied. Check seat height, arm overlap, skirt and shoes. No new artwork was generated.</p>''']
for sample in config['samples']:
    path = out/(sample['id']+'-raw.png')
    sample['captures'] = {'raw': {'path':path.relative_to(ROOT).as_posix(), 'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}}
    assert hashlib.sha256((ROOT/sample['asset']).read_bytes()).hexdigest() == sample['asset_sha256']
    parts.append(f'<article id="{sample["id"]}"><h2>{html.escape(sample["label"])}</h2><p><code>{sample["contact_id"]}</code> — {sample["pose_id"]}</p><img src="{sample["id"]}-raw.png" alt="Char fit at {html.escape(sample["label"])}"></article>')
parts.append('<p>Visual fit approval is recorded. Runtime staging is deferred until character pose sets are complete. This preview does not establish compatibility with every body shape or pose.</p></html>')
(out/'index.html').write_text('\n'.join(parts),encoding='utf-8')
CONFIG.write_text(json.dumps(config,indent=2)+'\n',encoding='utf-8')
print(out/'index.html')
