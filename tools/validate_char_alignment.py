"""Validate Char alignment_01 provenance, shared scale and pixel-preserving exports.

These checks do not approve likeness, directional art, anatomical side placement,
furniture fit, collision, navigation, foreground masks or runtime integration.
"""
import hashlib
import json
from pathlib import Path
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'assets/characters/poses/char'

def load(path):
    return json.loads(path.read_text(encoding='utf-8'))

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    batch=load(BASE/'batches/alignment_01.json')
    expected={'standing_idle_'+d for d in ['north','east','south','west']}|{'seated_idle_'+d for d in ['east','south','west']}
    assert {j['pose_id'] for j in batch['jobs']}==expected and len(batch['jobs'])==7
    contacts={c['key']:c for c in load(ROOT/'docs/pose-audit/furniture-contact-map.json')['contacts']}
    manifest=load(BASE/'production-manifest.json')
    metrics=[]
    for job in batch['jobs']:
        record=load(BASE/'prompts/alignment_01'/(job['pose_id']+'.json'))
        source=ROOT/record['source_master']
        assert digest(source)==record['source_sha256']
        assert record['tool']=='built-in image_gen.imagegen' and record['transparent_background']
        assert record['inputs'][0]['path']==manifest['approved_design_reference'].removeprefix('res://')
        for ref in record['inputs']:
            assert digest(ROOT/ref['path'])==ref['sha256']
        assert record['standing_reference_height']==1673
        assert record['logical_standing_height']==64
        assert record['source_units_to_logical_scale']==64/1673
        assert not record['auto_mirrored']
        assert record['prompt'] and 'POSE '+job['pose_id'] in record['prompt']
        image=Image.open(source).convert('RGBA')
        assert image.getchannel('A').getextrema()==(0,255)
        bounds=image.getchannel('A').point(lambda a:255 if a>=128 else 0).getbbox()
        assert list(bounds)==record['alpha_bounds']
        output=Image.open(ROOT/record['exported_draft']).convert('RGBA')
        assert output.size==(1045,1844)
        recovered=output.crop((64,64,64+image.width,64+image.height))
        assert recovered.tobytes()==image.tobytes(),'Export changed artwork: '+job['pose_id']
        alpha=output.getchannel('A')
        assert alpha.crop((0,0,1045,64)).getextrema()==(0,0)
        assert alpha.crop((0,0,64,1844)).getextrema()==(0,0)
        assert alpha.crop((1045-64,0,1045,1844)).getextrema()==(0,0)
        assert alpha.crop((0,1844-64,1045,1844)).getextrema()==(0,0)
        point=record['source_landmarks'][record['contact_kind']]
        assert record['export_contact']==[point[0]+64,point[1]+64]
        assert all(0<=value<limit for value,limit in zip(point,image.size))
        if record['fit_contact']:
            contact=contacts[record['fit_contact']]
            assert contact['enabled'] and contact['actor_facing']==job['pose_id'].split('_')[-1]
            assert contact['contact_kind']=='seat' and contact['approach_clear']
        metrics.append({'pose_id':job['pose_id'],'source_canvas':list(image.size),'opaque_height':bounds[3]-bounds[1],
            'logical_occupied_height':round((bounds[3]-bounds[1])*64/1673,3),'pixel_preserving_export':True,
            'contact_kind':record['contact_kind'],'fit_contact':record['fit_contact']})
        assert any(r['job_id']==record['job_id'] for r in manifest['generation_runs'])
        assert next(p for p in manifest['pose_requirements'] if p['pose_id']==job['pose_id'])['candidate_export']==record['exported_draft']
    seated=[r['opaque_height'] for r in metrics if r['pose_id'].startswith('seated')]
    standing=[r['opaque_height'] for r in metrics if r['pose_id'].startswith('standing')]
    assert max(seated)<min(standing)
    for name,size in [('comparison.png',(1600,1180)),('context-closeups.png',(1500,700))]+[(p+'--context.png',(1440,960)) for p in expected if p.startswith('seated')]:
        assert Image.open(BASE/'review/alignment_01'/name).size==size
    log=(ROOT/'test-results/char-alignment-review.log').read_text()
    assert 'CHAR_ALIGNMENT_REVIEW_OK' in log and 'SCRIPT ERROR' not in log and 'ERROR:' not in log
    result=dict(ok=True,poses=7,shared_source_reference_height=1673,logical_standing_height=64,
        padded_exports=7,native_review_images=5,metadata=metrics,
        visual_user_approval=all(next(p for p in manifest['pose_requirements'] if p['pose_id']==j['pose_id'])['approval']=='approved' for j in batch['jobs']),
        approval_evidence='production manifest; explicit user approval, not inferred by validator',runtime_integrated=False,chair_masks_available=False,
        limitations=['Artist-estimated landmarks','Manual contact landmarks remain provisional','No runtime contact/mask/navigation/occupancy validation','Final presentation/export standard undecided'])
    (ROOT/'test-results/char-alignment-validation.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result))

if __name__=='__main__':
    main()
