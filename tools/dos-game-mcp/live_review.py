"""Keep an owned MCP remake session open for user review; newline 'stop' closes it."""
import asyncio
import json
import sys
from pathlib import Path
from mcp import Client
from mcp.client.stdio import StdioServerParameters

async def main():
    root=Path(__file__).resolve().parents[2]
    params=StdioServerParameters(command=sys.executable,args=[str(Path(__file__).with_name('server.py'))],cwd=str(root))
    async with Client(params,read_timeout_seconds=90) as client:
        async def call(name,**kwargs):
            result=await client.call_tool(name,kwargs)
            value=result.structured_content
            print(json.dumps({'tool':name,'result':value}),flush=True)
            return value
        launched=await call('launch_remake')
        if not launched or not launched.get('ok'):return
        await call('get_game_status',game='remake')
        await call('capture_game_screenshot',game='remake',label='integrated-mansion-start')
        try:
            while True:
                line=await asyncio.to_thread(sys.stdin.readline)
                if not line or line.strip()=='stop':break
                request=json.loads(line)
                await call(request['tool'],**request.get('arguments',{}))
        finally:
            await call('stop_game',game='remake')

if __name__=='__main__':asyncio.run(main())
