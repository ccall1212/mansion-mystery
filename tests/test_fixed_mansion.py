"""Authored room metadata plus end-to-end walking through actual Godot physics."""
import json
from collections import deque
from pathlib import Path

import pytest
import server

ROOT = Path(__file__).resolve().parents[1]
DATA = json.loads((ROOT/'assets/mansion/fixed-mansion.json').read_text())


def test_fixed_room_graph_and_art_contract():
    rooms = DATA['rooms']
    assert len(rooms) == 9
    assert DATA['id'] == 'fixed-manor-compact-1' and DATA['start_room'] == 'g_foyer'
    assert len({r['asset'] for r in rooms.values()}) == len(rooms)
    assert {floor:sum(r['floor'] == floor and r['role'] == 'room' for r in rooms.values()) for floor in (-1,0,1)} == {-1:1,0:4,1:2}
    seen, queue = {'g_foyer'}, deque(['g_foyer'])
    for identity, room in rooms.items():
        assert identity == room['id']
        assert (ROOT/room['asset'].removeprefix('res://')).is_file()
        assert room['walk_regions']
        for portal in room['portals']:
            target = rooms[portal['target']]
            reverse = [p for p in target['portals'] if p['id'] == portal['id'] and p['target'] == identity]
            assert len(reverse) == 1
            assert portal['facing'] in ([1,0],[-1,0],[0,1],[0,-1])
            assert (portal['kind'] == 'stairs') == (target['floor'] != room['floor'])
    while queue:
        for portal in rooms[queue.popleft()]['portals']:
            if portal['target'] not in seen:
                seen.add(portal['target']); queue.append(portal['target'])
    assert seen == rooms.keys()
    assert not any('outside' in p['target'] for r in rooms.values() for p in r['portals'])
    assert len(rooms['g_foyer']['portals']) == 1
    assert rooms['g_foyer']['portals'][0]['at'][1] > 300  # north/front door stays locked
    assert rooms['g_kitchen']['art_note'] and rooms['g_dining']['art_note']


def test_fixed_mansion_walking_in_godot():
    executable = server.config().get('godot_gui') or server.config().get('godot')
    if not executable or not Path(executable).is_file():
        pytest.skip('Godot not configured')
    report = ROOT/'test-results/fixed-mansion-tests.json'
    report.unlink(missing_ok=True)
    result = server.run_bounded([executable,'--headless','--path',str(ROOT),'--script','tools/fixed_mansion_checks.gd'],ROOT,70)
    assert result['ok'] and 'SCRIPT ERROR' not in result['stderr'], result
    data = json.loads(report.read_text())
    assert data['ok'] and data['directed_passages'] == 16 and len(data['visited']) == 9, data
    assert data['checks'] >= 90
