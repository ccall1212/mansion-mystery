"""Owned-window Char placement smoke; optional interactive handoff stays session-owned."""
import argparse
import asyncio
import html
import json
import shutil
import sys
from pathlib import Path
from mcp import Client
from mcp.client.stdio import StdioServerParameters

ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / 'test-results/char-live-test'


async def main(handoff=False):
    OUTPUT.mkdir(parents=True, exist_ok=True)
    params = StdioServerParameters(command=sys.executable,
        args=[str(Path(__file__).with_name('server.py'))], cwd=str(ROOT))
    samples = {}
    async with Client(params, read_timeout_seconds=90) as client:
        async def call(name, **arguments):
            result = (await client.call_tool(name, arguments)).structured_content
            assert result and result.get('ok'), result
            return result

        async def state():
            await asyncio.sleep(.2)
            return (await call('get_game_status', game='remake'))['game_state']

        try:
            await call('launch_remake')
            await call('send_game_input', game='remake', keys=['F7'], hold_ms=70)
            for roll in range(50):
                current = await state()
                test = current['char_pose_test']
                assert test['active'] and test['global_identity_count'] == test['visible_identity_count'] == 1, test
                records = [a for a in current['npc_assignments'] if a['id'] == 'likeness-photo01']
                assert len(records) == 1 and records[0]['room'] == current['mansion']['room_id']
                pose = records[0]['pose_id']
                if pose not in samples:
                    capture = await call('capture_game_screenshot', game='remake', label='char-live-'+pose)
                    target = OUTPUT / ('char_'+pose+'_preview.png')
                    shutil.copyfile(capture['path'], target)
                    samples[pose] = {'pose_id':pose, 'room':records[0]['room'],
                        'contact':records[0]['contact_key'], 'image':target.name,
                        'global_count':1, 'visible_count':1}
                if len(samples) == 7:
                    break
                await call('send_game_input', game='remake', keys=['F8'], hold_ms=70)
            assert len(samples) == 7, samples
            before = (await state())['char_pose_test']['assignment']
            await call('send_game_input', game='remake', keys=['F7'], hold_ms=70)
            assert (await state())['char_pose_test']['assignment'] == before, 'Find must not reroll'
            current = await state()
            assert current['presentation']['viewport'] == [960,720] and current['presentation']['adult_height'] == 80
            assert current['camera_zoom'] == 1.5
            await call('send_game_input', game='remake', keys=['z'], hold_ms=70)
            overview = await state()
            assert overview['camera_zoom'] == 1 and overview['char_pose_test']['assignment'] == before
            capture = await call('capture_game_screenshot', game='remake', label='char-hd-overview')
            shutil.copyfile(capture['path'], OUTPUT/'char_overview_preview.png')
            await call('send_game_input', game='remake', keys=['z','F11'], hold_ms=70)
            assert (await state())['presentation']['fullscreen']
            await call('send_game_input', game='remake', keys=['F11'], hold_ms=70)
            assert not (await state())['presentation']['fullscreen']
            logs = await call('read_game_logs', game='remake')
            assert 'SCRIPT ERROR' not in logs['text'] and 'ERROR:' not in logs['text'], logs
            report = {'ok':True, 'samples':list(samples.values()), 'all_seven_poses_seen':True,
                'owned_window_input':True, 'find_preserves_assignment':True,
                'presentation':current['presentation'], 'overview_toggle':True, 'fullscreen_toggle':True,
                'fit_status':'Provisional contacts; no chair foreground masks. No appearance change.'}
            (OUTPUT/'live-smoke.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
            lines = ['<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Char — live placement test</title>',
                '<style>body{font:17px system-ui;background:#17242b;color:#e1e9eb;margin:26px}a,h1,h2{color:#edce98}img{width:1280px;max-width:100%;image-rendering:pixelated}body.native img{max-width:none;width:auto}button{font:inherit;padding:8px}article{margin-bottom:36px}</style>',
                '<h1>Char — live room and pose test</h1><button onclick="document.body.classList.toggle(\'native\')">Toggle native pixels / fit to panel</button><p>Actual owned game captures. One global Char assignment and one visible Char in her room. Seated contact fit, skirt clearance and foreground masks remain provisional.</p>',
                '<p>F7: start/find Char · F8: random room and pose · F10: exit test · Z: detail/overview · F11: fullscreen. Detail view is the default. Visiting a room does not reroll her. Save/load is disabled during the test.</p>',
                '<p><a href="../../assets/characters/poses/char/index.html">Approved source poses</a> · <a href="live-smoke.json">Live checks</a> · <a href="checks.json">Cross-room lifecycle checks</a></p>']
            for sample in sorted(samples.values(), key=lambda s:s['pose_id']):
                lines.append('<article><h2>'+html.escape(sample['pose_id'])+'</h2><p>'+html.escape(sample['room']+' / '+(sample['contact'] or 'clear standing placement'))+'</p><img src="'+sample['image']+'" alt="Char live '+sample['pose_id']+'"></article>')
            (OUTPUT/'index.html').write_text('\n'.join(lines)+'</html>', encoding='utf-8')
            print('CHAR_LIVE_TEST_OK seven poses; index: test-results/char-live-test/index.html', flush=True)
            if handoff:
                print('LIVE_GAME_READY F7=find F8=randomize F10=exit test. Close the game window when finished.', flush=True)
                while (await call('get_game_status', game='remake')).get('running', False):
                    await asyncio.sleep(2)
        finally:
            await call('stop_game', game='remake')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--handoff', action='store_true')
    asyncio.run(main(parser.parse_args().handoff))
