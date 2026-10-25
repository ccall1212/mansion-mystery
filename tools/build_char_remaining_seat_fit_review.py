"""Build native seat comparisons and explicit missing/disabled contact coverage."""
import hashlib
import html
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CONFIG = ROOT/'assets/characters/poses/char/remaining-seat-fit-review.json'
config = json.loads(CONFIG.read_text(encoding='utf-8'))
out = ROOT/'test-results/char-remaining-seat-fit'
esc = html.escape
parts = ['''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Char — dining, kitchen and upstairs seating</title>
<style>body{font:18px system-ui;background:#14232b;color:#e5edf0;margin:24px}a,h1,h2,h3{color:#edce98}img{max-width:1440px;width:100%;height:auto}article{margin:36px 0;border-top:1px solid #526773}button{font:inherit;padding:8px}nav{display:flex;gap:20px;flex-wrap:wrap}code{overflow-wrap:anywhere}.gap{color:#ffc4a5}</style>
<h1>Char — dining, kitchen and upstairs seating</h1><p>13 isolated comparisons using existing approved artwork. Four enabled contacts need seated-north artwork; six additional contacts are deliberately disabled. One character appears in each scene; the enlarged panel is the same placement.</p>
<p><b>Fit approval pending.</b> No character artwork changed, no automatic staging enabled. Scale remains 80 / 1673 for every pose. Candidate furniture masks can be toggled; furniture owns contact positions and shared masks.</p>
<p class="gap">Updated upstairs fits: window sill higher; west bench higher/left; study table seats adjusted with retraced masks; study armchair higher. The west-facing vanity seat is disabled. The angled bedroom east reading chair is excluded from seating for everyone. Kitchen stool remains a pose-fit candidate. General navigation/occupancy and packaged export are untested.</p>
<nav><a href="#g_dining">Dining</a><a href="#g_kitchen">Kitchen</a><a href="#u_master">Bedroom</a><a href="#u_study">Study</a><a href="#gaps">Missing / disabled</a></nav>''']
for room in ['g_dining','g_kitchen','u_master','u_study']:
    parts.append(f'<h2 id="{room}">{room}</h2>')
    for sample in [s for s in config['samples'] if s['room_id']==room and s['status']=='preview_candidate']:
        assert hashlib.sha256((ROOT/sample['asset']).read_bytes()).hexdigest()==sample['asset_sha256']
        sample['captures']={}
        for mode in ['raw','masked']:
            path=out/(sample['id']+'-'+mode+'.png')
            sample['captures'][mode]={'path':path.relative_to(ROOT).as_posix(),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
        sample['captures_status']='current_native_capture'
        id=sample['id']
        parts.append(f'<article id="{id}"><h3>{esc(sample["label"])}</h3><p><code>{sample["contact_id"]}</code><br>Pose: {sample["pose_id"]}; actor faces {sample["actor_facing"]}.</p><p>{esc(sample["notes"])}</p>')
        if sample['foreground_polygons']:
            parts.append(f'''<button onclick="document.getElementById('img-{id}').src='{id}-raw.png'">Raw / masks off</button> <button onclick="document.getElementById('img-{id}').src='{id}-masked.png'">Candidate furniture mask</button>''')
        else:
            parts.append('<p>No foreground mask applied.</p>')
        mode='masked' if sample['foreground_polygons'] else 'raw'
        parts.append(f'<img id="img-{id}" src="{id}-{mode}.png" alt="{esc(sample["label"])} fit candidate"></article>')
parts.append('<h2 id="gaps">Missing or deliberately disabled contacts</h2><ul>')
for sample in config['samples']:
    if sample['status']=='preview_candidate':continue
    reason='Needs seated_idle_north; no mirrored substitute.' if sample['status']=='missing_seated_north_artwork' else sample.get('disabled_reason','Disabled in current furniture metadata; bed/mattress calibration or separate chair contact must be used.')
    parts.append(f'<li><code>{sample["contact_id"]}</code>: {esc(reason)}</li>')
parts.append('</ul><p>Next art planning: Char’s directional personality gestures, holding/reading books, emotions and mystery reactions. Randomized NPC staging is deferred until the character pose sets are complete.</p></html>')
(out/'index.html').write_text('\n'.join(parts),encoding='utf-8')
CONFIG.write_text(json.dumps(config,indent=2)+'\n',encoding='utf-8')
print(out/'index.html')
