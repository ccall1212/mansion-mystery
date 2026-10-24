"""Asset contract and real Godot review controls; no invented room navigation."""
import json
from pathlib import Path

import pytest
from PIL import Image
import server


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "assets/rooms/room-manifest.json"


def test_environment_asset_contract():
    data = json.loads(MANIFEST.read_text(encoding="utf-8"))
    assert data["room_size"] == [480, 320]
    assert data["room_offset"] == [0, 24]
    assert len(data["rooms"]) == 9
    variants = [v for room in data["rooms"] for v in room["variants"]]
    assert len(variants) == 18
    assert len({v["id"] for v in variants}) == 18
    assert len({v["asset"] for v in variants}) == 18
    for variant in variants:
        paths = {}
        for key in ["asset", "master", "prompt"]:
            path = (ROOT / variant[key].removeprefix("res://")).resolve()
            path.relative_to(ROOT / "assets/rooms")
            assert path.is_file(), path
            paths[key] = path
        with Image.open(paths["asset"]) as image:
            assert image.size == (480, 320)
            assert image.convert("RGBA").getchannel("A").getextrema() == (255, 255)
        with Image.open(paths["master"]) as image:
            assert image.width * 2 == image.height * 3
        assert variant["entrance_directions"]
    staircase = data["rooms"][-1]["variants"]
    assert "upstairs" in staircase[0]["entrance_directions"]
    assert "basement-down" in staircase[1]["entrance_directions"]
    project = (ROOT / "project.godot").read_text(encoding="utf-8")
    assert 'run/main_scene="res://src/mansion/playable_mansion.tscn"' in project


def test_environment_review_in_godot():
    executable = server.config().get("godot_gui") or server.config().get("godot")
    if not executable or not Path(executable).is_file():
        pytest.skip("Godot not configured on this machine")
    report = ROOT / "test-results/environment-engine-tests.json"
    report.unlink(missing_ok=True)
    result = server.run_bounded([
        executable, "--headless", "--path", str(ROOT),
        "res://src/environments/environment_review.tscn", "--", "--environment-test",
    ], ROOT, 25)
    assert result["ok"], result
    assert "SCRIPT ERROR" not in result["stderr"], result
    actual = json.loads(report.read_text(encoding="utf-8"))
    assert actual["ok"] and actual["layouts"] == 18 and actual["checks"] == 24, actual
