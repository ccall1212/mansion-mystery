"""Approved opposite-door layout; all positions are logical world feet coordinates."""
import json
from pathlib import Path
from check_image_approval import check

def apply(rooms, link):
    root = Path(__file__).resolve().parents[1]
    batch = json.loads((root/'assets/rooms/revisions/2026-10-24-opposite-doors/manifest.json').read_text())
    geometry = {
        'g_foyer': ([[16,174,448,164],[110,160,260,40]],
            [[0,316,207,28],[273,316,207,28],[166,155,148,18],
             [29,150,69,18],[378,155,42,20],[422,167,28,15],
             [72,220,93,56],[22,231,38,20],[315,240,120,31]]),
        'g_main_stair': ([[16,185,448,127],[266,92,108,150]],
            [[65,167,42,25],[390,195,45,27],[248,104,16,131],[376,104,11,131],[0,312,480,32]]),
        'g_dining': ([[16,132,448,206],[190,104,43,50]],
            [[140,170,204,80],[263,115,78,16],[329,118,77,22]]),
        'g_kitchen': ([[16,134,448,204],[307,100,40,60]],
            [[8,160,66,40],[75,190,141,48],[51,210,28,23],[355,119,66,18],[0,302,179,42],[295,302,185,42]])
    }
    for job in batch['jobs']:
        check(job, root)
        room = rooms[job['id']]
        room.update(asset='res://'+job['path'], furniture_layout=job.get('furniture_layout',''),
                    walk_regions=geometry[job['id']][0], obstacles=geometry[job['id']][1],
                    art_note='User-approved opposite-door artwork. New furniture contacts require independent fit review.')
    rooms['g_foyer']['hide_reading_stand'] = True
    for room in rooms.values():
        room['portals'] = []
        room['automatic_doorways'] = True
    link('g_foyer',[20,190],[50,190],[1,0], 'g_library',[460,188],[437,211],[-1,0])
    link('g_foyer',[460,190],[430,190],[-1,0], 'g_main_stair',[20,224],[52,227],[1,0])
    link('g_foyer',[240,326],[240,294],[0,-1], 'g_dining',[211,120],[211,152],[0,1])
    link('g_library',[277,326],[277,292],[0,-1], 'g_kitchen',[327,116],[327,156],[0,1])
    link('g_dining',[20,190],[48,210],[1,0], 'g_kitchen',[460,188],[431,215],[-1,0])
    link('g_main_stair',[322,101],[322,126],[0,1], 'u_main_stair',[240,326],[240,287],[0,-1], 'stairs')
    link('u_main_stair',[20,184],[49,201],[1,0], 'u_master',[460,302],[431,300],[-1,0])
    link('u_main_stair',[460,184],[431,201],[-1,0], 'u_study',[20,185],[52,205],[1,0])
    link('g_kitchen',[240,326],[240,286],[0,-1], 'b_store',[418,140],[418,176],[0,1], 'stairs')
    plan = json.loads((root/'assets/mansion/opposite-door-plan.json').read_text())
    opposite = {'north':'south','south':'north','east':'west','west':'east'}
    for id, room in rooms.items():
        room['map_grid'] = plan['rooms'][id]['grid']
        for portal in room['portals']:
            portal['side'] = next(side for side,target in plan['rooms'][id]['doors'].items() if target == portal['target'])
            assert plan['rooms'][portal['target']]['doors'][opposite[portal['side']]] == id
