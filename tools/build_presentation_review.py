"""Build a native-capture comparison; never edit character/background source pixels."""
import html
import json
import shutil
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / 'test-results/presentation-review'


def main():
    OUTPUT.mkdir(exist_ok=True)
    lines = ['<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">',
        '<title>Char — larger HD presentation review</title>',
        '<style>body{background:#17242b;color:#e6edef;font:18px system-ui;margin:26px}h1,h2,a{color:#efd19b}.pair{display:grid;grid-template-columns:repeat(auto-fit,minmax(360px,1fr));gap:22px}img{width:100%;height:auto}article{margin:32px 0}button{font:inherit;padding:10px}body.native img{width:auto;max-width:none}.panel{overflow:auto;background:#27343c;padding:14px}p{max-width:1100px}</style>',
        '<h1>Char — larger HD presentation</h1>',
        '<p>Review proposal: 960×720 internal viewport, up to 1280×960 window, shared adult height 80 instead of 64, and a 1.5× detail camera. Source artwork and room/physics coordinates are unchanged.</p>',
        '<p><b>In the game:</b> Z = detail/overview · F11 = fullscreen · F7 = find Char · F8 = new pose/room. Move to return the camera to the detective. Chair masks/contact calibration still need visual review.</p>',
        '<button onclick="document.body.classList.toggle(\'native\')">Toggle native-pixel / fit-to-panel images</button>',
        '<p><a href="../char-live-test/index.html">All seven updated live poses</a> · Click any screenshot to open it separately. Other guests may differ between runs.</p>']
    pairs = []
    for pose, title in [('seated_idle_south','Library chair'),('seated_idle_west','Foyer chair')]:
        before = OUTPUT / ('before_'+pose+'.png')
        after = OUTPUT / ('after_'+pose+'.png')
        shutil.copyfile(ROOT/'test-results/char-live-test'/('char_'+pose+'_preview.png'),after)
        assert Image.open(before).size == (960,720)
        assert Image.open(after).size == (1280,960)
        pairs.append({'pose':pose,'before':before.name,'after':after.name})
        lines.append('<article><h2>'+html.escape(title)+'</h2><div class="pair">')
        for label,path in [('Before — full-room view, smaller characters',before),('After — HD detail view, larger shared scale',after)]:
            lines.append('<div class="panel"><h3>'+label+'</h3><a href="'+path.name+'"><img src="'+path.name+'" alt="'+html.escape(label)+'"></a></div>')
        lines.append('</div></article>')
    lines.append('</html>')
    (OUTPUT/'index.html').write_text('\n'.join(lines),encoding='utf-8')
    (OUTPUT/'review.json').write_text(json.dumps({'status':'awaiting_user_presentation_review','internal_viewport':[960,720],
        'default_window':[1280,960],'reference_coordinates':[480,360],'shared_adult_height':80,
        'detail_zoom':1.5,'pairs':pairs,'source_artwork_modified':False},indent=2)+'\n',encoding='utf-8')
    print('Presentation review: test-results/presentation-review/index.html')


if __name__ == '__main__':
    main()
