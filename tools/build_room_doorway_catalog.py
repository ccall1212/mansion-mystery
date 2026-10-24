"""Seed explicit reviewed doorway metadata. Never infer usable exits from filenames.

Existing catalog entries are preserved so manual review is not overwritten.
"""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT/'assets/rooms/doorway-catalog.json'
manifest = json.loads((ROOT/'assets/rooms/room-manifest.json').read_text())
directions = ['north','east','south','west']
# Background-local 480x320 approximate centers. Markers are review labels,
# not collider/trigger coordinates. Shelf-filled arches are deliberately absent.
observed = {
 'foyer': [('north',240,118,'locked_front'),('south',240,304,'threshold')],
 'guest-bedroom': [('east',462,182,'door'),('south',240,306,'threshold')],
 'guest-bedroom-alternate': [('west',10,205,'opening_needs_review'),('east',462,261,'door')],
 'firelit-entry': [('west',16,185,'door'),('east',464,183,'door'),('south',46,308,'threshold')],
 'firelit-entry-alternate': [('north',83,96,'door'),('east',462,186,'door'),('south',82,306,'threshold')],
 'grand-hall': [('north',240,105,'door'),('east',462,172,'door'),('south',240,306,'threshold'),('west',17,172,'door')],
 'grand-hall-alternate': [('east',463,159,'door'),('south',71,306,'threshold'),('west',15,158,'door')],
 'torchlit-stone': [('north',390,111,'door'),('west',17,181,'door')],
 'torchlit-stone-alternate': [('north',420,110,'door'),('west',16,169,'door')],
 'library': [('east',462,169,'door'),('west',18,169,'door')],
 'library-alternate': [('north',429,86,'door'),('south',236,305,'threshold'),('west',17,177,'door')],
 'reception-hall': [('east',462,178,'door'),('south',241,305,'threshold')],
 'reception-hall-alternate': [('east',462,170,'door'),('south',406,305,'threshold'),('west',17,170,'door')],
 'night-exterior': [('north',279,176,'exterior_front')],
 'night-exterior-alternate': [('north',86,162,'exterior_service')],
 'cold-statue-hall': [('east',464,177,'door'),('south',239,305,'threshold'),('west',16,177,'door')],
 'cold-statue-hall-alternate': [('east',463,185,'door'),('south',238,305,'threshold'),('west',17,185,'door')],
 'dark-stairwell': [('north',105,38,'balcony_door'),('south',240,305,'threshold'),('west',19,177,'door')],
 'dark-stairwell-basement': [('south',81,306,'threshold'),('west',18,165,'door')],
}
rework = {
 'g_foyer': ('connection_review','Resolve bent vestibule; keep north front entrance locked.',{'north':1,'east':0,'south':1,'west':0}),
 'g_main_stair': ('user_looks_alright','Keep current appearance. Balcony door is visible but not an active route; stair flight is separate.',{'north':1,'east':0,'south':1,'west':1}),
 'g_library': ('rework_required','Remove window obstruction and clustered stool/chair/bookcase. Separate accessible chair, shelves and desk.',{'north':0,'east':1,'south':0,'west':1}),
 'g_dining': ('rework_required','Add dining table and usable chairs; remove unused south exit.',{'north':0,'east':1,'south':0,'west':1}),
 'g_kitchen': ('rework_required','Create a real kitchen. Retain current bar reference for later bar room with counter-facing usable stools.',{'north':0,'east':1,'south':1,'west':0}),
 'u_main_stair': ('rework_required','South/bottom arrival facing north; carpet branches west and east. Remove unused north door.',{'north':0,'east':1,'south':1,'west':1}),
 'u_master': ('rework_required','Remove unused left opening and improve lower floor composition; bathroom is a future alternative.',{'north':0,'east':1,'south':0,'west':0}),
 'u_study': ('rework_required','Remove unused north and south openings; preserve west landing connection.',{'north':0,'east':0,'south':0,'west':1}),
 'b_store': ('rework_required','Remove unused west door. Add shelves, crates, trunks and barrels with clear aisles and inspection access.',{'north':1,'east':0,'south':0,'west':0}),
}
house = json.loads((ROOT/'assets/mansion/fixed-mansion.json').read_text())
entries = json.loads(PATH.read_text()).get('backgrounds',{}) if PATH.exists() else {}
assets = [('foyer','res://assets/foyer/foyer-background.png',[])]
assets += [(v['id'],v['asset'],v.get('entrance_directions',[])) for room in manifest['rooms'] for v in room['variants']]
for identity,asset,legacy in assets:
    if asset in entries:
        continue
    doors = [{'id':f'door_{side}_{i+1:02d}','side':side,'position':[x,y],'kind':kind,'position_status':'visual_estimate'}
             for i,(side,x,y,kind) in enumerate(observed[identity])]
    counts = {side:sum(d['side']==side for d in doors) for side in directions}
    path = ROOT/asset.removeprefix('res://')
    active = [key for key,room in house['rooms'].items() if room['asset']==asset]
    entry = {'background_id':identity,'asset':asset,'source_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),
        'coordinate_space':'background_local','coordinate_size':[480,320],
        'door_count':len(doors),'door_counts':counts,'door_signature':'_'.join(side[0].upper()+str(counts[side]) for side in directions),
        'doors':doors,'stair_flights':[],'paths':[],
        'count_status':'manual_visual_inventory_pending_user_confirmation',
        'legacy_entrance_labels':legacy,'active_rooms':active}
    if identity == 'dark-stairwell': entry['stair_flights']=[{'id':'main_ascent','side':'east','position':[370,166],'travel':'up'}]
    if identity == 'dark-stairwell-basement': entry['stair_flights']=[{'id':'basement_descent','side':'east','position':[370,250],'travel':'down'}]
    if identity.startswith('night-exterior'): entry['paths']=[{'side':'south','kind':'exterior_path'},{'side':'east','kind':'garden_path'}]
    for key in active:
        status,note,target = rework[key]
        entry['room_reviews'] = {key:{'status':status,'user_notes':note,'target_door_counts':target,'target_door_count':sum(target.values())}}
    entries[asset]=entry
catalog = {'schema_version':1,'directions':directions,
    'door_definition':'One door assembly/opening/threshold; double leaves count once. Stairs and exterior paths are separate. Screen-side is wall placement, not traversal direction.',
    'source_basis':'Existing images and contact sheets, user room review; positions are approximate. Counts need visual confirmation, not runtime topology authority.',
    'backgrounds':entries}
PATH.write_text(json.dumps(catalog,indent=2)+'\n',encoding='utf-8')
print(f'Doorway catalog: {len(entries)} backgrounds')
