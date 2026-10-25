"""One authored walking prototype. Source artwork is never modified."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
rooms = {}


def room(identity, name, floor, art, regions, obstacles=(), note=''):
    rooms[identity] = dict(id=identity, name=name, floor=floor,
        role='passage' if identity.endswith('_stair') else 'room',
        asset=f'res://assets/rooms/room-{art}.png' if art else 'res://assets/foyer/foyer-background.png',
        walk_regions=regions, obstacles=list(obstacles), portals=[],
        spawn=[240,280], art_note=note)


# Coordinates include the room's (0,24) rendering offset. Rectangles describe
# feet-level walk space, not the apparent height of painted furniture.
foyer_regions = [[16,160,448,171]]
foyer_blocks = [[0,316,209,44],[273,316,207,44],[166,155,148,24],
    [68,162,28,20],[17,160,49,18],[396,174,57,23],[339,184,14,8],[354,237,24,10]]
room('g_foyer','Foyer',0,None,foyer_regions,foyer_blocks)
stairs_regions = [[16,190,448,142],[18,165,294,40],[328,128,108,80]]
stairs_blocks = [[65,164,75,28],[252,180,47,33],[310,218,130,20]]
# The lower right stair footing stays clear in front of its painted riser.
stairs_blocks[-1] = [310,212,14,26]
room('g_main_stair','Main Stair Hall',0,'dark-stairwell',stairs_regions,stairs_blocks)
library_regions = [[16,121,448,211]]
library_blocks = [[49,104,68,86],[305,115,101,44],[0,226,148,72]]
room('g_library','Library',0,'library',library_regions,library_blocks)
salon_regions = [[16,143,448,189]]
salon_blocks = [[30,137,75,39],[389,137,63,43],[0,266,61,66],[358,292,24,40],[445,292,35,40]]
room('g_dining','Dining Room',0,'reception-hall-alternate',salon_regions,salon_blocks,
     'Reception-room placeholder; dining table and food-service furnishings need a later art pass.')
counter_regions = [[16,126,448,206]]
counter_blocks = [[0,123,247,46],[0,174,66,67],[159,290,34,42],[287,290,27,42]]
room('g_kitchen','Kitchen',0,'reception-hall',counter_regions,counter_blocks,
     'Existing counter-room placeholder; shelves/bar are not a finished kitchen.')
service_regions = [[16,153,448,179],[16,132,284,35]]
service_blocks = [[313,155,133,108]]
room('g_service_stair','Service Stair Hall',0,'dark-stairwell-basement',service_regions,service_blocks,
     'Descending flight is painted; the upper service flight uses a marked passage pending matching art.')

hall_regions = [[16,174,448,158],[213,151,55,45]]
hall_blocks = [[0,299,187,33],[294,299,186,33]]
room('u_main_stair','Upper Gallery',1,'grand-hall',hall_regions,hall_blocks)
room('u_service_stair','Upper Service Landing',1,'cold-statue-hall-alternate',
     [[16,197,448,135],[16,168,448,42]],[],
     'Service stair return is a marked landing doorway; the downward flight needs dedicated art.')
room('u_master','Main Bedroom',1,'guest-bedroom-alternate',[[16,176,448,156]],
     [[0,142,114,54],[318,145,146,48]])
room('u_guest','Guest Bedroom',1,'guest-bedroom',[[16,156,448,176]],
     [[24,147,103,62],[157,129,126,31],[380,157,67,42],[0,298,194,34],[284,298,196,34]])
room('u_study','Study',1,'library-alternate',[[16,126,448,206],[405,109,39,45]],
     [[43,139,147,63],[0,285,193,47],[284,285,196,47]])
room('u_bath','Washroom',1,'firelit-entry',[[16,160,448,172]],[],
     'Existing furnished hall placeholder; bath fixtures need a later art pass.')

room('b_main_stair','Basement Main Landing',-1,'torchlit-stone',[[16,177,448,155],[360,120,64,79]],
     [[0,244,97,88],[425,243,39,39]],'Main stair return uses the painted rear passage; stair flight art is pending.')
room('b_service_stair','Basement Service Landing',-1,'torchlit-stone-alternate',
     [[16,174,448,158],[388,126,63,65]],[],
     'Service stair return uses the rear passage; dedicated upward stair art is pending.')
room('b_wine','Wine Cellar',-1,'torchlit-stone-alternate',[[16,174,448,158],[388,126,63,65]],[],
     'Storage alcoves stand in for wine racks.')
room('b_archive','Estate Archive',-1,'library-alternate',[[16,126,448,206],[405,109,39,45]],
     [[43,139,147,63],[0,285,193,47],[284,285,196,47]])
room('b_utility','Utility Room',-1,'torchlit-stone',[[16,177,448,155],[360,120,64,79]],
     [[0,244,97,88],[425,243,39,39]])
room('b_store','Storage Room',-1,'torchlit-stone-alternate',[[16,174,448,158],[388,126,63,65]],[])


def link(a, a_at, a_arrival, a_facing, b, b_at, b_arrival, b_facing, kind='door', note=''):
    identity = a+'--'+b
    for origin, at, target, arrival, facing in [(a,a_at,b,b_arrival,b_facing),(b,b_at,a,a_arrival,a_facing)]:
        rooms[origin]['portals'].append(dict(id=identity, at=at, target=target,
            arrival=arrival, facing=facing, kind=kind, passage_note=note))


# Small playable slice: seven functional rooms and two circulation screens.
# Keep unused definitions above as authoring options; they are not runtime rooms.
active_ids = ['g_foyer','g_main_stair','g_library','g_dining','g_kitchen',
              'u_main_stair','u_master','u_study','b_store']
deferred = {key: {'name': value['name'], 'asset': value['asset']}
            for key, value in rooms.items() if key not in active_ids}
rooms = {key: rooms[key] for key in active_ids}
rooms['b_store']['name'] = 'Basement Storage'
rooms['u_main_stair']['name'] = 'Upstairs Landing'

# Painted thresholds are used where possible. The foyer vestibule and kitchen
# basement flight remain explicit art gaps; do not claim a measured floor plan.
link('g_foyer',[240,326],[240,299],[0,-1], 'g_main_stair',[240,326],[240,295],[0,-1],note='Bent passage between south thresholds; foyer side-door art remains a future option.')
link('g_main_stair',[20,202],[49,210],[1,0], 'g_library',[460,193],[431,205],[-1,0])
link('g_library',[20,195],[48,209],[1,0], 'g_dining',[460,194],[430,209],[-1,0])
link('g_dining',[20,194],[48,210],[1,0], 'g_kitchen',[460,202],[430,217],[-1,0])
link('g_main_stair',[374,139],[374,174],[0,1], 'u_main_stair',[240,326],[240,292],[0,-1], 'stairs')
link('u_main_stair',[20,195],[49,211],[1,0], 'u_master',[460,279],[431,282],[-1,0])
link('u_main_stair',[460,195],[431,212],[-1,0], 'u_study',[20,203],[48,220],[1,0])
link('g_kitchen',[240,326],[240,285],[0,-1], 'b_store',[421,140],[421,183],[0,1],
     'stairs','Kitchen south threshold leads through an offscreen descending stair. Basement return is the rear doorway; matching stair artwork is still required.')

from reworked_mansion_geometry import apply as apply_reworked_geometry
apply_reworked_geometry(rooms,link)
from opposite_mansion_geometry import apply as apply_opposite_geometry
apply_opposite_geometry(rooms,link)

object_placements = {
    "foyer-lens":["g_foyer",120,221], "foyer-knife":["g_library",244,252], "review-bust":["g_library",292,220],
    "review-bottle":["g_dining",311,258], "review-hammer":["g_kitchen",288,241],
    "review-stool":["g_kitchen",365,275], "review-poker":["u_master",173,237],
    "review-mallet":["b_store",270,263], "review-decanter":["g_dining",213,249],
    "review-book":["u_study",269,234], "review-safe":["b_store",365,245]}

data = dict(object_placements=object_placements, schema_version=1,id='fixed-manor-compact-3',start_room='g_foyer',rooms=rooms,
    deferred_rooms=deferred,
    description='Compact first mansion: four ground-floor rooms, two upstairs, one basement; stair hall and upper landing are circulation. Opposite-side doors, automatic crossing, and a ground-floor loop.')
(ROOT/'assets/mansion/fixed-mansion.json').write_text(json.dumps(data,indent=2)+'\n')
print(f'Wrote {len(rooms)} fixed rooms, {sum(len(r["portals"]) for r in rooms.values())//2} reciprocal passages')
