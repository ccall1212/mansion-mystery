"""Provisional annotations for approved opposite-door art; preserve later calibration."""
import json
from pathlib import Path
from tag_mansion_furniture import create
from tag_reworked_rooms import PLANS
from check_image_approval import check

ROOT = Path(__file__).resolve().parents[1]
batch_path = ROOT/'assets/rooms/revisions/2026-10-24-opposite-doors/manifest.json'
batch = json.loads(batch_path.read_text())
catalog = json.loads((ROOT/'assets/furniture/catalog.json').read_text())
registry_path = ROOT/'assets/furniture/backgrounds.json'
registry = json.loads(registry_path.read_text())
doors = json.loads((ROOT/'assets/rooms/doorway-catalog.json').read_text())['backgrounds']
plans = {key:list(PLANS[key]) for key in ['g_main_stair','g_dining','g_kitchen']}
plans['g_foyer'] = [
    ('welcome_table','table_south',[72,169,93,83]),
    ('bench','bench_south',[315,195,120,52]),
    ('reading_armchair','armchair_south',[378,99,42,52]),
    ('reading_side_table','table_south',[422,123,28,35]),
    ('clock','clock_south',[72,71,30,74]),
    ('console','cabinet_south',[29,112,42,32]),
    ('west_window','window_south',[112,28,47,88]),
    ('east_window','window_south',[321,28,47,88])]
plans['g_dining'] = [row for row in plans['g_dining'] if row[0] not in ['sideboard','landscape']]+[
    ('sideboard','cabinet_south',[263,65,78,40]),('landscape','painting_south',[269,3,66,55])]
plans['g_kitchen'] = [row for row in plans['g_kitchen'] if row[0] not in ['sink','window','pantry','sink_barrel']]+[
    ('sink','cabinet_south',[224,65,80,38]),('window','window_south',[239,0,51,69]),
    ('pantry','cabinet_south',[355,0,66,100])]
for job in batch['jobs']:
    check(job,ROOT)
    id = job['id']+'_opposite_v2'
    path = ROOT/'assets/furniture/layouts'/ (id+'.json')
    asset = 'res://'+job['path']
    if not path.exists():
        layout = dict(schema_version=1,id=id,background=asset,coordinate_space='background_local',
            coordinate_size=[480,320],artwork_sha256=job['sha256'],source_room_id=job['id'],
            review_status='provisional_not_pose_fit_approved',instances=[],
            coverage_gaps=['Coat and umbrella stands are decorative; dedicated interaction types pending.'] if job['id']=='g_foyer' else [])
        rows = list(plans[job['id']])
        for door in doors[asset]['doors']:
            side=door['side'];x,y=door['position']
            variant={'north':'doorway_south','south':'doorway_north','east':'doorway_west','west':'doorway_east'}[side]
            bounds=[max(0,min(446,x-12)),max(0,min(264,y-45)),24,56] if side in ['east','west'] else [max(0,min(414,x-33)),max(0,y-74) if side=='north' else 292,66,74 if side=='north' else 28]
            rows.append((side+'_door',variant,bounds))
        for short,variant,bounds in rows:
            item=create(catalog['variants'][variant],job['id']+'_'+short,bounds)
            item.update(contact_status='provisional',placement_enabled=False)
            for anchor in item['anchors']:
                anchor['status']='provisional'
                if job['id']=='g_foyer' and short=='north_door':
                    anchor['enabled']=False
                    anchor['status']='locked_front_door'
            if job['id']=='g_dining' and short.startswith('chair_'):
                item['target_instance_id']='g_dining_dining_table'
            layout['instances'].append(item)
        path.write_text(json.dumps(layout,indent=2)+'\n')
    job['furniture_layout']='res://'+path.relative_to(ROOT).as_posix()
    job['furniture_status']='provisional_not_pose_fit_approved'
    registry['backgrounds'][asset]=job['furniture_layout']
batch_path.write_text(json.dumps(batch,indent=2)+'\n')
registry_path.write_text(json.dumps(registry,indent=2)+'\n')
print('Four current artwork layouts registered; new contacts remain provisional.')
