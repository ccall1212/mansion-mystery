"""Shared rendering, seeded occupancy and real movement/conversation integration."""
import json
from pathlib import Path
import pytest
import server

ROOT = Path(__file__).resolve().parents[1]


def test_character_prototype_in_godot():
    executable = server.config().get('godot_gui') or server.config().get('godot')
    if not executable or not Path(executable).is_file():
        pytest.skip('Godot not configured')
    report = ROOT/'test-results/character-prototype-tests.json'
    report.unlink(missing_ok=True)
    result = server.run_bounded([executable,'--headless','--path',str(ROOT),'--script',
        'tools/character_prototype_checks.gd','--','--npc-seed=20261023'],ROOT,90)
    assert result['ok'] and 'SCRIPT ERROR' not in result['stderr'], result
    data = json.loads(report.read_text())
    assert data['ok'] and data['tested_seeds'] == 64 and len(data['occupants']) == 7, data
    assert data['checks'] > 1500
