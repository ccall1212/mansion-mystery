"""Real stdio integration smoke; launches the original and saves local evidence."""
import asyncio
import json
import sys
from pathlib import Path
from mcp import Client
from mcp.client.stdio import StdioServerParameters

ROOT = Path(__file__).resolve().parents[2]


async def main():
    params = StdioServerParameters(command=sys.executable, args=[str(Path(__file__).with_name('server.py'))], cwd=str(ROOT))
    results = {}
    async with Client(params, read_timeout_seconds=120) as client:
        results['tools'] = [t.name for t in (await client.list_tools()).tools]
        async def call(name, **arguments):
            r = await client.call_tool(name, arguments)
            data = r.structured_content or {'protocol_error': r.is_error, 'content': str(r.content)}
            results.setdefault('calls', []).append({'tool': name, 'arguments': arguments, 'result': data})
            (ROOT / 'test-results/smoke.json').write_text(json.dumps(results, indent=2), encoding='utf-8')
            print(name, json.dumps(data)[:500], flush=True)
            if name not in ('launch_remake', 'send_mouse_input') and not data.get('ok'):
                raise RuntimeError(f'{name} failed; see test-results/smoke.json')
            return data
        for name in ['inspect_game_archive', 'get_game_environment', 'get_project_status', 'get_game_status', 'send_mouse_input']:
            await call(name)
        try:
            started = await call('launch_original_game')
            if started.get('ok'):
                await asyncio.sleep(8)
                shot = await call('capture_game_screenshot', label='startup', reference=True)
                await call('get_game_status')
                await call('read_game_logs')
                if shot.get('ok'):
                    await call('compare_game_screenshots', first=shot['path'], second=shot['path'])
                await call('send_game_input', keys=['ENTER'])
                await asyncio.sleep(1)
                await call('capture_game_screenshot', label='after-enter', reference=True)
                await call('send_game_input', keys=['ENTER'])
                await asyncio.sleep(1)
                await call('capture_game_screenshot', label='menu', reference=True)
                await call('send_game_input', keys=['a'])
                await asyncio.sleep(2)
                await call('capture_game_screenshot', label='basic-game', reference=True)
                await call('reset_game')
                await asyncio.sleep(2)
                await call('capture_game_screenshot', label='reset', reference=True)
            await call('run_project_tests')
            await call('get_test_results')
        finally:
            await call('stop_game')
            await call('get_game_status')
    (ROOT / 'test-results/smoke.json').write_text(json.dumps(results, indent=2), encoding='utf-8')


if __name__ == '__main__':
    asyncio.run(main())
