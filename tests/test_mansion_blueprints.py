"""Logical house topology and real Godot session persistence."""
import json
from collections import defaultdict, deque
from pathlib import Path

import pytest
import server

ROOT = Path(__file__).resolve().parents[1]
DATA = json.loads((ROOT / "assets/mansion/blueprints.json").read_text(encoding="utf-8"))
OPPOSITE = {"north": "south", "south": "north", "east": "west", "west": "east", "up": "down", "down": "up"}
DELTA = {"north": (0, -1), "south": (0, 1), "east": (1, 0), "west": (-1, 0)}


def reachable(plan, removed_shaft=None):
    graph = defaultdict(set)
    for link in plan["links"]:
        assert link["kind"] in {"door", "archway", "stairs"}
        if link.get("shaft") == removed_shaft and removed_shaft is not None:
            continue
        a, b = link["a"]["room"], link["b"]["room"]
        graph[a].add(b)
        graph[b].add(a)
    seen, queue = {plan["start_room"]}, deque([plan["start_room"]])
    while queue:
        for destination in graph[queue.popleft()] - seen:
            seen.add(destination)
            queue.append(destination)
    return seen


@pytest.mark.parametrize("plan", DATA["blueprints"], ids=lambda p: p["id"])
def test_reciprocal_physical_layout_and_two_stair_routes(plan):
    rooms = {r["id"]: r for r in plan["rooms"]}
    assert len(rooms) == len(plan["rooms"])
    assert len({(r["floor"], *r["grid"]) for r in rooms.values()}) == len(rooms)
    assert {r["floor"] for r in rooms.values()} == {-1, 0, 1}
    assert len({e["id"] for e in plan["links"]}) == len(plan["links"])
    ports = set()
    for link in plan["links"]:
        a, b = link["a"], link["b"]
        ra, rb = rooms[a["room"]], rooms[b["room"]]
        assert OPPOSITE[a["port"]] == b["port"]
        for endpoint in [a, b]:
            key = endpoint["room"], endpoint["port"]
            assert key not in ports, f"Two exits reuse one port: {key}"
            ports.add(key)
        if link["kind"] == "stairs":
            assert ra["grid"] == rb["grid"], "Stair shafts do not align vertically"
            assert abs(ra["floor"] - rb["floor"]) == 1
            assert a["port"] == ("up" if rb["floor"] > ra["floor"] else "down")
        else:
            assert ra["floor"] == rb["floor"]
            assert tuple(rb["grid"][i] - ra["grid"][i] for i in [0, 1]) == DELTA[a["port"]]
    assert reachable(plan) == set(rooms)
    for shaft in ["main", "service"]:
        assert reachable(plan, removed_shaft=shaft) == set(rooms), "A floor depends on a single staircase"
    for room in rooms.values():
        for candidate in room["asset_candidates"]:
            asset = ROOT / candidate["asset"].removeprefix("res://")
            assert asset.is_file()
        if room["asset_type"] in {"kitchen", "bathroom", None}:
            assert room["art_status"] == "new-room-art-required"


def test_templates_have_distinct_layouts_and_fixed_front_entry():
    signatures = []
    for plan in DATA["blueprints"]:
        rooms = {r["id"]: r for r in plan["rooms"]}
        assert rooms["g_foyer"]["grid"][1] == 0
        assert plan["start_entry_port"] == "north"
        assert plan["boundaries"] == [{"id": "locked-front-door", "room": "g_foyer", "port": "north", "locked": True, "traversable": False, "outside_destination": None}]
        assert not any(r["role"] == "exterior" for r in rooms.values())
        assert not any(e[side] == {"room": "g_foyer", "port": "north"} for e in plan["links"] for side in ["a", "b"])
        for floor in [-1, 0, 1]:
            level = [r for r in rooms.values() if r["floor"] == floor]
            assert len(level) == 6
            assert sum(r["role"] == "room" for r in level) == 4
            assert sum(r["role"] == "passage" for r in level) == 2
            assert sum(r.get("contains_stairs", False) for r in level) == 2
        signatures.append(json.dumps({"rooms": [(r["id"], r["grid"]) for r in rooms.values()], "links": plan["links"]}, sort_keys=True))
    assert len(set(signatures)) == 4


def test_mansion_session_in_godot():
    executable = server.config().get("godot_gui") or server.config().get("godot")
    if not executable or not Path(executable).is_file():
        pytest.skip("Godot not configured")
    report = ROOT / "test-results/mansion-engine-tests.json"
    report.unlink(missing_ok=True)
    result = server.run_bounded([executable, "--headless", "--path", str(ROOT),
        "--script", "res://tools/test_mansion_session.gd"], ROOT, 25)
    assert result["ok"], result
    assert "SCRIPT ERROR" not in result["stderr"], result
    actual = json.loads(report.read_text(encoding="utf-8"))
    assert actual["ok"] and actual["checks"] >= 35, actual
