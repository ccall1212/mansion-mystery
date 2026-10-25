"""Approved room integration: feet-level geometry, never full-height art bounds."""
import json
from pathlib import Path
from check_image_approval import check

def apply(rooms, link):
    root=Path(__file__).resolve().parents[1]
    batch=json.loads((root/'assets/rooms/revisions/2026-10-24-room-rework/manifest.json').read_text())
    geometry={
      'g_main_stair': ([[16,185,448,153],[266,92,108,150]],[[65,167,42,25],[390,195,45,27],[248,104,16,131],[376,104,11,131]]),
      'g_library': ([[16,137,448,201]],[[0,24,54,202],[120,164,112,48],[64,246,59,30],[124,254,59,29],[48,254,34,22],[322,165,112,34],[277,143,40,22],[0,316,244,28],[311,316,169,28]]),
      'g_dining': ([[16,132,448,206]],[[140,170,204,80],[186,111,109,19],[329,118,77,22]]),
      'g_kitchen': ([[16,134,448,204]],[[8,160,66,40],[75,190,141,48],[51,210,28,23],[334,119,87,18],[0,302,179,42],[295,302,185,42]]),
      'u_main_stair': ([[16,150,448,188]],[[74,141,43,17],[363,141,43,17],[132,138,28,22],[317,138,30,22],[201,137,73,14],[0,303,188,41],[294,303,186,41]]),
      'u_master': ([[16,120,448,218]],[[307,135,142,75],[416,186,50,33],[276,174,43,26],[227,105,63,18],[110,112,82,17],[26,157,62,46],[67,164,36,20],[10,251,33,18],[130,222,58,32],[235,264,66,22],[189,241,50,28]]),
      'u_study': ([[16,118,448,220]],[[37,113,74,22],[98,147,103,50],[131,191,33,13],[173,201,203,87],[377,158,63,27],[424,175,34,16]]),
      'b_store': ([[16,151,448,187],[395,102,51,70]],[[0,165,78,45],[0,226,121,108],[414,202,66,111],[438,158,41,40],[96,140,85,18],[224,140,84,18]])
    }
    for job in batch['jobs']:
        if job['id'] not in rooms: continue
        check(job,root)
        room=rooms[job['id']]
        room.update(asset='res://'+job['path'],furniture_layout=job['furniture_layout'],
                    walk_regions=geometry[job['id']][0],obstacles=geometry[job['id']][1],
                    art_note='Approved room revision; feet-level geometry integrated. General furniture staging remains provisional.')
    for room in rooms.values(): room['portals']=[]
    link('g_foyer',[240,326],[240,299],[0,-1], 'g_main_stair',[240,326],[240,295],[0,-1],note='Bent entrance vestibule joins the two south thresholds; locked front door remains north.')
    link('g_main_stair',[20,224],[52,227],[1,0], 'g_library',[460,188],[437,211],[-1,0])
    link('g_library',[277,326],[277,292],[0,-1], 'g_dining',[460,190],[430,210],[-1,0],note='Short turning passage joins library south to dining east; this is not a straight shared wall.')
    link('g_dining',[20,190],[48,210],[1,0], 'g_kitchen',[460,188],[431,215],[-1,0])
    link('g_main_stair',[322,101],[322,126],[0,1], 'u_main_stair',[240,326],[240,287],[0,-1], 'stairs')
    link('u_main_stair',[20,184],[49,201],[1,0], 'u_master',[460,302],[431,300],[-1,0])
    link('u_main_stair',[460,184],[431,201],[-1,0], 'u_study',[20,185],[52,205],[1,0])
    link('g_kitchen',[240,326],[240,286],[0,-1], 'b_store',[418,140],[418,176],[0,1], 'stairs',
         'Kitchen south threshold descends an offscreen service stair to the basement north doorway.')
