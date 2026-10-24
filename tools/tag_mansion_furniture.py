"""Append reviewed visible-object tags without overwriting mapper calibration.

Run without arguments to preview; --apply writes missing tags and registry bindings.
Bounds are background-local at 480x320. Generated anchors are draft pose targets.
"""
import argparse
import copy
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT/'assets/furniture'

# Short IDs describe the pictured object, rather than an imagined future room prop.
# Each row is (name, orientation ID, visual bounds).
PLANS = {
 'foyer': ('foyer/foyer-background.png', [
  ('west_window','window_south',[108,37,50,100]),
  ('clock','clock_south',[69,100,29,63]),
  ('console','cabinet_south',[17,112,49,42]),
  ('portrait','painting_south',[28,61,32,50])]),
 'library': ('rooms/room-library.png', [
  ('west_shelves','bookshelf_east',[49,58,68,128]),
  ('foreground_cabinet','cabinet_south',[0,198,145,74]),
  ('window','window_south',[110,0,49,80]),
  ('side_table','table_south',[104,103,20,35]),
  ('west_door','doorway_east',[4,88,31,91]),
  ('east_door','doorway_west',[446,89,32,92])]),
 'guest_bedroom': ('rooms/room-guest-bedroom.png', [
  ('cabinet','cabinet_south',[201,48,67,67]),
  ('back_chair','chair_south',[271,87,28,29]),
  ('nightstand','cabinet_east',[126,95,28,52]),
  ('side_table','table_west',[422,104,29,53]),
  ('west_door','doorway_east',[1,109,27,114]),
  ('east_door','doorway_west',[445,97,32,88]),
  ('south_threshold','doorway_north',[199,278,79,42])]),
 'main_stair': ('rooms/room-dark-stairwell.png', [
  ('stairs','stairway_south',[304,94,133,123]),
  ('window','window_south',[328,0,54,64]),
  ('upper_door','doorway_south',[83,0,46,40]),
  ('bench','bench_south',[67,123,92,44]),
  ('west_door','doorway_east',[8,107,28,94])]),
 'dining': ('rooms/room-reception-hall-alternate.png', [
  ('west_sofa','sofa_east',[50,73,60,69]),
  ('east_sofa','sofa_west',[389,81,61,70]),
  ('side_table','table_east',[36,106,32,40]),
  ('cabinet','cabinet_south',[185,67,116,42]),
  ('fireplace','fireplace_south',[335,29,63,80]),
  ('portrait','painting_south',[198,1,87,54]),
  ('window','window_south',[76,0,50,79]),
  ('west_door','doorway_east',[8,88,28,91]),
  ('east_door','doorway_west',[446,90,33,87]),
  ('south_threshold','doorway_north',[380,270,59,50])]),
 'kitchen': ('rooms/room-reception-hall.png', [
  ('counter','bar_counter_south',[29,57,204,66]),
  ('back_shelves','cabinet_south',[49,0,159,64]),
  ('upper_chair','chair_east',[23,128,33,54]),
  ('lower_chair','chair_east',[4,166,44,57]),
  ('side_table','table_east',[31,150,28,39]),
  ('back_cabinet','cabinet_south',[338,54,66,34]),
  ('portrait','painting_south',[336,0,66,50]),
  ('window','window_south',[266,0,47,82]),
  ('west_door','doorway_east',[8,64,30,92]),
  ('east_door','doorway_west',[443,83,32,94]),
  ('south_threshold','doorway_north',[194,278,81,42])]),
 'service_stair': ('rooms/room-dark-stairwell-basement.png', [
  ('shelves','bookshelf_south',[317,13,81,93]),
  ('window','window_south',[126,0,68,85]),
  ('descending_stairs','stairway_north',[314,127,135,154]),
  ('west_door','doorway_east',[8,66,28,78]),
  ('east_door','doorway_west',[438,90,35,86])]),
 'upper_gallery': ('rooms/room-grand-hall.png', [
  ('west_bench','bench_south',[77,111,44,25]),
  ('east_bench','bench_south',[369,111,35,25]),
  ('west_statue','statue_south',[132,26,31,107]),
  ('east_statue','statue_south',[321,26,31,107]),
  ('west_window','window_south',[81,10,40,101]),
  ('east_window','window_south',[362,9,40,101]),
  ('north_door','doorway_south',[212,43,61,85]),
  ('west_door','doorway_east',[8,93,28,89]),
  ('east_door','doorway_west',[444,94,32,88]),
  ('south_threshold','doorway_north',[193,285,89,35])]),
 'upper_service': ('rooms/room-cold-statue-hall-alternate.png', [
  ('west_statue','statue_south',[68,21,44,112]),
  ('east_statue','statue_south',[365,25,44,108]),
  ('west_bench','bench_east',[32,108,33,52]),
  ('east_bench','bench_west',[411,116,28,46]),
  ('north_door','doorway_south',[211,53,57,76]),
  ('west_door','doorway_east',[3,195,30,82]),
  ('east_door','doorway_west',[444,105,32,88]),
  ('window','window_south',[221,0,36,46])]),
 'master_bedroom': ('rooms/room-guest-bedroom-alternate.png', [
  ('bed','bed_north_south_head_north',[338,0,104,158]),
  ('nightstand','cabinet_west',[431,100,39,75]),
  ('bedside_bench','bench_west',[316,102,28,53]),
  ('vanity','desk_east',[44,68,58,59]),
  ('vanity_chair','chair_west',[82,91,24,35]),
  ('mirror','mirror_east',[55,28,35,49]),
  ('fireplace','fireplace_south',[112,14,69,88]),
  ('window','window_south',[222,0,69,78]),
  ('window_bench','bench_south',[223,76,66,24]),
  ('west_door','doorway_east',[3,95,30,103]),
  ('east_door','doorway_west',[446,230,32,90])]),
 'study_archive': ('rooms/room-library-alternate.png', [
  ('back_shelves','bookshelf_south',[106,1,288,97]),
  ('desk','desk_south',[44,90,83,42]),
  ('foreground_shelves','bookshelf_south',[47,116,140,67]),
  ('armchair','armchair_west',[423,104,43,56]),
  ('side_table','table_west',[449,132,25,34]),
  ('fireplace','fireplace_south',[39,24,64,70]),
  ('west_door','doorway_east',[6,89,30,92]),
  ('north_door','doorway_south',[410,8,37,88]),
  ('south_threshold','doorway_north',[201,278,80,42])]),
 'washroom_placeholder': ('rooms/room-firelit-entry.png', [
  ('bench','bench_south',[58,83,66,29]),
  ('west_window','window_south',[100,7,43,73]),
  ('east_window','window_south',[272,7,44,73]),
  ('portrait','painting_south',[187,9,44,64]),
  ('upper_brazier','fireplace_west',[369,72,29,58]),
  ('lower_brazier','fireplace_west',[430,157,34,58]),
  ('west_door','doorway_east',[3,251,25,69]),
  ('east_door','doorway_west',[445,13,32,121])]),
 'basement_stone': ('rooms/room-torchlit-stone.png', [
  ('bench','bench_south',[203,91,74,28]),
  ('crate','crate_west',[427,214,40,54]),
  ('west_door','doorway_east',[6,71,29,91]),
  ('north_arch','doorway_south',[359,0,66,101])]),
 'basement_storage': ('rooms/room-torchlit-stone-alternate.png', [
  ('front_barrel','barrel_south',[97,88,31,37]),
  ('back_barrel','barrel_south',[116,64,27,44]),
  ('west_crate','crate_south',[149,94,20,22]),
  ('back_crates','crate_south',[234,70,64,51]),
  ('east_crate','crate_south',[282,96,28,22]),
  ('west_rack','cabinet_south',[113,37,59,58]),
  ('east_rack','cabinet_south',[232,39,87,59]),
  ('north_arch','doorway_south',[392,17,54,104]),
  ('west_door','doorway_east',[6,88,27,89])])
}

def create(template, identity, bounds):
    x,y,w,h = bounds
    ox,oy = x+w/2,y+h
    sx,sy = w/template['bounds'][2],h/template['bounds'][3]
    item = dict(id=identity,variant_id=template['id'],position=[ox,oy],
        bounds=[-w/2,-h,w,h],footprint=[v*(sx if i%2==0 else sy) for i,v in enumerate(template['footprint'])],
        anchors=copy.deepcopy(template['anchors']),target_instance_id='',ready_for_staging=False,
        render_mode='baked',notes='Visible-art annotation. Draft contact; verify pose landmarks, occlusion and room navigation before staging.')
    facing = template['facing']
    dx,dy = {'north':(0,-1),'east':(1,0),'south':(0,1),'west':(-1,0),None:(0,0)}[facing]
    for a in item['anchors']:
        for key in ['contact','approach']:
            a[key] = [a[key][0]*sx,a[key][1]*sy]
        a['clearance'] = [-12,-8,24,16]
        if a['posture'] == 'standing':
            # Front edge, not the template's compressed vertical offset.
            px = ox+dx*(w/2+14)
            py = y-12 if facing=='north' else oy+12 if facing=='south' else oy-3
            a['contact'] = [max(10,min(470,px))-ox,max(10,min(310,py))-oy]
            a['approach'] = [max(12,min(468,px+dx*15))-ox,max(12,min(308,py+dy*15))-oy]
        if a['id']=='outside':
            a['enabled'] = False
    # Facing-side sofas use vertical seat separation in this perspective.
    if template['type']=='sofa' and facing in ['east','west']:
        for index,a in enumerate(item['anchors']):
            a['contact'] = [dx*w*.16,-h*(.6 if index==0 else .28)]
            a['approach'] = [dx*(w/2+18),-h*(.6 if index==0 else .28)]
    # Clamp draft approaches inside the canvas; geometry is still reviewed separately.
    for a in item['anchors']:
        for key in ['contact','approach']:
            a[key]=[round(max(8,min(472,ox+a[key][0]))-ox,2),round(max(8,min(312,oy+a[key][1]))-oy,2)]
    return item

def apply(write=False):
    catalog=json.loads((BASE/'catalog.json').read_text())
    registry=json.loads((BASE/'backgrounds.json').read_text())
    added=0
    for name,(asset,specs) in PLANS.items():
        background='res://assets/'+asset
        resource=registry['backgrounds'].get(background,'res://assets/furniture/layouts/'+name+'.json')
        path=ROOT/resource.removeprefix('res://')
        layout=json.loads(path.read_text()) if path.exists() else dict(schema_version=1,id=name,background=background,coordinate_space='background_local',coordinate_size=[480,320],instances=[])
        existing={i['id'] for i in layout['instances']}
        for short,variant,bounds in specs:
            identity=name+'_'+short+'_01'
            if identity in existing:
                continue
            item=create(catalog['variants'][variant],identity,bounds)
            # Wall-height bounds are not floor-height feet. Project their standing
            # contacts onto this image's approximate floor, preserving side facing.
            if catalog['variants'][variant]['type'] in ['window','painting','mirror','clock','statue','cabinet','bookshelf']:
                floor_y={'foyer':150,'library':115,'guest_bedroom':150,'main_stair':165,
                    'dining':140,'kitchen':120,'service_stair':145,'upper_gallery':165,
                    'upper_service':160,'master_bedroom':172,'study_archive':120,
                    'washroom_placeholder':152,'basement_stone':170,'basement_storage':166}[name]
                for a in item['anchors']:
                    if a['posture']=='standing':
                        a['contact'][1]=max(a['contact'][1],floor_y-item['position'][1])
                        a['approach'][1]=max(a['approach'][1],floor_y+16-item['position'][1])
            if short=='back_shelves' and name=='kitchen':
                for a in item['anchors']: a['enabled']=False
                item['notes']+=' Behind the painted bar counter; disabled until access is authored.'
            if name=='master_bedroom' and short=='bed':
                # Right side is against furniture/wall; use the clear west side.
                item['anchors'][0]['approach']=[-75,-45]
                item['anchors'][2]['enabled']=False
            if name=='master_bedroom' and short=='vanity':
                item['anchors'][0]['contact']=[26,-19]
                item['anchors'][0]['actor_facing']='west'
                item['anchors'][0]['approach']=[50,8]
                item['notes']+=' Seated work shares the separately tagged vanity chair; these are one occupancy group.'
                item['occupancy_group']='master_vanity'
            if name=='master_bedroom' and short=='vanity_chair':
                item['anchors'][0]['activities']=['idle','talk','read','write']
                item['occupancy_group']='master_vanity'
            if name=='study_archive' and short=='desk':
                item['anchors'][0]['actor_facing']='south'
                item['anchors'][0]['contact']=[20,-45]
                item['anchors'][0]['approach']=[45,-30]
            if 'brazier' in short:
                item['notes']+=' Painted fire basket, using fireplace interaction vocabulary; no new hearth is implied.'
            if 'threshold' in short or 'door' in short or 'arch' in short:
                item['notes']+=' Visual opening tag only; actual traversable exits remain defined by mansion portals.'
            layout['instances'].append(item)
            added+=1
        if write:
            path.write_text(json.dumps(layout,indent=2)+'\n')
        registry['backgrounds'][background]=resource
    if write:
        (BASE/'backgrounds.json').write_text(json.dumps(registry,indent=2)+'\n')
    print(('Added' if write else 'Would add'),added,'tags;',len(registry['backgrounds']),'backgrounds registered')

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply',action='store_true')
    apply(parser.parse_args().apply)
