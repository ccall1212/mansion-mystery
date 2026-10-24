"""Real actor lifecycle, cross-room identity uniqueness and contact-scale checks."""
import json
from pathlib import Path
import pytest
import server

ROOT = Path(__file__).resolve().parents[1]


def test_char_pose_session_in_godot():
    executable = server.config().get('godot_gui') or server.config().get('godot')
    if not executable or not Path(executable).is_file():
        pytest.skip('Godot not configured')
    report = ROOT / 'test-results/char-live-test/checks.json'
    report.unlink(missing_ok=True)
    result = server.run_bounded([executable, '--headless', '--path', str(ROOT),
        '--script', 'tools/char_pose_checks.gd', '--', '--npc-seed=20261023'], ROOT, 55)
    assert result['ok'] and 'SCRIPT ERROR' not in result['stderr'], result
    data = json.loads(report.read_text(encoding='utf-8'))
    assert data['ok'] and data['room_visit_checks'] == 63 and data['rerolls'] == 100
    assert len(data['samples']) == 7 and len(data['random_poses_seen']) == 7
