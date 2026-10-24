"""Validate planning references and compare contact results with native Godot evidence.

Run the audit generator first. If the capture report is absent/stale, regenerate
it using tools/capture_tagged_rooms.gd; this script does not launch or alter a game.
"""
import csv
import hashlib
import json
import re
from pathlib import Path
from audit_character_poses import ROOT, build

def load(path):
    return json.loads((ROOT/path).read_text(encoding='utf-8'))

def main():
    outputs,_,summary=build()
    for path,text in outputs.items():
        assert (ROOT/path).read_text(encoding='utf-8')==text,'Regenerate stale report: '+path
    contacts=load('docs/pose-audit/furniture-contact-map.json')['contacts']
    native=load('test-results/tagged-room-coverage.json')
    assert native['ok']
    prior={c['key']:c for room in native['rooms'] for c in room['contacts']}
    enabled={c['key']:c for c in contacts if c['enabled']}
    assert set(enabled)==set(prior),'Native report must be regenerated for changed tags'
    for key,contact in enabled.items():
        assert contact['approach_clear']==prior[key]['approach_clear'],key
        assert contact['pose_ids']==prior[key]['pose_ids'],key
    for contact in contacts:
        assert contact['enabled'] or not contact['pose_ids']
        assert (ROOT/contact['layout'].removeprefix('res://')).is_file()
        if contact['posture']=='lying':
            assert contact['body_axis'] in ['north_south','east_west']
        else:
            assert contact['actor_facing'] in ['north','east','south','west']
    with (ROOT/'docs/pose-audit/furniture-contact-map.csv').open(newline='',encoding='utf-8') as stream:
        rows=list(csv.DictReader(stream))
    assert {r['key'] for r in rows}=={c['key'] for c in contacts}
    assert len(rows)==len(contacts)
    inventory=load('assets/characters/poses/pose-requirements.json')
    poses={p['id'] for p in inventory['concrete_poses']}
    assert {p for c in contacts for p in c['pose_ids']}<=poses
    brief=load('assets/characters/poses/requirements-brief.json')
    assert len({f['id'] for f in brief['families']})==len(brief['families'])
    for family in brief['families']:
        assert (ROOT/family['source'].split('#')[0]).is_file()
    manifest=load('assets/characters/poses/char/production-manifest.json')
    assert {p['pose_id'] for p in manifest['pose_requirements']}>=poses
    assert {f['family_id'] for f in manifest['semantic_requirements']}=={f['id'] for f in brief['families']}
    for source in manifest['sources']:
        path=ROOT/source['path'].removeprefix('res://')
        assert hashlib.sha256(path.read_bytes()).hexdigest()==source['sha256']
    for artifact in manifest['artifacts']:
        path=ROOT/artifact['path'].removeprefix('res://')
        assert path.is_file(),artifact['path']
        assert hashlib.sha256(path.read_bytes()).hexdigest()==artifact['sha256'],'Update reviewed artifact record: '+artifact['path']
    batch=load('assets/characters/poses/char/batches/alignment_01.json')
    assert len(batch['jobs'])==7 and len({j['pose_id'] for j in batch['jobs']})==7
    for job in batch['jobs']:
        assert job['pose_id'] in poses
        if job['fit_contact']:
            assert enabled[job['fit_contact']]['approach_clear']
    directional=load('assets/characters/poses/char/directional-index.json')
    assert directional['authoring_only'] and not directional['runtime_loaded']
    assert set(directional['direction_groups'])=={'north','east','south','west'}
    indexed={a['pose_id']:a for a in directional['assets']}
    assert set(indexed)=={j['pose_id'] for j in batch['jobs']}
    grouped=[p for group in directional['direction_groups'].values() for p in group]
    assert len(grouped)==len(set(grouped))==7 and set(grouped)==set(indexed)
    for job in batch['jobs']:
        asset=indexed[job['pose_id']]
        assert asset['actor_facing']==job['pose_id'].rsplit('_',1)[1]
        assert job['pose_id'] in directional['direction_groups'][asset['actor_facing']]
        assert asset['approval']==job['approval']=='approved'
        assert Path(asset['export']).parent.name == asset['actor_facing']
        assert Path(asset['export']).name == 'char_'+job['pose_id']+'_'+asset['variant_id']+'.png'
        assert asset['fit_contact']==job['fit_contact'] and not asset['runtime_integrated']
        for path_key,hash_key in [('source_master','source_sha256'),('export','export_sha256')]:
            assert hashlib.sha256((ROOT/asset[path_key]).read_bytes()).hexdigest()==asset[hash_key]
    links=0
    for name in ['CHARACTER_POSE_AUDIT.md','CHARACTER_REACTION_MATRIX.md','CHARACTER_MEASUREMENT_STANDARD.md',
                 'CHARACTER_POSE_PRODUCTION_WORKFLOW.md','CHARACTER_POSE_PRODUCTION_PROMPT.md',
                 'pose-audit/MASTER_POSE_MATRIX.md','pose-audit/FURNITURE_POSE_MAPPING.md','CHAR_POSE_PLAN.md',
                 'CHARACTER_DIRECTIONAL_PIPELINE_PLAN.md']:
        path=ROOT/'docs'/name
        for link in re.findall(r'\]\(([^)]+)\)',path.read_text(encoding='utf-8')):
            if '://' not in link:
                assert (path.parent/link.split('#')[0]).resolve().exists(),(name,link)
                links+=1
    result=dict(ok=True,godot_contact_parity=len(enabled),csv_contacts=len(rows),pose_ids=len(poses),
        semantic_families=len(brief['families']),char_proposed_samples=len(batch['jobs']),local_doc_links=links,
        production_artifacts=len(manifest['artifacts']),summary=summary)
    (ROOT/'test-results').mkdir(exist_ok=True)
    (ROOT/'test-results/character-pose-audit-validation.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(result))

if __name__=='__main__':
    main()
