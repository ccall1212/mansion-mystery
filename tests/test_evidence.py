import hashlib
import json
from pathlib import Path

import pytest
from PIL import Image
import server

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / 'assets/objects/object-manifest.json'


def local(path):
    assert path.startswith('res://assets/objects/')
    result = (ROOT / path.removeprefix('res://')).resolve()
    assert result.is_relative_to(ROOT / 'assets/objects')
    return result


def test_evidence_assets_and_manifest():
    m = json.loads(MANIFEST.read_text(encoding='utf-8'))
    assert m['schema_version'] == 1
    assert {'knife', 'bust', 'bottle', 'hammer', 'stool', 'mirror', 'poker', 'magnifier'} <= m['definitions'].keys()
    for identity, definition in m['definitions'].items():
        assert identity == definition['id']
        assert local(definition['master']).is_file()
        assert (ROOT / f'assets/objects/prompts/{identity}.txt').is_file()
        assert definition['source_cells'] == len(definition['conditions'])
        hashes = set()
        for condition in definition['conditions'].values():
            assert all(condition[stage].strip() for stage in ('initial', 'detailed', 'repeat'))
            for key, dimensions in [('asset', (32, 40)), ('closeup', (160, 160))]:
                with Image.open(local(condition[key])) as im:
                    assert im.mode == 'RGBA' and im.size == dimensions
                    alpha = im.getchannel('A')
                    assert set(alpha.tobytes()) == {0, 255}
                    box = alpha.getbbox()
                    assert box and box[0] > 0 and box[2] < dimensions[0]
                    if key == 'asset':
                        assert box[3] == 39  # stable one-pixel foot margin
            digest = hashlib.sha256(local(condition['closeup']).read_bytes()).hexdigest()
            assert digest not in hashes, f'Duplicate physical art: {identity}'
            hashes.add(digest)
        if identity != 'magnifier':
            assert len(hashes) >= 2
    for forensic in m['forensics'].values():
        if forensic['inset']:
            with Image.open(local(forensic['inset'])) as image:
                assert image.mode == 'RGBA' and image.size == (160, 160)
    assert m['forensics']['none']['inset'] is None
    for instance in m['instances'].values():
        definition = m['definitions'][instance['definition']]
        assert instance['condition'] in definition['conditions']
        assert instance['forensic'] in definition['allowed_forensics']
    for planned in m['expansion_catalog']:
        assert planned['art_status'] == 'planned' and not planned['gameplay_ready']
        assert planned['id'] not in m['definitions']


def test_evidence_behavior_in_godot():
    executable = server.config().get('godot_gui') or server.config().get('godot')
    if not executable or not Path(executable).is_file():
        pytest.skip('Godot not configured')
    report = ROOT / 'test-results/evidence-engine-tests.json'
    report.unlink(missing_ok=True)
    result = server.run_bounded([executable, '--headless', '--path', str(ROOT), '--script', 'tools/evidence_checks.gd'], ROOT, 25)
    assert result['ok'] and 'SCRIPT ERROR' not in result['stderr'], result
    data = json.loads(report.read_text())
    assert data['ok'] and data['checks'] >= 59, data
