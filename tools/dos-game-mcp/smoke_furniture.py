"""Verify furniture IDs and the F6 overlay through an owned Godot window."""
import asyncio
import json
import sys
from pathlib import Path
from mcp import Client
from mcp.client.stdio import StdioServerParameters

ROOT = Path(__file__).resolve().parents[2]


async def main():
    report = {'ok':False,'calls':[]}
    params = StdioServerParameters(command=sys.executable,args=[str(Path(__file__).with_name('server.py'))],cwd=str(ROOT))
    async with Client(params,read_timeout_seconds=90) as client:
        async def call(name,**arguments):
            result = await client.call_tool(name,arguments)
            data = result.structured_content
            for attempt in range(3):
                if name == 'capture_game_screenshot' and data and not data.get('ok') and 'Permission denied' in data.get('error',''):
                    await asyncio.sleep(.3)
                    data = (await client.call_tool(name,arguments)).structured_content
                else:
                    break
            report['calls'].append({'tool':name,'arguments':arguments,'result':data})
            assert data and data.get('ok'),data
            return data
        try:
            await call('launch_remake')
            await asyncio.sleep(.4)
            state = (await call('get_game_status',game='remake'))['game_state']
            expected = [i['id'] for i in json.loads((ROOT/'assets/furniture/layouts/foyer.json').read_text())['instances']]
            assert state['furniture']['ids'] == expected
            assert not state['furniture']['overlay']
            await call('send_game_input',game='remake',keys=['z','F6'])
            await asyncio.sleep(.3)
            state = (await call('get_game_status',game='remake'))['game_state']
            assert state['furniture']['overlay'] and state['camera_zoom'] == 1
            await call('capture_game_screenshot',game='remake',label='furniture-id-overlay')
            await call('send_game_input',game='remake',keys=['F6'])
            await asyncio.sleep(.3)
            assert not (await call('get_game_status',game='remake'))['game_state']['furniture']['overlay']
            logs = await call('read_game_logs',game='remake')
            assert 'SCRIPT ERROR' not in logs['text'] and 'ERROR:' not in logs['text'],logs
            report['ok'] = True
        finally:
            await call('stop_game',game='remake')
            (ROOT/'test-results/furniture-mcp.json').write_text(json.dumps(report,indent=2))
    print('FURNITURE_MCP_OK',report['ok'])


if __name__ == '__main__':
    asyncio.run(main())
