"""Build an inspectable gallery and exact Char compatibility list for revised rooms."""
import html
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'test-results/reworked-furniture'
inventory=json.loads((OUT/'inventory.json').read_text())
batch=json.loads((ROOT/'assets/characters/poses/char/batches/alignment_01.json').read_text())
available={j['pose_id'] for j in batch['jobs'] if j.get('approval')=='approved'}
catalog=json.loads((ROOT/'assets/furniture/catalog.json').read_text())
esc=html.escape
parts=['''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Reworked mansion — furniture IDs</title>
<style>body{font:17px system-ui;background:#14232b;color:#e5edf0;margin:24px}a,h1,h2{color:#edce98}nav{display:flex;gap:16px;flex-wrap:wrap}img{max-width:100%;height:auto}article{border-top:1px solid #526773;margin-top:36px}td,th{padding:8px;border-bottom:1px solid #526773;text-align:left}table{border-collapse:collapse}details{overflow:auto}code{color:#f0d6a7}</style>
<h1>New mansion backgrounds — furniture IDs</h1><p>Nine selected artworks, 126 manually traced object tags. These annotations open in the existing furniture mapper. Orange = contact, cyan = approach, white = actor facing.</p>
<p><strong>All placement remains provisional.</strong> Bounds and contacts are visual estimates. Seat size, Char fit, masks, path clearance and occupancy still need calibration. The runtime mansion now uses eight approved revised backgrounds with updated routes. These tags remain provisional; the future bar is only an authoring concept.</p>
<p>Char has approved seated east, south and west samples. Seated north, stool-specific leg alignment and action variants require further work; an available sprite is not a fit approval.</p><nav>''']
for room in inventory:parts.append(f'<a href="#{room["room"]}">{room["room"]}</a>')
parts.append('</nav>')
contacts=[]
for room in inventory:
    layout=json.loads((ROOT/room['layout'].removeprefix('res://')).read_text())
    assert (OUT/(room['room']+'.png')).exists()
    parts.append(f'<article id="{room["room"]}"><h2>{room["room"]} — {room["tags"]} tags</h2><p><a href="{room["room"]}.png">Open full-size tagged screenshot</a> · <a href="../../{room["layout"].removeprefix("res://")}">Exact layout JSON</a></p><img src="{room["room"]}.png" alt="{room["room"]} furniture IDs and draft contacts"><details><summary>Exact interaction IDs, directions and Char pose coverage</summary><table><tr><th>Furniture/contact ID</th><th>Orientation ID</th><th>Actor faces</th><th>Pose requirements</th><th>Status</th></tr>')
    for item in layout['instances']:
        kind=catalog['variants'][item['variant_id']]['type']
        for anchor in item['anchors']:
            enabled=anchor.get('enabled',True)
            direction=anchor.get('actor_facing')
            alignment=anchor['body_axis']+'_head_'+anchor['head_toward'] if anchor['posture']=='lying' else direction
            poses=[anchor['posture']+'_'+action+'_'+alignment for action in anchor['activities']] if enabled else []
            key=room['room']+'::'+item['id']+'::'+anchor['id']
            coverage={p:('approved_sample_fit_pending' if p in available else 'missing_art_or_unmapped_action') for p in poses}
            if kind=='bar_stool':coverage={p:'stool_specific_fit_and_leg_pose_required' for p in poses}
            row=dict(contact_id=key,layout=room['layout'],orientation_id=item['variant_id'],actor_facing=direction,
                     posture=anchor['posture'],contact_kind=anchor['contact_kind'],contact=anchor['contact'],approach=anchor['approach'],
                     target_instance_id=item.get('target_instance_id',''),enabled=enabled,ready_for_staging=False,
                     pose_coverage=coverage,body_axis=anchor.get('body_axis'),head_toward=anchor.get('head_toward'))
            contacts.append(row)
            cells=[key,item['variant_id'],direction or alignment,', '.join(poses),'; '.join(sorted(set(coverage.values()))) if enabled else 'disabled']
            parts.append('<tr>'+''.join('<td>'+esc(value)+'</td>' for value in cells)+'</tr>')
    parts.append('</table></details></article>')
parts.append('</html>')
(OUT/'index.html').write_text('\n'.join(parts),encoding='utf-8')
mapping=ROOT/'assets/furniture/reworked-room-pose-contacts.json'
mapping.write_text(json.dumps(dict(schema_version=1,status='provisional_not_runtime_staging',character='char',
                                  source='registered reworked room layouts; alignment_01 approved artwork',contacts=contacts),indent=2)+'\n')
print(f'{len(inventory)} screenshots; {len(contacts)} exact contacts mapped; gallery: {OUT / "index.html"}')
