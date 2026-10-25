"""End-to-end Godot window, targeted keyboard, live state and viewport capture."""
import asyncio
import json
import sys
import heapq
import math
from pathlib import Path
from mcp import Client
from mcp.client.stdio import StdioServerParameters

ROOT = Path(__file__).resolve().parents[2]


async def main():
    report = {'calls': [], 'ok': False}
    params = StdioServerParameters(command=sys.executable, args=[str(Path(__file__).with_name('server.py'))], cwd=str(ROOT))
    async with Client(params, read_timeout_seconds=90) as client:
        async def call(name, **arguments):
            result = await client.call_tool(name, arguments)
            data = result.structured_content
            # Windows can briefly hold a completed capture during indexing.
            if name == 'capture_game_screenshot':
                for attempt in range(3):
                    if data and not data.get('ok') and 'Permission denied' in data.get('error',''):
                        await asyncio.sleep(.3)
                        result = await client.call_tool(name, arguments)
                        data = result.structured_content
                    else:
                        break
            report['calls'].append({'tool': name, 'arguments': arguments, 'result': data})
            (ROOT / 'test-results/remake-smoke.json').write_text(json.dumps(report, indent=2))
            print(name, json.dumps(data)[:600], flush=True)
            assert data and data.get('ok'), data
            return data
        async def walk(x, y):
            # Navigate the same feet geometry as the engine, then compress straight
            # sections into bounded, window-targeted key presses. No timed routes
            # tied to the previous movement speed.
            state = (await call('get_game_status', game='remake'))['game_state']
            room_id = state['mansion']['room_id']
            definition = json.loads((ROOT/'assets/mansion/fixed-mansion.json').read_text())['rooms'][room_id]
            occupants = [a for a in state.get('npc_assignments', []) if a['room'] == room_id]
            def inside(at, r):
                return r[0] <= at[0] < r[0]+r[2] and r[1] <= at[1] < r[1]+r[3]
            def free(cell):
                px, py = cell[0]*4+2, cell[1]*4+2
                if not 0 <= cell[0] < 120 or not 0 <= cell[1] < 90:
                    return False
                if not all(any(inside((px+dx, py+dy), r) for r in definition['walk_regions'])
                           for dx,dy in [(-5,-5),(5,-5),(-5,.5),(5,.5)]):
                    return False
                blocks = definition['obstacles'] + [[a['position'][0]-7,a['position'][1]-8,14,8] for a in occupants]
                return not any(px+5 > r[0] and px-5 < r[0]+r[2] and py+1 > r[1] and py-5 < r[1]+r[3] for r in blocks)
            def nearest(px,py):
                cells = [(cx,cy) for cy in range(max(0,int(py/4)-10),min(90,int(py/4)+11))
                         for cx in range(max(0,int(px/4)-10),min(120,int(px/4)+11)) if free((cx,cy))]
                return min(cells, key=lambda c: math.hypot(c[0]*4+2-px,c[1]*4+2-py))
            start = nearest(state['position']['x'],state['position']['y'])
            goal = nearest(x,y)
            queue, costs, parents = [(0,start)], {start:0}, {}
            while queue:
                _, at = heapq.heappop(queue)
                if at == goal:
                    break
                for dx,dy in [(0,1),(0,-1),(1,0),(-1,0)]:
                    nxt = at[0]+dx, at[1]+dy
                    cost = costs[at]+1
                    if free(nxt) and cost < costs.get(nxt,1e9):
                        costs[nxt] = cost; parents[nxt] = at
                        heapq.heappush(queue,(cost+abs(nxt[0]-goal[0])+abs(nxt[1]-goal[1]),nxt))
            assert goal == start or goal in parents, (room_id, start, goal)
            path = [goal]
            while path[-1] != start:
                path.append(parents[path[-1]])
            path.reverse()
            corners = [path[0]]
            for i in range(1,len(path)-1):
                if (path[i][0]-path[i-1][0],path[i][1]-path[i-1][1]) != (path[i+1][0]-path[i][0],path[i+1][1]-path[i][1]):
                    corners.append(path[i])
            corners.append(goal)
            for cell in corners:
                for axis, target in [('x',cell[0]*4+2),('y',cell[1]*4+2)]:
                    for attempt in range(12):
                        state = (await call('get_game_status', game='remake'))['game_state']
                        delta = target-state['position'][axis]
                        if abs(delta) < 3:
                            break
                        key = ('RIGHT' if delta > 0 else 'LEFT') if axis == 'x' else ('DOWN' if delta > 0 else 'UP')
                        await call('send_game_input',game='remake',keys=[key],hold_ms=max(20,min(1000,round(abs(delta)/state['animation']['speed']*1000))))
                        await asyncio.sleep(.13)
                    else:
                        raise AssertionError(('walk stalled',room_id,axis,target,state['position']))
            assert math.hypot(state['position']['x']-x,state['position']['y']-y) < 16

        try:
            await call('launch_remake')
            await asyncio.sleep(1)
            initial = (await call('get_game_status', game='remake'))['game_state']
            assert initial['mansion']['blueprint_id'] == 'fixed-manor-compact-2'
            assert initial['mansion']['floor'] == 0 and initial['mansion']['room_id'] == 'g_foyer'
            assert initial['camera_zoom'] == 1.5, 'Detail camera should be the default'
            assert len(initial['npc_assignments']) == 7
            assert len({a['room'] for a in initial['npc_assignments']}) == 7
            await call('capture_game_screenshot', game='remake', label='foyer-entry')
            await call('send_game_input', game='remake', keys=['z'])
            await asyncio.sleep(.2)
            assert (await call('get_game_status', game='remake'))['game_state']['camera_zoom'] == 1.0
            await call('capture_game_screenshot', game='remake', label='foyer-overview')
            await call('send_game_input', game='remake', keys=['z'])
            await asyncio.sleep(.2)
            assert (await call('get_game_status', game='remake'))['game_state']['camera_zoom'] == 1.5
            await call('send_game_input', game='remake', keys=['RIGHT'], hold_ms=500)
            await asyncio.sleep(.3)
            moved = (await call('get_game_status', game='remake'))['game_state']
            assert moved['mansion'] == initial['mansion'], 'Mansion rerolled during room movement'
            assert moved['npc_assignments'] == initial['npc_assignments']
            assert moved['position']['x'] > initial['position']['x'] + 10, 'Window-targeted keyboard did not move Godot player'
            await call('send_game_input', game='remake', keys=['r'])
            await walk(82,205)
            await call('send_game_input', game='remake', keys=['e'])
            await asyncio.sleep(.3)
            state = (await call('get_game_status', game='remake'))['game_state']
            assert state['clue_found'] and state['dialogue_open'], state
            await call('capture_game_screenshot', game='remake', label='foyer-clock-clue')
            await call('send_game_input', game='remake', keys=['ESC'])
            await asyncio.sleep(.3)
            assert not (await call('get_game_status', game='remake'))['game_state']['dialogue_open']
            await call('send_game_input', game='remake', keys=['r'])
            await walk(346,217)
            await call('send_game_input', game='remake', keys=['e'])
            await asyncio.sleep(.5)
            guest = (await call('get_game_status', game='remake'))['game_state']
            assert guest['questioning'] and guest['movement_locked'], guest
            await call('capture_game_screenshot', game='remake', label='foyer-eleanor-questions')
            await call('send_game_input', game='remake', keys=['ENTER'])
            await asyncio.sleep(.3)
            answer = (await call('get_game_status', game='remake'))['game_state']
            assert answer['guest_questioned'] and 0 in answer['answers_heard'] and 'carriage' in answer['dialogue_text'], answer
            await call('capture_game_screenshot', game='remake', label='foyer-eleanor-alibi')
            await call('send_game_input', game='remake', keys=['ENTER', 'DOWN', 'DOWN', 'ENTER'])
            await asyncio.sleep(.3)
            answer = (await call('get_game_status', game='remake'))['game_state']
            assert 2 in answer['answers_heard'] and 'ticking' in answer['dialogue_text'], answer
            await call('send_game_input', game='remake', keys=['ESC', 'r'])
            await call('capture_game_screenshot', game='remake', label='foyer-playable')
            # Carry a real tool through two room doors and inspect a library clue.
            await walk(366,258)
            await call('send_game_input', game='remake', keys=['e', 'c', 'ESC', 'r'])
            await asyncio.sleep(.2)
            lens = (await call('get_game_status', game='remake'))['game_state']
            assert lens['evidence']['records']['foyer-lens']['collected'], lens
            await walk(240,318)
            await call('send_game_input', game='remake', keys=['e'])
            await asyncio.sleep(.2)
            assert (await call('get_game_status', game='remake'))['game_state']['mansion']['room_id'] == 'g_main_stair'
            await walk(30,202)
            await call('send_game_input', game='remake', keys=['e'])
            await asyncio.sleep(.2)
            assert (await call('get_game_status', game='remake'))['game_state']['mansion']['room_id'] == 'g_library'
            await call('capture_game_screenshot', game='remake', label='library-arrival')
            await walk(244,271)
            await call('send_game_input', game='remake', keys=['e', 'm'])
            await asyncio.sleep(.3)
            finding = (await call('get_game_status', game='remake'))['game_state']
            assert finding['evidence_selected'] == 'foyer-knife' and finding['evidence']['records']['foyer-knife']['discovered'], finding
            await call('capture_game_screenshot', game='remake', label='library-magnifier-finding')
            await call('read_game_logs', game='remake')
            await call('reset_game', game='remake')
            await asyncio.sleep(.3)
            reset = (await call('get_game_status', game='remake'))['game_state']
            assert reset['position'] == {'x': 240.0, 'y': 294.0} and not reset['clue_found'] and not reset['guest_questioned'], reset
            assert len(reset['npc_assignments']) == 7 and reset['npc_seed'] != initial['npc_seed']
            report['ok'] = True
        finally:
            await call('stop_game', game='remake')
            (ROOT / 'test-results/remake-smoke.json').write_text(json.dumps(report, indent=2))


if __name__ == '__main__':
    asyncio.run(main())
