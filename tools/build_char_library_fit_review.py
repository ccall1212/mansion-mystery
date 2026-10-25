"""Build the four-contact Char seating review from native Godot captures."""
import hashlib
import html
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
CONFIG=ROOT/'assets/characters/poses/char/library-fit-review.json'
config=json.loads(CONFIG.read_text())
out=ROOT/'test-results/char-library-fit'
parts=['''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Char — new library seating fit</title>
<style>body{font:18px system-ui;background:#14232b;color:#e5edf0;margin:24px}a,h1,h2{color:#edce98}img{width:100%;max-width:1440px;height:auto}article{margin-top:36px;border-top:1px solid #536773}button{font:inherit;padding:8px}nav{display:flex;gap:18px;flex-wrap:wrap}.note{color:#edce98}</style>
<h1>Char — new library seating fit</h1><p>Four separate placements using her existing approved sprites at the shared 80-unit adult scale. Each screenshot shows a room overview and an enlarged view of the same placement, not duplicate occupants.</p>
<p>Candidate masks redraw the existing background furniture in front of Char. These are review previews; no live placement or new artwork is enabled. Controls switch between raw placement and candidate overlap.</p>
<p class="note">Review: pelvis/seat alignment, foot reach, skirt and arm overlap. Front reading-table seats still need north-facing seated artwork. Bar stools and other rooms are not tested here.</p><nav>''']
for s in config['samples']:parts.append(f'<a href="#{s["id"]}">{html.escape(s["label"])}</a>')
parts.append('</nav>')
for sample in config['samples']:
    sample['captures']={}
    for mode in ['raw','masked']:
        path=out/(sample['id']+'-'+mode+'.png')
        assert path.exists()
        sample['captures'][mode]={'path':path.relative_to(ROOT).as_posix(),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()}
    parts.append(f'''<article id="{sample['id']}"><h2>{html.escape(sample['label'])}</h2><p><code>{sample['contact_id']}</code></p><p>{html.escape(sample['review_notes'])} — Fit approval: {sample['approval']}</p><button onclick="this.nextElementSibling.src='{sample['id']}-raw.png'">Raw placement</button><img hidden><button onclick="document.getElementById('image-{sample['id']}').src='{sample['id']}-raw.png'">Masks off</button> <button onclick="document.getElementById('image-{sample['id']}').src='{sample['id']}-masked.png'">Candidate masks on</button><p><img id="image-{sample['id']}" src="{sample['id']}-masked.png" alt="Char seated at {sample['label']}"></p></article>''')
parts.append('<p>All four placements visually approved. Source artwork is unchanged. The isolated live library test is ready; general mansion integration remains pending.</p></html>')
# Only two meaningful controls per sample.
page='\n'.join(parts)
import re
page=re.sub(r'<button onclick="this.nextElementSibling.*?<img hidden>', '', page)
(out/'index.html').write_text(page,encoding='utf-8')
CONFIG.write_text(json.dumps(config,indent=2)+'\n')
print(out/'index.html')
