"""Open the first-case briefing through an owned game window for user playtesting."""
import asyncio
import sys
from pathlib import Path
from mcp import Client
from mcp.client.stdio import StdioServerParameters

ROOT = Path(__file__).resolve().parents[2]


async def main():
    params = StdioServerParameters(command=sys.executable,
        args=[str(Path(__file__).with_name('server.py'))], cwd=str(ROOT))
    async with Client(params, read_timeout_seconds=90) as client:
        async def call(name, **arguments):
            result = (await client.call_tool(name, arguments)).structured_content
            assert result and result.get('ok'), result
            return result
        try:
            await call('launch_remake')
            await call('send_game_input', game='remake', keys=['F4'], hold_ms=60)
            await call('capture_game_screenshot', game='remake', label='first-case-briefing')
            print('FIRST_CASE_READY: Enter begins; F4 case board; N notes. Close the game when finished.', flush=True)
            while (await call('get_game_status', game='remake')).get('running', False):
                await asyncio.sleep(2)
        finally:
            await call('stop_game', game='remake')


if __name__ == '__main__':
    asyncio.run(main())
