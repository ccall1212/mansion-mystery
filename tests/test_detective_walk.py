"""Protect original vertical artwork and user-supplied gait through atlas cleanup."""
import hashlib
import json
from pathlib import Path
from PIL import Image
import pytest
import server

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT/'assets/characters/detective-walk-v1'


def test_original_and_user_art_preserved():
    manifest = json.loads((BASE/'manifest.json').read_text())
    original = ROOT/'assets/foyer/investigator-sheet.png'
    # The canonical original is protected by its recorded hash; cleanup removes
    # redundant copies rather than requiring a second identical image forever.
    assert manifest['up_down_source'] == 'res://assets/foyer/investigator-sheet.png'
    assert hashlib.sha256(original.read_bytes()).hexdigest() == manifest['original_sha256']
    user = Image.open(BASE/'masters/user-corrected-horizontal.png').convert('RGB')
    cleaned = Image.open(BASE/'cleaned-user-sheet.png').convert('RGBA')
    assert user.size == cleaned.size
    pixels, source = cleaned.load(), user.load()
    changed = 0
    for y in range(2,cleaned.height-2):
        for x in range(2,cleaned.width-2):
            r,g,b,a = pixels[x,y]
            if not a or (r,g,b) == source[x,y]:
                continue
            # Every recoloured pixel must be red fringe within two pixels of alpha.
            sr,sg,sb = source[x,y]
            assert sr+1 > sg*2.8 and sr+1 > sb*2.8  # float/byte threshold rounding
            assert any(pixels[x+dx,y+dy][3] == 0 for dx,dy in [(-2,0),(2,0),(0,-2),(0,2)])
            changed += 1
    extraction = json.loads((BASE/'extraction.json').read_text())
    assert changed == extraction['fringe_pixels'] and changed > 0
    assert len(extraction['frames']) == 8
    assert manifest['standing_height_ratio'] == 246/254


def test_detective_walk_in_godot():
    executable = server.config().get('godot_gui') or server.config().get('godot')
    if not executable or not Path(executable).is_file():
        pytest.skip('Godot not configured')
    report = ROOT/'test-results/detective-walk-tests.json'
    report.unlink(missing_ok=True)
    result = server.run_bounded([executable,'--headless','--path',str(ROOT),'--script',
        'tools/detective_walk_checks.gd','--','--npc-seed=20261023'],ROOT,55)
    assert result['ok'] and 'SCRIPT ERROR' not in result['stderr'], result
    data = json.loads(report.read_text())
    assert data['ok'] and data['checks'] >= 60, data
