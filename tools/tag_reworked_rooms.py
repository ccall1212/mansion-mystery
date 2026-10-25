"""Author draft furniture on the approved October room revisions, preserving later edits.

Bounds are manually traced estimates in 480x320 background-local units.
Run --apply once; subsequent runs preserve existing layout files/calibration.
"""
import argparse
import copy
import hashlib
import json
from pathlib import Path
from tag_mansion_furniture import create

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT/'assets/furniture'
BATCH = ROOT/'assets/rooms/revisions/2026-10-24-room-rework/manifest.json'
# name, existing orientation ID, x/y/width/height. Books on shelves and decorative
# candles are part of their parent surface, not independently collectible props.
PLANS = {
 'g_library': [
  ('west_shelves','bookshelf_east',[0,0,54,203]),
  ('north_shelves_west','bookshelf_south',[54,0,56,111]),
  ('north_shelves_middle','bookshelf_south',[154,0,125,114]),
  ('north_shelves_east','bookshelf_south',[312,0,131,108]),
  ('window','window_south',[110,0,44,85]),
  ('reading_table','table_south',[120,130,111,48]),
  ('reading_chair_nw','chair_south',[148,107,32,25]),
  ('reading_chair_ne','chair_south',[190,107,32,25]),
  ('reading_chair_sw','chair_north',[135,146,34,43]),
  ('reading_chair_se','chair_north',[185,146,34,43]),
  ('red_armchair','armchair_east',[62,182,61,66]),
  ('green_armchair','armchair_west',[124,190,58,66]),
  ('reading_side_table','table_south',[48,204,34,43]),
  ('librarian_desk','desk_south',[322,121,112,52]),
  ('desk_chair','chair_south',[356,103,34,30]),
  ('book_cart','cabinet_south',[278,94,39,46])],
 'g_main_stair': [
  ('straight_stairs','stairway_north',[248,73,139,137]),
  ('window','window_south',[171,0,44,91])],
 'g_dining': [
  ('dining_table','table_south',[163,136,156,66]),
  ('chair_nw','chair_south',[195,113,29,26]),('chair_ne','chair_south',[260,113,28,26]),
  ('chair_sw','chair_north',[191,176,30,50]),('chair_se','chair_north',[259,176,30,50]),
  ('chair_west','chair_east',[141,143,27,58]),('chair_east','chair_west',[316,143,26,58]),
  ('sideboard','cabinet_south',[186,65,109,40]),
  ('fireplace','fireplace_south',[329,49,77,66]),
  ('landscape','painting_south',[198,0,85,58]),('window','window_south',[77,0,60,97])],
 'g_kitchen': [
  ('range','fireplace_south',[74,24,121,87]),
  ('west_worktop','cabinet_east',[8,90,66,86]),
  ('west_shelves','cabinet_east',[13,44,53,51]),
  ('sink','cabinet_south',[247,65,80,38]),
  ('window','window_south',[263,0,51,69]),
  ('pantry','cabinet_south',[334,0,87,100]),
  ('prep_table','table_south',[76,132,140,82]),
  ('work_stool','stool_east',[51,165,28,45]),
  ('sink_barrel','barrel_south',[316,80,21,28])],
 'u_main_stair': [
  ('west_bench','bench_south',[74,113,43,20]),('east_bench','bench_south',[363,113,43,20]),
  ('west_statue','statue_south',[132,34,28,99]),('east_statue','statue_south',[317,34,30,99]),
  ('west_window','window_south',[76,0,43,108]),('east_window','window_south',[360,0,44,108]),
  ('landscape','painting_south',[207,20,68,55]),('console','table_south',[201,89,73,38])],
 'u_master': [
  ('canopy_bed','bed_east_west_head_east',[307,12,142,174]),
  ('bedside_cabinet','cabinet_south',[416,129,50,66]),
  ('bed_foot_bench','bench_west',[276,117,43,59]),
  ('window_bench','bench_south',[227,62,63,31]),
  ('window','window_south',[223,0,66,66]),
  ('fireplace','fireplace_south',[110,44,82,56]),
  ('mantel_clock','clock_south',[143,23,17,23]),
  ('vanity','desk_east',[26,89,62,89]),('vanity_mirror','mirror_east',[36,39,26,61]),
  ('vanity_bench','bench_west',[67,117,36,42]),('west_bench','bench_east',[10,198,33,48]),
  ('reading_armchair_west','armchair_east',[130,169,58,61]),
  ('reading_armchair_east','armchair_west',[235,195,66,67]),
  ('reading_table','table_south',[189,198,50,48]),
  ('west_picture','painting_east',[12,81,22,55]),('upper_picture','painting_east',[64,6,19,51])],
 'u_study': [
  ('north_shelves','bookshelf_south',[113,0,338,97]),
  ('west_window','window_east',[0,0,31,86]),
  ('fireplace','fireplace_south',[37,29,74,74]),('mantel_picture','painting_south',[59,0,38,27]),
  ('writing_desk','desk_north',[98,107,103,60]),('desk_chair','chair_north',[131,130,33,45]),
  ('document_table','table_south',[197,180,151,63]),
  ('chair_north','chair_south',[242,156,36,25]),('chair_south','chair_north',[244,214,41,50]),
  ('chair_west','chair_east',[172,178,27,62]),('chair_east','chair_west',[344,178,31,62]),
  ('reading_armchair','armchair_west',[377,90,63,71]),('reading_side_table','table_south',[424,125,34,42])],
 'b_store': [
  ('west_storage_rack','cabinet_south',[96,29,85,89]),
  ('back_east_storage_rack','cabinet_south',[224,28,84,92]),
  ('workbench','desk_west',[12,110,62,76]),('work_stool','stool_west',[57,145,22,33]),
  ('west_work_shelf','cabinet_east',[5,72,43,66]),
  ('back_barrel_west','barrel_south',[97,89,26,40]),('back_barrel_east','barrel_south',[278,89,29,40]),
  ('back_crate','crate_south',[223,97,35,32]),('back_chest','cabinet_south',[145,105,38,25]),
  ('foreground_crate_west','crate_south',[1,202,39,89]),
  ('foreground_crate_center','crate_south',[19,251,48,53]),
  ('foreground_worktable','table_south',[24,224,69,62]),
  ('foreground_chest','cabinet_south',[82,246,39,42]),
  ('foreground_crate_east','crate_south',[414,178,66,71]),
  ('foreground_barrel_east','barrel_south',[423,256,35,60]),
  ('east_storage_rack','cabinet_west',[438,123,41,73])],
 'future_bar': [
  ('bar_counter','bar_counter_south',[46,69,185,56]),
  ('bottle_shelves','cabinet_south',[75,0,102,70]),
  ('bar_stool_01','bar_stool_north',[73,90,26,46]),
  ('bar_stool_02','bar_stool_north',[110,90,26,46]),
  ('bar_stool_03','bar_stool_north',[146,90,26,46]),
  ('bar_stool_04','bar_stool_north',[183,90,26,46]),
  ('window','window_south',[267,0,47,74]),('north_picture','painting_south',[338,0,53,48]),
  ('west_picture','painting_east',[9,37,30,80]),('console','table_south',[340,63,59,35]),
  ('conversation_table','table_south',[256,148,76,65]),
  ('table_chair_nw','armchair_east',[240,133,35,47]),
  ('table_chair_ne','armchair_west',[316,132,35,47]),
  ('table_chair_sw','armchair_east',[228,170,49,57]),
  ('table_chair_se','armchair_west',[314,170,47,57]),
  ('west_armchair_upper','armchair_east',[30,131,46,62]),
  ('west_armchair_lower','armchair_east',[3,174,46,61]),
  ('west_side_table','table_south',[19,164,34,38])]
}

def main(apply=False):
    batch=json.loads(BATCH.read_text())
    catalog=json.loads((BASE/'catalog.json').read_text())
    registry=json.loads((BASE/'backgrounds.json').read_text())
    report=[]
    for job in batch['jobs']:
        assert job['approval']=='approved', f"Unapproved art: {job['id']}"
        assert hashlib.sha256((ROOT/job['path']).read_bytes()).hexdigest()==job['sha256']
        room=job['id']; layout_id=room+'_rework_v'+('3' if room=='g_library' else '2' if room in ['u_study','future_bar'] else '1')
        path=BASE/'layouts'/(layout_id+'.json')
        layout=dict(schema_version=1,id=layout_id,background='res://'+job['path'],coordinate_space='background_local',coordinate_size=[480,320],
                    artwork_sha256=job['sha256'],source_room_id=room,review_status='draft_contacts_pending_visual_review',instances=[])
        if path.exists():
            layout=json.loads(path.read_text())
        else:
            for short,variant,bounds in PLANS[room]:
                item=create(catalog['variants'][variant],room+'_'+short,bounds)
                item['contact_status']='provisional'
                item['placement_enabled']=False
                if 'size_profile_id' in catalog['variants'][variant]:
                    item.update(size_profile_id=catalog['variants'][variant]['size_profile_id'],size_review='unmeasured')
                # Side-view gaze templates include coordinates as well as floor points.
                template=catalog['variants'][variant]
                for anchor in item['anchors']:
                    anchor['status']='provisional'
                    if 'gaze_target' in anchor:
                        anchor['gaze_target']=[anchor['gaze_target'][0]*bounds[2]/template['bounds'][2],anchor['gaze_target'][1]*bounds[3]/template['bounds'][3]]
                layout['instances'].append(item)
            for door in job['door_positions']:
                side=door['side']; x,y=door['position']
                variant={'north':'doorway_south','south':'doorway_north','east':'doorway_west','west':'doorway_east'}[side]
                bounds=[max(0,min(446,x-12)),max(0,min(264,y-45)),24,56] if side in ['east','west'] else [max(0,min(414,x-33)),0 if side=='north' else 292,66,28]
                item=create(catalog['variants'][variant],room+'_'+side+'_door',bounds)
                item.update(contact_status='provisional',placement_enabled=False)
                layout['instances'].append(item)
            by_short={i['id'].removeprefix(room+'_'):i for i in layout['instances']}
            for short,item in by_short.items():
                kind=catalog['variants'][item['variant_id']]['type']
                if kind=='bar_stool':
                    item['target_instance_id']=room+'_bar_counter'
                    item['notes']+=' Tall stool: footrest and special seated leg pose require calibration.'
                target='reading_table' if room=='g_library' and short.startswith('reading_chair_') else 'dining_table' if room=='g_dining' and short.startswith('chair_') else 'document_table' if room=='u_study' and short.startswith('chair_') else 'conversation_table' if room=='future_bar' and short.startswith('table_chair_') else None
                if target:
                    item['target_instance_id']=room+'_'+target
                    item['notes']+=' Facing is intended toward table; painted seat/backs need pose and occlusion review.'
                if kind=='desk':
                    # Do not allocate a second occupant to the same painted desk chair.
                    for anchor in item['anchors']:
                        if anchor['posture']=='seated':
                            anchor['enabled']=False
                            anchor['status']='disabled_use_separate_seat_tag'
                if short in ['desk_chair','vanity_bench']:
                    item['occupancy_group']=room+'_desk_seat'
                if short=='canopy_bed':
                    item['notes']+=' Body axis east-west, head east; canopy is not mattress height. Contacts disabled pending mattress/pelvis calibration.'
                    for anchor in item['anchors']:anchor['enabled']=False
        report.append(dict(room=room,layout='res://'+path.relative_to(ROOT).as_posix(),background=layout['background'],tags=len(layout['instances'])))
        registry['backgrounds'][layout['background']]='res://'+path.relative_to(ROOT).as_posix()
        if apply:
            path.write_text(json.dumps(layout,indent=2)+'\n')
            job['furniture_layout']='res://'+path.relative_to(ROOT).as_posix()
            job['furniture_status']='tagged_provisional_contacts_not_staging_ready'
    if apply:
        (BASE/'backgrounds.json').write_text(json.dumps(registry,indent=2)+'\n')
        BATCH.write_text(json.dumps(batch,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
        out=ROOT/'test-results/reworked-furniture';out.mkdir(parents=True,exist_ok=True)
        (out/'inventory.json').write_text(json.dumps(report,indent=2)+'\n')
    print(f'{len(report)} backgrounds; {sum(r["tags"] for r in report)} tags; contacts provisional; runtime unchanged')

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--apply',action='store_true')
    main(parser.parse_args().apply)
