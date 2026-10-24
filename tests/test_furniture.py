"""Orientation vocabulary, background-local annotations and editor integration."""
import json
import subprocess
import sys
from pathlib import Path
import pytest
import server

ROOT = Path(__file__).resolve().parents[1]


def test_catalog_rebuild_and_orientation_contract():
    path = ROOT/'assets/furniture/catalog.json'
    before = path.read_bytes()
    subprocess.run([sys.executable,str(ROOT/'tools/build_furniture_catalog.py')],check=True,capture_output=True)
    assert path.read_bytes() == before
    catalog = json.loads(before)
    variants = catalog['variants']
    assert len(variants) == 84 and len(catalog['types']) == 21
    for kind in catalog['types']:
        selected = [v for v in variants.values() if v['type'] == kind]
        assert len(selected) == 4
        if kind == 'bed':
            assert {v['headboard'] for v in selected} == {'north','east','south','west'}
        else:
            assert {v['facing'] for v in selected} == {'north','east','south','west'}
    assert not any('left' in identity or 'right' in identity for identity in variants)
    window = variants['window_south']
    anchors = {a['id']: a for a in window['anchors']}
    assert anchors['view_from_west']['actor_facing'] == 'east'
    assert anchors['view_from_east']['actor_facing'] == 'west'
    assert 'look_up' in anchors['look_out']['activities']
    for kind in ['window', 'painting', 'clock']:
        for facing in ['north', 'east', 'south', 'west']:
            side = [a for a in variants[kind+'_'+facing]['anchors'] if 'interaction_side' in a]
            assert len(side) == 2
            assert all('look_up' in a['activities'] and len(a['gaze_target']) == 2 for a in side)


def test_furniture_editor_and_runtime_in_godot():
    executable = server.config().get('godot_gui') or server.config().get('godot')
    if not executable or not Path(executable).is_file():
        pytest.skip('Godot not configured')
    report = ROOT/'test-results/furniture-tests.json'
    report.unlink(missing_ok=True)
    result = server.run_bounded([executable,'--headless','--path',str(ROOT),
        '--script','tools/furniture_checks.gd','--','--npc-seed=20261023'],ROOT,55)
    assert result['ok'] and 'SCRIPT ERROR' not in result['stderr'], result
    data = json.loads(report.read_text())
    assert data['ok'] and data['checks'] >= 180, data
