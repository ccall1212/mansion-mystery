"""Publish native idle-portrait captures for immediate user review."""
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'test-results/dialogue-portraits'
speakers = [('char','Char'),('justin','Justin'),('chris','Chris'),('gage','Gage'),
            ('sarah_jo','Sarah Jo'),('jessica','Jessica'),('john','John'),('eleanor','Eleanor')]
parts = ['''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Sleuth — enlarged idle dialogue portraits</title>
<style>body{font:18px system-ui;background:#17242b;color:#e1e9eb;margin:28px;max-width:1280px}a,h1,h2{color:#edce98}img{width:100%;image-rendering:pixelated}article{margin:36px 0}</style>
<h1>Enlarged idle dialogue portraits</h1><p>Actual engine captures for all eight current in-game speakers. Existing sprite, pose and expression are reused without new artwork or mirroring. Portraits sit behind the dialogue panel; transparent padding is excluded from framing.</p>
<p>The case conversation uses a lower dialogue panel. Ordinary guest statements and Eleanor's questions also show portraits. Close the conversation to dismiss the portrait. Turning, new expressions and the countdown remain future work. A guest omitted by the random room-placement rules is shown in a temporary preview fixture; the preview does not change saves or the roster rules.</p>
<p>Shared 3× enlargement relative to character world stature, with an aspect-preserving screen-fit cap. South/north currently use the left side; authored west-facing poses use the right.</p>''']
for stem,name in speakers:
    assert (OUT/(stem+'.png')).is_file(), stem
    parts.append(f'<article><h2>{name}</h2><img src="{stem}.png" alt="{name} enlarged idle conversation preview"></article>')
(OUT/'index.html').write_text('\n'.join(parts)+'</html>',encoding='utf-8')
print(OUT/'index.html')
