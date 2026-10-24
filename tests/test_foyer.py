import json
from pathlib import Path
import pytest
import server


def test_playable_foyer_in_godot():
    executable = server.config().get('godot_gui') or server.config().get('godot')
    if not executable or not Path(executable).is_file():
        pytest.skip('Godot not configured on this machine')
    report = server.ROOT / 'test-results/foyer-engine-tests.json'
    if report.exists():
        report.unlink()
    result = server.run_bounded([executable, '--headless', '--path', str(server.ROOT), '--', '--foyer-test'], server.ROOT, 25)
    assert result['ok'], result
    assert 'SCRIPT ERROR' not in result['stderr'], result
    actual = json.loads(report.read_text())
    assert actual['ok'] and actual['checks'] == 14, actual
