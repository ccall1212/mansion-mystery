"""Build room screenshot index and Char's pose plan from actual Godot coverage."""
import html
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
report=json.loads((ROOT/'test-results/tagged-room-coverage.json').read_text())
assert report['ok'] and len(report['rooms'])==18
registry=json.loads((ROOT/'assets/furniture/backgrounds.json').read_text())
layouts=[json.loads((ROOT/p.removeprefix('res://')).read_text()) for p in registry['backgrounds'].values()]
unique_count=sum(len(layout['instances']) for layout in layouts)
room_count=sum(room['tags'] for room in report['rooms'])
clear_count=sum(c['approach_clear'] for r in report['rooms'] for c in r['contacts'])
contact_count=sum(len(r['contacts']) for r in report['rooms'])
output=ROOT/'assets/furniture/review/all-rooms'
assert all((output/(r['id']+'.png')).exists() for r in report['rooms'])

lines=['# Tagged mansion room screenshots','',
 f'All 18 playable rooms are covered: {len(layouts)} background layouts, {unique_count} unique painted-object tags and {room_count} room-scoped object instances.', '',
 'Each screenshot uses the actual room renderer, including separate runtime props. Gold rectangles and numbers identify objects; the right-hand legend lists instance and orientation IDs. Orange is the character contact landmark; cyan is the approach point. These are **draft contacts**, not approved NPC placements.', '',
 f'The current collision check finds a clear approach footprint for {clear_count} of {contact_count} enabled room contacts. This is a local clearance check, **not pathfinding**, pose fitting or occupancy validation. Other contacts need navigation/contact calibration; all staging-review flags remain false.', '',
 'Portable evidence props keep their separate evidence IDs. Doorway tags describe visible openings; mansion portal data still controls actual travel. Repeated backgrounds are explicitly identified. The kitchen, dining room and washroom retain their provisional dressing.', '',
 '[Char pose checklist](CHAR_POSE_PLAN.md) · [Clickable image gallery](../assets/furniture/review/all-rooms/index.html)', '']
gallery=['<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Sleuth — tagged rooms</title>',
 '<style>body{margin:24px;background:#17242b;color:#e4e9ea;font:17px system-ui}h1,h2{color:#e4c68d}a{color:#e4c68d}nav{display:flex;gap:16px;flex-wrap:wrap}article{margin:32px 0}img{width:100%;height:auto;max-width:1440px;border:1px solid #44535c}p{max-width:1000px}</style>',
 '<h1>Sleuth — all 18 tagged rooms</h1><p>Draft contact review. Open any screenshot for full resolution. Gold: object IDs; orange: contact; cyan: approach. Navigation, pose alignment and foreground overlap remain to be calibrated. Shared backgrounds are named in each screenshot.</p>',
 '<nav>'+''.join(f'<a href="#{r["id"]}">{html.escape(r["name"])}</a>' for r in report['rooms'])+'</nav>']
for floor,title in [(0,'Ground floor'),(1,'Upper floor'),(-1,'Basement')]:
    lines += ['## '+title,'',f'![{title} — six tagged rooms](../assets/furniture/review/all-rooms/floor_{floor}.png)','']
    for room in [r for r in report['rooms'] if r['floor']==floor]:
        asset=Path(room['asset']).name
        others=[r['name'] for r in report['rooms'] if r['asset']==room['asset']]
        lines += [f'### {room["name"]} — `{room["id"]}`','',f'{room["tags"]} tags. Background: `{asset}`. Used by: {", ".join(others)}.','',
                  f'[Open full-size screenshot](../assets/furniture/review/all-rooms/{room["id"]}.png)','',
                  f'![{room["name"]} furniture tags](../assets/furniture/review/all-rooms/{room["id"]}.png)','']
        gallery += [f'<article id="{room["id"]}"><h2>{html.escape(room["name"])} — {room["tags"]} tags</h2><p>Draft contacts: orange position; pale arrow actor facing; purple line gaze target. All new side contacts require visual review.</p><a href="{room["id"]}.png"><img loading="lazy" alt="{html.escape(room["name"])} furniture tags" src="{room["id"]}.png"></a>']
        gallery.append('<details><summary>Exact contact IDs, directions and local approach checks</summary><table><tr><th>Contact</th><th>Furniture orientation</th><th>Actor faces</th><th>Side</th><th>Approach</th><th>Required poses</th></tr>')
        for contact in room['contacts']:
            values=[contact['key'],contact.get('orientation_id',''),str(contact.get('actor_facing') or 'axis/head'),str(contact.get('interaction_side') or 'front/original'),'locally clear; unapproved' if contact['approach_clear'] else 'blocked; unapproved',', '.join(contact['pose_ids'])]
            gallery.append('<tr>'+''.join('<td style="padding:8px;border-bottom:1px solid #44535c">'+html.escape(v)+'</td>' for v in values)+'</tr>')
        gallery.append('</table></details></article>')
(ROOT/'docs/TAGGED_ROOM_SCREENSHOTS.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
(output/'index.html').write_text('\n'.join(gallery)+'</html>',encoding='utf-8')

starter=['standing_idle_north','standing_idle_east','standing_idle_south','standing_idle_west',
         'seated_idle_east','seated_idle_south','seated_idle_west']
requirements=report['pose_requirements']
poses=[]
for pose in sorted(set(requirements)|set(starter)):
    poses.append(dict(id=pose,status='planned',phase=1 if pose in starter else 2,
        contacts=requirements.get(pose,[]),
        notes='Base facing pose also supports conversation planning.' if pose in starter else 'Required action/facing; artwork reuse must be reviewed, not assumed.'))
plan=dict(schema_version=1,character_id='char',cast_number='01',name='Char',status='original_furniture_requirement_subset',
    scope='original furniture-only subset; not the full action/reaction audit',
    full_pose_audit='res://assets/characters/poses/pose-requirements.json',
    production_manifest='res://assets/characters/poses/char/production-manifest.json',
    identity_reference='res://assets/characters/prototype/cast-01.png',
    preserve=['cream high-collar blouse','teal-green long skirt','burgundy sash','cream hair ribbon','long brown wavy hair','approved face and adult proportions'],
    contact_contract={'standing':'feet','seated':'seat','kneeling':'knees','lying':'pelvis; north-south body axis, head north'},
    animation_scope='Walking animation is handled separately; no animation generation is authorized by this room-tagging task.',
    poses=poses)
(ROOT/'assets/characters/char-pose-plan.json').write_text(json.dumps(plan,indent=2)+'\n',encoding='utf-8')
text=['# Char — first complete furniture pose plan','',
 'This is the original furniture-only subset (42 IDs). The full source-linked audit adds conversation coverage (45 concrete IDs) and semantic reaction/event families. See [the full audit](CHARACTER_POSE_AUDIT.md), [master pose matrix](pose-audit/MASTER_POSE_MATRIX.md), [workflow](CHARACTER_POSE_PRODUCTION_WORKFLOW.md) and [reusable production prompt](CHARACTER_POSE_PRODUCTION_PROMPT.md). The current production record is `assets/characters/poses/char/production-manifest.json`.', '',
 'This is the original furniture requirement subset. Current generation/approval progress lives in the production manifest and [alignment review](CHAR_ALIGNMENT_01_REVIEW.md); do not interpret these requirement rows as missing or approved art automatically.', '',
 'Char is cast #01: the approved cream blouse, teal-green long skirt, burgundy sash, cream ribbon and long brown wavy hair. Preserve her face, adult anatomy and established pixel-art detail. Use the approved design reference recorded in her production manifest; the existing character art standard remains authoritative.', '',
 '## Start with seven alignment samples','',
 'Four standing facings (north/east/south/west) and three seated facings (east/south/west). The tagged furniture currently does not require seated north. Approve these proportions and contact landmarks before producing action variants. These are static pose samples; walking animation remains a separate task.', '',
 'Fit the seated-west sample to the foyer armchair, seated-south to the library chair, and seated-east to the kitchen chairs. Fit tests must check the actual chair surface, feet, skirt volume and which furniture pixels cover the character. A clear approach is not proof that a pose fits.', '',
 '## Full action coverage','',
 f'The enabled furniture contacts request **{len(requirements)} distinct action/direction combinations**. Adding the east/west standing base samples gives **{len(poses)} planned pose requirements**. These are requirements, not necessarily one unique image per ID: compatible actions may share an approved base drawing. No mirroring or art reuse is assumed safe.', '',
 '| Pose requirement | Room contacts | Clear approach footprints | Phase |', '| --- | ---: | ---: | --- |']
for pose in poses:
    contacts=pose['contacts']
    text.append(f'| `{pose["id"]}` | {len(contacts)} | {sum(c["approach_clear"] for c in contacts)} | {pose["phase"]} |')
text += ['', 'Phase 2 adds reading/talking/writing, looking outside/upward, inspecting/reaching, listening/peeking, warming hands, kneeling and lying. Produce these in small review batches after the seven alignment samples.', '',
 '## Integration contract','',
 '- Store a pose-specific contact landmark: feet, seat, knees or pelvis. Place that landmark on the furniture contact; do not snap every sprite’s bottom edge to a chair seat.',
 '- Standing actor facing is separate from furniture facing. Lying uses the bed axis and headboard direction.',
 '- Keep the shared adult rendering scale. Do not resize or stretch Char independently to fit each piece of furniture.',
 '- Respect disabled contacts, draft status, occupancy and movement clearance. The master-bedroom vanity and its chair share the `master_vanity` occupancy group; this is metadata for future staging, not implemented automatic occupancy.',
 '- Supply appropriate foreground masks/layers before hiding skirt/legs behind a desk or bed. Existing baked room art does not automatically provide occlusion.',
 '- The machine-readable plan lists every exact room/object/contact source and its current local-clearance result: `assets/characters/char-pose-plan.json`.', '',
 '[Review all tagged rooms first](TAGGED_ROOM_SCREENSHOTS.md). Character looks and pose batches must be shown to the user before finalization.']
(ROOT/'docs/CHAR_POSE_PLAN.md').write_text('\n'.join(text)+'\n',encoding='utf-8')
print(f'Review: {unique_count} unique tags / {room_count} room tags / {len(poses)} Char requirements')
