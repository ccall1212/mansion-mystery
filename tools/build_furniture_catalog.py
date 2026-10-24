"""Build orientation metadata only; never rotate or generate furniture artwork."""
import json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
DIRECTIONS = {'north':(0,-1),'east':(1,0),'south':(0,1),'west':(-1,0)}
OPPOSITE = {'north':'south','south':'north','east':'west','west':'east'}
TYPES = {
 'chair':('Chair',40,48), 'armchair':('Armchair',56,60),
 'sofa':('Sofa',100,60), 'bar_stool':('Bar stool',28,40),
 'desk':('Desk',86,50), 'bookshelf':('Bookshelf',100,100),
 'table':('Table / reading stand',64,40), 'bar_counter':('Bar counter',120,62),
 'fireplace':('Fireplace',90,100), 'window':('Window',50,100),
 'doorway':('Doorway',70,100), 'bench':('Bench',76,36),
 'cabinet':('Cabinet / storage shelving',80,70), 'statue':('Statue',40,100),
 'crate':('Crate',40,40), 'barrel':('Barrel',32,42),
 'mirror':('Mirror',36,60), 'painting':('Painting',60,60),
 'stairway':('Stairway',100,110), 'clock':('Clock',32,80)}

def anchor(identity, contact, facing, posture, activities, approach=None, contact_kind='feet', **extra):
 return dict(id=identity,enabled=True,contact=contact,approach=approach if approach is not None else [contact[0],contact[1]+24],
             actor_facing=facing,posture=posture,activities=activities,contact_kind=contact_kind,
             clearance=[-12,-8,24,16],**extra)

def side_view_anchors(direction, w, h):
 # Side is the actor's location relative to the object, never furniture facing.
 # These are editable draft floor positions; they do not rotate the painted art.
 sides = ['west','east'] if direction in ['north','south'] else ['north','south']
 result = []
 for side in sides:
  dx,dy=DIRECTIONS[side]
  contact=[dx*(w/2+16),20] if dx else [DIRECTIONS[direction][0]*(w/2+16),-h-16 if dy<0 else 20]
  approach=[contact[0]+dx*16,contact[1]+dy*16]
  result.append(anchor('view_from_'+side,contact,OPPOSITE[side],'standing',['inspect','look_up'],approach,
      interaction_side=side,gaze_target=[0,-h*.5],visual_review='pending'))
 return result

variants={}
for kind,(label,w,h) in TYPES.items():
 for direction,(dx,dy) in DIRECTIONS.items():
  front=[dx*(w/2+16),dy*20]
  towards=OPPOSITE[direction]
  if kind in ['chair','armchair','sofa','bar_stool','bench']:
   seats=[(-w*.25,'seat_left'),(w*.25,'seat_right')] if kind=='sofa' else [(0,'seat')]
   anchors=[anchor(name,[x,-h*.38],direction,'seated',['idle','talk','read'] if kind!='bar_stool' else ['idle','talk','drink'],
                   [x+dx*(w/2+18),dy*24],contact_kind='seat') for x,name in seats]
  elif kind in ['cabinet','crate','barrel','mirror','statue','painting','stairway','clock']:
   activities = ['inspect','reach'] if kind=='cabinet' else ['inspect','look_up'] if kind in ['statue','painting','clock'] else ['idle','listen'] if kind=='stairway' else ['inspect']
   anchors=[anchor('inspect',front,towards,'standing',activities)]
  elif kind=='desk':
   anchors=[anchor('seated_work',[0,-h*.35],towards,'seated',['idle','read','write'],front,contact_kind='seat'),
            anchor('standing_work',front,towards,'standing',['inspect','read'])]
  elif kind=='bookshelf':
   anchors=[anchor('inspect',front,towards,'standing',['inspect','read','reach'])]
  elif kind=='fireplace':
   anchors=[anchor('stand',front,towards,'standing',['inspect','warm_hands']),
            anchor('kneel',front,towards,'kneeling',['inspect'],contact_kind='knees')]
  elif kind=='window':
   anchors=[anchor('look_out',front,towards,'standing',['look_out','inspect','look_up'],gaze_target=[0,-h*.5])]
  elif kind=='doorway':
   anchors=[anchor('inside',front,towards,'standing',['listen','inspect','peek']),
            anchor('outside',[-front[0],-front[1]],direction,'standing',['listen','inspect','peek'])]
  else:
   anchors=[anchor('use',front,towards,'standing',['inspect','read'] if kind=='table' else ['idle','talk','drink'])]
  if kind in ['window','painting','clock']:
   anchors += side_view_anchors(direction,w,h)
  identity=kind+'_'+direction
  variants[identity]=dict(id=identity,type=kind,label=label+' / '+direction,facing=direction,axis=None,headboard=None,
    asset_view='front' if direction=='south' else 'rear' if direction=='north' else 'side',
    bounds=[-w/2,-h,w,h],footprint=[-w/2,-12,w,12],anchors=anchors,
    required_target_type='bar_counter' if kind=='bar_stool' else None)
for head in DIRECTIONS:
 axis='east_west' if head in ['east','west'] else 'north_south'
 w,h=(120,72) if axis=='east_west' else (78,120)
 sides=['north','south'] if axis=='east_west' else ['west','east']
 anchors=[anchor('lie',[0,-h/2],None,'lying',['idle'],contact_kind='pelvis',body_axis=axis,head_toward=head)]
 for side in sides:
  dx,dy=DIRECTIONS[side]
  contact=[dx*w/2,-h/2+dy*h/2]
  approach=[contact[0]+dx*24,contact[1]+dy*24]
  anchors.append(anchor('sit_'+side,contact,side,'seated',['idle','talk','read'],approach,contact_kind='seat'))
 identity='bed_'+axis+'_head_'+head
 variants[identity]=dict(id=identity,type='bed',label='Bed / '+axis+' / head '+head,facing=None,axis=axis,headboard=head,
   asset_view='front',bounds=[-w/2,-h,w,h],footprint=[-w/2,-h,w,h],anchors=anchors,required_target_type=None)
result=dict(schema_version=1,directions=list(DIRECTIONS),description='Orientation IDs and provisional authoring templates. No furniture art, character poses, or automatic staging.',
 types={**{key:value[0] for key,value in TYPES.items()},'bed':'Bed'},variants=variants)
(ROOT/'assets/furniture/catalog.json').write_text(json.dumps(result,indent=2)+'\n')
print('Furniture orientation IDs:',len(variants))
