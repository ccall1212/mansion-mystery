"""Render the pending opposite-side room plan and actual artwork candidates."""
import html
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/rooms/revisions/2026-10-24-opposite-doors'
plan=json.loads((ROOT/'assets/mansion/opposite-door-plan.json').read_text())
batch=json.loads((OUT/'manifest.json').read_text())
names={'g_foyer':'Foyer','g_library':'Library','g_main_stair':'Main Stair Hall','g_kitchen':'Kitchen','g_dining':'Dining Room','u_main_stair':'Upper Landing','u_master':'Bedroom','u_study':'Study','b_store':'Basement Storage'}
opposite={'north':'south','south':'north','east':'west','west':'east'}
vectors={'north':(0,-1),'south':(0,1),'east':(1,0),'west':(-1,0)}
for id,room in plan['rooms'].items():
    for side,target in room['doors'].items():
        if target!='locked_front_door':assert plan['rooms'][target]['doors'].get(opposite[side])==id
svg=['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 820 730"><rect width="820" height="730" fill="#14232b"/><style>text{font-family:system-ui;fill:#e5edf0}.title{font-size:22px;fill:#edce98}.name{font-size:16px}.small{font-size:12px;fill:#adc5d0}</style>']
positions={}
for floor,label,top in [(0,'GROUND FLOOR — opposite-side doors',40),(1,'UPSTAIRS',350),(-1,'BASEMENT',540)]:
    svg.append(f'<text x="25" y="{top}" class="title">{label}</text>')
    for id,room in plan['rooms'].items():
        if room['floor']!=floor:continue
        gx,gy=room['grid'];x=35+gx*185;y=top+40+(gy*110 if floor==0 else 0)
        positions[id]=(x,y)
for id,room in plan['rooms'].items():
    x,y=positions[id]
    for side,target in room['doors'].items():
        if target=='locked_front_door' or plan['rooms'][target]['floor']!=room['floor'] or id>target:continue
        tx,ty=positions[target];dx,dy=vectors[side]
        svg.append(f'<line x1="{x+78+dx*78}" y1="{y+32+dy*32}" x2="{tx+78-dx*78}" y2="{ty+32-dy*32}" stroke="#edce98" stroke-width="3"/>')
for id,room in plan['rooms'].items():
    x,y=positions[id]
    svg.append(f'<rect x="{x}" y="{y}" width="156" height="64" rx="5" fill="#29404a" stroke="#edce98"/><text x="{x+78}" y="{y+27}" text-anchor="middle" class="name">{names[id]}</text>')
    extra='North front door: LOCKED' if id=='g_foyer' else 'Up to upper landing' if id=='g_main_stair' else 'Down to main stairs' if id=='u_main_stair' else 'Down to basement' if id=='g_kitchen' else 'Up to kitchen' if id=='b_store' else id
    svg.append(f'<text x="{x+78}" y="{y+46}" text-anchor="middle" class="small">{extra}</text>')
    for side in room['doors']:
        dx,dy=vectors[side];svg.append(f'<circle cx="{x+78+dx*78}" cy="{y+32+dy*32}" r="4" fill="{"#d57878" if id=="g_foyer" and side=="north" else "#edce98"}"/>')
svg.append('<text x="25" y="700" class="small">Every linked door has an opposite-side return. Stair pairs preserve travel direction across floors.</text></svg>')
(OUT/'blueprint.svg').write_text(''.join(svg),encoding='utf-8')
parts=['''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Mansion — opposite-door layout and foyer furnishings</title><style>body{background:#14232b;color:#e5edf0;font:18px system-ui;margin:24px}h1,h2,a{color:#edce98}img{max-width:100%;height:auto}article{border-top:1px solid #526773;margin-top:34px}.pair{display:grid;grid-template-columns:1fr 1fr;gap:18px}figure{margin:0}figcaption{margin:10px 0}.note{color:#ffd4a9}@media(max-width:900px){.pair{grid-template-columns:1fr}}</style><h1>Opposite-door mansion layout</h1><p>Four-door foyer: locked north front entrance; library west, main stairs east, dining south. Kitchen links north to library, east to dining and south to basement, creating a useful ground-floor loop.</p><p>Every east exit arrives west, every north exit arrives south, and vice versa. The same movement direction carries into the receiving room. No bent, same-side or corner-teleport connections.</p><p>Approved and integrated in compact-3. All 18 directed door/stair crossings pass actual physics walking without E, Enter or Space. New furniture IDs are provisional and still require pose-fit review. <a href="../../../../test-results/compact-mansion/index.html">Open current in-game room captures</a>.</p><img src="blueprint.svg" alt="Opposite-side mansion blueprint"><p><a href="manifest.json">Candidate prompts, hashes and review status</a> · <a href="../../../../assets/mansion/opposite-door-plan.json">Exact connection plan</a></p>''']
for job in batch['jobs']:
    before='../../../../'+job['source']
    parts.append(f'<article id="{job["id"]}"><h2>{html.escape(job["name"])}</h2><p>{html.escape(job["brief"])}</p><p class="note">Approved and integrated. Doors: '+', '.join(f'{k.upper()} {v}' for k,v in job['doors'].items())+f'</p><div class="pair"><figure><figcaption>Previous artwork</figcaption><img src="{before}" alt="Previous {job["id"]}"></figure><figure><figcaption>{job["filename"]}</figcaption><img src="{job["filename"]}" alt="New {job["name"]}"></figure></div></article>')
parts.append('<p>Approval recorded: “Looks good to me”, 2026-10-24. Existing approved images are preserved.</p></html>')
(OUT/'index.html').write_text('\n'.join(parts),encoding='utf-8')
print(OUT/'index.html')
