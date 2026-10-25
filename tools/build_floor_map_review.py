"""Build the local floor-map presentation preview from native captures."""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
out=ROOT/'test-results/floor-map'
parts=['''<!doctype html><html lang="en"><meta charset="utf-8"><title>Mansion floor map preview</title><style>body{font:18px system-ui;background:#14232b;color:#e5edf0;margin:24px}h1,h2{color:#edce98}img{max-width:100%;height:auto}</style><h1>Current-floor map — local preview</h1><p>Gold marks your current room; teal marks visited rooms. Links come from the same room data used by doors. UP/DN marks stairs between floors. Room counts exclude circulation spaces such as the stair hall and landing.</p><p>This is a connection diagram rather than an architectural blueprint. It hides during dialogue, inspections, case menus and Char's dedicated pose test. TAB still opens the full room directory.</p>''']
for key,label in [('g_library','Ground floor — four main rooms'),('u_master','Upstairs — two main rooms'),('b_store','Basement — one main room')]:
    assert (out/(key+'.png')).exists()
    parts.append(f'<h2>{label}</h2><img src="{key}.png" alt="{label} map preview">')
(out/'index.html').write_text('\n'.join(parts)+'</html>',encoding='utf-8')
print(out/'index.html')
