"""Local, pending-fit-only polygon editor. Run from any directory; open printed URL."""
import argparse
import hashlib
import json
import math
import os
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

ROOT = Path(__file__).resolve().parents[1]
CONFIG = 'assets/characters/poses/char/remaining-seat-fit-review.json'

def read(path):
    return json.loads(path.read_text(encoding='utf-8'))

def fingerprint(config, layout):
    return hashlib.sha256(config.read_bytes()+layout.read_bytes()).hexdigest()

def seat_revision(sample, layout, instance, anchor):
    # Another seat in the same JSON files must not invalidate this editor's copy.
    data={'sample':sample,'background':layout.get('background'),
          'artwork_sha256':layout.get('artwork_sha256'),
          'position':instance.get('position'),'anchor':anchor}
    return 'seat:'+hashlib.sha256(json.dumps(data,sort_keys=True).encode()).hexdigest()

RECOVERY = {}

def context(root, sample_id):
    config_path = root/CONFIG
    config = read(config_path)
    sample = next((s for s in config['samples'] if s['id']==sample_id), None)
    if not sample or sample['status']!='preview_candidate' or sample['approval']=='approved':
        raise ValueError('Only pending seating candidates can be edited.')
    layout_path = (root/sample['layout'].removeprefix('res://')).resolve()
    if not layout_path.is_relative_to((root/'assets/furniture/layouts').resolve()):
        raise ValueError('Invalid furniture layout.')
    layout = read(layout_path)
    instance = next(i for i in layout['instances'] if i['id']==sample['contact_source']['instance_id'])
    anchor = next(a for a in instance['anchors'] if a['id']==sample['contact_source']['anchor_id'])
    if not anchor.get('enabled',True):
        raise ValueError('This contact is disabled.')
    return config_path,config,sample,layout_path,layout,instance,anchor

def validate_polygons(polygons):
    if not isinstance(polygons,list) or len(polygons)>40:
        raise ValueError('Use at most 40 masks.')
    def cross(a,b,c):
        return (b[0]-a[0])*(c[1]-a[1])-(b[1]-a[1])*(c[0]-a[0])
    for poly in polygons:
        if not isinstance(poly,list) or not 3<=len(poly)<=100:
            raise ValueError('Each mask needs 3–100 points.')
        for point in poly:
            if not isinstance(point,list) or len(point)!=2 or any(type(v) not in (int,float) or not math.isfinite(v) for v in point):
                raise ValueError('Mask coordinates must be finite numbers.')
            if not 0<=point[0]<=480 or not 0<=point[1]<=320:
                raise ValueError('Keep every point inside the room.')
        if len({tuple(p) for p in poly})!=len(poly):
            raise ValueError('A mask cannot repeat a point.')
        area=sum(a[0]*b[1]-b[0]*a[1] for a,b in zip(poly,poly[1:]+poly[:1]))
        if abs(area)<0.02:
            raise ValueError('Mask has no usable area.')
        for i in range(len(poly)):
            for j in range(i+1,len(poly)):
                if j==i+1 or (i==0 and j==len(poly)-1):continue
                a,b=poly[i],poly[(i+1)%len(poly)];c,d=poly[j],poly[(j+1)%len(poly)]
                if max(min(a[0],b[0]),min(c[0],d[0]))>min(max(a[0],b[0]),max(c[0],d[0])):continue
                if max(min(a[1],b[1]),min(c[1],d[1]))>min(max(a[1],b[1]),max(c[1],d[1])):continue
                if cross(a,b,c)*cross(a,b,d)<=0 and cross(c,d,a)*cross(c,d,b)<=0:
                    raise ValueError('Mask edges cross or touch. Move the points apart.')

def save_masks(root, payload, recovery=None):
    cp,config,sample,lp,layout,instance,anchor=context(root,payload['id'])
    current=seat_revision(sample,layout,instance,anchor)
    recovering=(recovery is not None and recovery.get(sample['id'])==current)
    if payload.get('revision') not in (current,fingerprint(cp,lp)) and not recovering:
        raise ValueError('Files changed since this seat loaded. Reload before saving.')
    polygons=payload['polygons'];validate_polygons(polygons)
    if 'contact' in payload:
        contact=payload['contact']
        if (not isinstance(contact,list) or len(contact)!=2 or
            any(type(v) not in (int,float) or not math.isfinite(v) for v in contact) or
            not 0<=contact[0]<=480 or not 0<=contact[1]<=320):
            raise ValueError('Seat contact must remain inside the room.')
        anchor['contact']=[round(contact[n]-instance['position'][n],3) for n in range(2)]
        sample['contact']=contact
        record=read(root/sample['landmark_record'])
        sample['estimated_feet_background_local']=[round(contact[n]+(
            record['source_landmarks']['feet'][n]+record['export_padding'][n]-
            record['export_contact'][n])*80/1673,3) for n in range(2)]
    sample['foreground_polygons']=polygons
    sample['approval']='pending'
    sample['captures_status']='stale_after_manual_mask_edit'
    sample['mask_edit']={'method':'visual_drag_editor','status':'pending_fit_review','shared_furniture_mask':True}
    anchor.setdefault('fit_review',{}).update(foreground_polygons=polygons,
        mask_coordinate_space='background_local',shared_across_characters=True,
        status='manual_mask_pending_visual_review',runtime_enabled=False)
    # Two files are written from validated copies; restore originals if the second fails.
    old_cp,old_lp=cp.read_bytes(),lp.read_bytes()
    try:
        for path,data in [(lp,layout),(cp,config)]:
            temp=path.with_suffix(path.suffix+'.mask-edit.tmp')
            temp.write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
            os.replace(temp,path)
    except OSError:
        cp.write_bytes(old_cp);lp.write_bytes(old_lp)
        raise
    if recovering:recovery.pop(sample['id'],None)
    return {'ok':True,'revision':seat_revision(sample,layout,instance,anchor),'message':'Saved shared seat position and masks. Static screenshot galleries need recapturing; this editor shows the saved fit live.'}

class Handler(SimpleHTTPRequestHandler):
    def __init__(self,*args,**kwargs):
        super().__init__(*args,directory=str(ROOT),**kwargs)
    def reply(self,value,status=200):
        data=json.dumps(value).encode()
        self.send_response(status);self.send_header('Content-Type','application/json');self.send_header('Cache-Control','no-store');self.end_headers();self.wfile.write(data)
    def do_GET(self):
        path=urlsplit(self.path).path
        if path=='/api/seats':
            result=[]
            for s in read(ROOT/CONFIG)['samples']:
                if s['status']!='preview_candidate' or s['approval']=='approved':continue
                cp,c,s,lp,l,i,a=context(ROOT,s['id'])
                record=read(ROOT/s['landmark_record'])
                result.append(dict(id=s['id'],label=s['label'],contact_id=s['contact_id'],
                    background='/'+s['background'].removeprefix('res://'),asset='/'+s['asset'],
                    contact=[i['position'][n]+a['contact'][n] for n in range(2)],
                    landmark=record['export_contact'],scale=80/1673,
                    polygons=a.get('fit_review',{}).get('foreground_polygons',s['foreground_polygons']),
                    revision=seat_revision(s,l,i,a)))
            return self.reply(result)
        if path=='/':self.path='/tools/mask-editor/index.html'
        elif not path.startswith(('/assets/','/tools/mask-editor/')):
            return self.send_error(404)
        return super().do_GET()
    def do_POST(self):
        if self.path!='/api/save':return self.send_error(404)
        expected='http://'+self.headers.get('Host','')
        if self.headers.get('Origin')!=expected or not self.headers.get('Content-Type','').startswith('application/json'):
            return self.reply({'error':'Use Save from this local editor.'},403)
        try:
            length=int(self.headers.get('Content-Length','0'))
            if not 0<length<200000:raise ValueError('Invalid request size.')
            result=save_masks(ROOT,json.loads(self.rfile.read(length)),RECOVERY)
            self.reply(result)
        except (ValueError,KeyError,TypeError,OSError) as exc:
            self.reply({'error':str(exc)},400)

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--port',type=int,default=8766)
    parser.add_argument('--recover-unsaved-seat',help='One-shot recovery of an open pre-fix editor; guards against changes after startup.')
    args=parser.parse_args()
    if args.recover_unsaved_seat:
        cp,c,s,lp,l,i,a=context(ROOT,args.recover_unsaved_seat)
        RECOVERY[s['id']]=seat_revision(s,l,i,a)
    server=ThreadingHTTPServer(('127.0.0.1',args.port),Handler)
    print(f'Foreground mask editor: http://127.0.0.1:{args.port}/tools/mask-editor/index.html',flush=True)
    server.serve_forever()
