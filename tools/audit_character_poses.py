"""Read-only game audit; writes authoring reports, never runtime data or artwork.

Run --check to compare the derived reports without writing. Production manifests
are initialized once and validated thereafter, never regenerated over approvals.
"""
import argparse
import csv
import hashlib
import io
import json
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DIRECTIONS = ['north','east','south','west']
OUT = 'docs/pose-audit/'
MANIFEST = 'assets/characters/poses/char/production-manifest.json'

def read(path):
    return json.loads((ROOT/path.removeprefix('res://')).read_text(encoding='utf-8'))

def sha(path):
    return hashlib.sha256((ROOT/path.removeprefix('res://')).read_bytes()).hexdigest()

def ids(a, enabled=True):
    if enabled and not a.get('enabled',True):
        return []
    alignment = a['body_axis']+'_head_'+a['head_toward'] if a['posture']=='lying' else a['actor_facing']
    return [a['posture']+'_'+action+'_'+alignment for action in a['activities']]

def inside(rect,p):
    x,y,w,h=rect
    return x<=p[0]<x+w and y<=p[1]<y+h

def feet_clear(room,p):
    # Same four footprint probes and strict rectangle overlap as FixedSession.feet_free.
    for dx,dy in [(-5,-5),(5,-5),(-5,.5),(5,.5)]:
        if not any(inside(r,[p[0]+dx,p[1]+dy]) for r in room['walk_regions']):
            return False
    x,y=p[0]-5,p[1]-5
    return not any(x<rx+rw and x+10>rx and y<ry+rh and y+6>ry for rx,ry,rw,rh in room['obstacles'])

def props(action):
    if action=='read': return 'Book or paper appropriate to target; hand choice and page contact pending'
    if action=='write': return 'Pen + paper + writing surface; dominant hand unassigned'
    if action=='drink': return 'Cup/glass + liquid level; gripping hand unassigned'
    if action=='warm_hands': return 'Both hands; no held prop; safe flame separation'
    if action=='reach': return 'Reaching hand and object/grip anchor unassigned'
    return 'No mandatory prop; any lens/held item requires a separately reviewed grip'

def csv_text(rows,fields):
    out=io.StringIO(newline='')
    writer=csv.DictWriter(out,fieldnames=fields,lineterminator='\n',extrasaction='ignore')
    writer.writeheader()
    for row in rows:
        writer.writerow({k:json.dumps(v,ensure_ascii=False) if isinstance(v,(dict,list)) else v for k,v in row.items() if k in fields})
    return out.getvalue()

def build():
    catalog=read('assets/furniture/catalog.json')
    bindings=read('assets/furniture/backgrounds.json')['backgrounds']
    rooms=read('assets/mansion/fixed-mansion.json')['rooms']
    brief=read('assets/characters/poses/requirements-brief.json')
    contacts=[]
    requirements=defaultdict(list)
    sources={'assets/furniture/catalog.json','assets/furniture/backgrounds.json','assets/mansion/fixed-mansion.json','assets/characters/poses/requirements-brief.json',
        'docs/GAME_DESIGN_BRAINSTORM.md','docs/GAME_DESIGN.md','docs/CHARACTER_ART_GUIDE.md','docs/CHARACTER_MEASUREMENT_STANDARD.md',
        'docs/CHARACTER_RENDERING.md','docs/CAST_NAME_REVIEW.md','assets/characters/review-v8/cast-catalog.json',
        'src/characters/character_render.gd','assets/characters/rendering.json','src/characters/prototype_npc.gd',
        'src/furniture/furniture_library.gd','src/mansion/fixed_session.gd'}
    layout_ids=set()
    unique_objects=set()
    variants=defaultdict(list)
    room_counts=[]
    for room_id,room in rooms.items():
        layout_path=room.get('furniture_layout') or bindings[room['asset']]
        layout=read(layout_path)
        sources.add(layout_path.removeprefix('res://'))
        layout_ids.add(layout_path)
        cw,ch=layout['coordinate_size']
        factor=min(480/cw,320/ch)
        offset=[(480-cw*factor)/2,24+(320-ch*factor)/2]
        count=Counter()
        for item in layout['instances']:
            unique_objects.add((layout_path,item['id']))
            variant=catalog['variants'][item['variant_id']]
            variants[item['variant_id']].append(room_id+'::'+item['id'])
            ox,oy=item['position']
            for anchor in item['anchors']:
                enabled=anchor.get('enabled',True)
                key=room_id+'::'+item['id']+'::'+anchor['id']
                points={k:[round((ox+anchor[k][0])*factor+offset[0],4),round((oy+anchor[k][1])*factor+offset[1],4)] for k in ['contact','approach']}
                row=dict(key=key,room_id=room_id,room_name=room['name'],floor=room['floor'],background=room['asset'],
                    layout=layout_path,instance_id=item['id'],orientation_id=item['variant_id'],furniture_type=variant['type'],
                    furniture_facing=variant['facing'],bed_axis=variant['axis'],headboard=variant['headboard'],
                    anchor_id=anchor['id'],enabled=enabled,ready_for_staging=item['ready_for_staging'],
                    declared_render_mode=item['render_mode'],
                    scene_layer_note='Existing separate ReadingStand draw-sorted prop' if item['id']=='foyer_reading_stand_01' else 'Painted background; no separate foreground mask identified',
                    status='disabled' if not enabled else 'ready' if item['ready_for_staging'] else 'provisional',
                    posture=anchor['posture'],actor_facing=anchor.get('actor_facing'),body_axis=anchor.get('body_axis'),head_toward=anchor.get('head_toward'),
                    contact_kind=anchor['contact_kind'],local_contact=anchor['contact'],local_approach=anchor['approach'],
                    interaction_side=anchor.get('interaction_side'),local_gaze_target=anchor.get('gaze_target'),
                    world_contact=points['contact'],world_approach=points['approach'],clearance=anchor['clearance'],
                    approach_clear=feet_clear(room,points['approach']) if enabled else None,
                    path_reachable='not_tested',pose_fit='not_tested',foreground_mask='not_supplied',
                    occupancy_group=item.get('occupancy_group'),target_instance_id=item.get('target_instance_id',''),
                    pose_ids=ids(anchor),disabled_template_pose_ids=[] if enabled else ids(anchor,False),
                    prop_hand_requirements={action:props(action) for action in anchor['activities']} if enabled else {},
                    occlusion='Baked art: author/check front/back mask and draw ordering before placement; no mask inferred from rectangles',
                    notes=item.get('notes',''))
                contacts.append(row)
                count['enabled' if enabled else 'disabled']+=1
                count['clear']+=int(row['approach_clear'] is True)
                for pose in row['pose_ids']:
                    requirements[pose].append(key)
        room_counts.append(dict(room_id=room_id,name=room['name'],tags=len(layout['instances']),**count))
    assert len({c['key'] for c in contacts})==len(contacts)
    # Concrete furniture IDs use the same posture_action_alignment naming as Godot.
    pose_rows=[]
    existing_manifest=read(MANIFEST) if (ROOT/MANIFEST).exists() else {}
    existing_poses={p['pose_id']:p for p in existing_manifest.get('pose_requirements',[])}
    basic={f'standing_{action}_{facing}' for action in ['idle','talk','listen'] for facing in DIRECTIONS}
    first={f'standing_idle_{facing}' for facing in DIRECTIONS}|{f'seated_idle_{facing}' for facing in ['east','south','west']}
    for pose in sorted(set(requirements)|basic):
        progress=existing_poses.get(pose,{})
        pose_rows.append(dict(id=pose,scope='common_conversation' if pose in basic else 'furniture_conditional',
            source=['docs/GAME_DESIGN_BRAINSTORM.md#5-poses-animations-and-action-continuity']+(['assets/furniture/catalog.json'] if pose in requirements else []),
            orientation_basis='enabled room anchors' if pose in requirements else 'four-sided conversations; planned future support',
            source_contacts=requirements.get(pose,[]),char_asset_status=progress.get('status','planned'),
            representation='base_pose_candidate' if pose in first else 'review_reuse_or_new_pose',
            batch='alignment_01' if pose in first else 'conversation_02' if pose in basic else 'furniture_03',
            final_asset=progress.get('final_asset'),candidate_export=progress.get('candidate_export'),approval=progress.get('approval','not_requested')))
    coverage=[dict(orientation_id=identity,type=v['type'],instances=variants[identity],
        enabled_contacts=sum(c['enabled'] for c in contacts if c['orientation_id']==identity),
        status='used_in_current_rooms' if variants[identity] else 'catalog_only_not_a_missing_current_pose',
        template_pose_ids=sorted({p for a in v['anchors'] for p in ids(a)})) for identity,v in catalog['variants'].items()]
    enabled=[c for c in contacts if c['enabled']]
    summary=dict(rooms=len(rooms),layouts=len(layout_ids),unique_objects=len(unique_objects),room_objects=sum(r['tags'] for r in room_counts),
        contacts=len(contacts),enabled_contacts=len(enabled),disabled_contacts=len(contacts)-len(enabled),
        clear_approach_contacts=sum(c['approach_clear'] for c in enabled),blocked_approach_contacts=sum(not c['approach_clear'] for c in enabled),
        staging_ready_contacts=sum(c['ready_for_staging'] for c in enabled),furniture_pose_ids=len(requirements),
        concrete_pose_ids=len(pose_rows),semantic_families=len(brief['families']),catalog_orientations=len(coverage),used_orientations=sum(bool(c['instances']) for c in coverage))
    data=dict(schema_version=1,authoring_only=True,runtime_loaded=False,summary=summary,source_hashes={p:sha(p) for p in sorted(sources)},
        concrete_poses=pose_rows,semantic_families=brief['families'],rooms=room_counts,orientation_coverage=coverage)
    outputs={'assets/characters/poses/pose-requirements.json':json.dumps(data,indent=2,ensure_ascii=False)+'\n',
        OUT+'furniture-contact-map.json':json.dumps(dict(schema_version=1,authoring_only=True,coordinate_contract='background local -> uniform fit Rect2(0,24,480,320); clearance is local to contact',contacts=contacts),indent=2,ensure_ascii=False)+'\n',
        OUT+'furniture-contact-map.csv':csv_text(contacts,list(contacts[0])),
        OUT+'orientation-coverage.csv':csv_text(coverage,list(coverage[0]))}
    md=['# Exact furniture-to-pose mapping','',
        'Derived from every current room and registered annotation. This file is generated by `python tools/audit_character_poses.py`; edit source tags in the mapper, then rerun. It does not change game state or artwork.', '',
        f'{summary["rooms"]} rooms, {summary["layouts"]} layouts, {summary["unique_objects"]} unique objects, {summary["room_objects"]} room instances; {summary["enabled_contacts"]} enabled and {summary["disabled_contacts"]} disabled contacts.', '',
        f'{summary["clear_approach_contacts"]} enabled approaches have a locally clear player-foot footprint; {summary["blocked_approach_contacts"]} fail that test. None are staging-approved. Local clearance does not establish path reachability, body/skirt fit, occupancy, occlusion or contact alignment.', '',
        '[Complete CSV](furniture-contact-map.csv) and [JSON](furniture-contact-map.json) include exact type/orientation, room/object/anchor IDs, furniture and actor facing, local/world points, contact landmark, props/hand usage, clearance, targets and mask status. [All 84 orientation IDs](orientation-coverage.csv) distinguish current use from catalog-only variants.', '']
    for room_id,room in rooms.items():
        md += ['## '+room['name']+' — `'+room_id+'`','',
            '| Furniture instance / anchor | Orientation | Actor / landmark | State / approach | Required pose IDs |',
            '| --- | --- | --- | --- | --- |']
        for c in [c for c in contacts if c['room_id']==room_id]:
            actor=(c['body_axis']+' / head '+c['head_toward']) if c['posture']=='lying' else c['actor_facing']
            state=c['status']+(' / local-clear' if c['approach_clear'] is True else ' / blocked' if c['approach_clear'] is False else '')
            md.append('| `'+c['instance_id']+'` / `'+c['anchor_id']+'` | `'+c['orientation_id']+'` | '+actor+' / '+c['contact_kind']+' | '+state+' | '+(', '.join('`'+p+'`' for p in c['pose_ids']) or 'None; excluded')+' |')
        md.append('')
    outputs[OUT+'FURNITURE_POSE_MAPPING.md']='\n'.join(md)+'\n'
    matrix=['# Master concrete pose matrix','',
        f'{len(requirements)} exact furniture pose IDs plus common directional conversation coverage give {len(pose_rows)} concrete requirements. Semantic emotion/event families are listed separately in [the main audit](../CHARACTER_POSE_AUDIT.md); this is not the full future reaction library.', '',
        'Current Char progress is read from her production manifest. Exported drafts are review candidates, not approved runtime poses. Her approved appearance alone does not approve all directions. See [the alignment review](../CHAR_ALIGNMENT_01_REVIEW.md).', '',
        '| Pose ID | Scope | Source contacts | Batch | Char asset / approval |','| --- | --- | ---: | --- | --- |']
    for p in pose_rows:
        matrix.append(f'| `{p["id"]}` | {p["scope"]} | {len(p["source_contacts"])} | {p["batch"]} | {p["char_asset_status"]} / {p["approval"]} |')
    outputs[OUT+'MASTER_POSE_MATRIX.md']='\n'.join(matrix)+'\n'
    char=next(e for e in read('assets/characters/review-v8/cast-catalog.json')['entries'] if e['number']=='01')
    manifest=dict(schema_version=1,authoring_only=True,runtime_loaded=False,character_id=char['identity_id'],review_number='01',name='Char',
        status='planning_only_no_new_art',personality='unassigned',guilt='case_dependent_unassigned',
        sources=[dict(path=p,sha256=sha(p),purpose=purpose) for p,purpose in [
            ('res://assets/characters/prototype/cast-01.png','Existing identity reference; not a validated directional pose set'),
            (char['variants'][0]['source'],'User-selected Party I; crop_grid [3,2,1], panel_crop [0.2,0,0.68,0.99]')]],
        identity_selection=dict(user_selected_primary=True,final_cast_approved=False,new_pose_approvals=[]),
        canonical_references=['01 Char','13 Sarah Jo','07 Kwinn','06 Chris'],
        metrics=dict(existing_reference_canvas=[252,472],existing_opaque_bounds=[0,0,252,472],existing_adult_height=64,height_ratio=1.0,
            source_pixels_per_logical_pixel=7.375,new_pose_canvas=None,padding=None,standing_reference_height=None,contact_landmarks=None,
            note='New export dimensions and reference scale must be approved; seated/crouched bounds must not be normalized to standing height.'),
        pose_requirements=[dict(pose_id=p['id'],status='planned',source_contacts=p['source_contacts'],batch=p['batch'],
            source_artwork=None,master_artwork=None,final_asset=None,landmarks=None,furniture_fit=[],generation_runs=[],approval='not_requested',approval_record=None,supersedes=None) for p in pose_rows],
        semantic_requirements=[dict(family_id=f['id'],status='excluded_other_identity' if f['id']=='chris_hat_scratch' else 'planned_pending_applicability_and_orientation',
            exclusion_reason='Chris-only signature; never copy to Char' if f['id']=='chris_hat_scratch' else None,
            generated_art=[],approved_art=[],selected_personality=None) for f in brief['families']],
        artifacts=[],generation_runs=[],revision_log=[],approval_log=[],
        holds=['Planning-only instruction: do not generate artwork','First batch and facing/contact/scale review required','Personality and mystery role not assigned','Nonstanding renderer/contact adapter not implemented'],
        production_complete=False)
    return outputs,manifest,summary

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check',action='store_true')
    args=parser.parse_args()
    outputs,manifest,summary=build()
    for path,body in outputs.items():
        target=ROOT/path
        if args.check:
            assert target.exists() and target.read_text(encoding='utf-8')==body,'Stale report: '+path
        else:
            target.parent.mkdir(parents=True,exist_ok=True)
            target.write_text(body,encoding='utf-8')
    target=ROOT/MANIFEST
    if not target.exists() and not args.check:
        target.parent.mkdir(parents=True,exist_ok=True)
        target.write_text(json.dumps(manifest,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
    saved=read(MANIFEST)
    assert saved['character_id']==manifest['character_id'] and saved['authoring_only']
    assert len({p['pose_id'] for p in saved['pose_requirements']})==len(saved['pose_requirements'])
    expected={p['pose_id'] for p in manifest['pose_requirements']}
    recorded={p['pose_id'] for p in saved['pose_requirements']}
    assert expected<=recorded,'Manifest needs a reviewed additive requirement update; existing production records were preserved.'
    for source in saved['sources']:
        assert sha(source['path'])==source['sha256'],'Identity source changed: review rather than silently replacing its hash'
    print(json.dumps(dict(ok=True,check_only=args.check,**summary)))

if __name__=='__main__':
    main()
