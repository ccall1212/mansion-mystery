"""Exercise installed Codex MCP discovery without creating a chat or invoking a model.

An unbound app-server has no thread/project context. Feed it ONLY the server settings
returned by the real `codex mcp get` command in this project, using CLI overrides.
"""
import json
import queue
import shutil
import subprocess
import threading
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def main():
    codex = shutil.which('codex')
    if not codex:
        raise RuntimeError('codex executable not on PATH')
    loaded = subprocess.run([codex, 'mcp', 'get', 'sleuth_game', '--json'], cwd=ROOT,
                            capture_output=True, text=True, check=True, timeout=15)
    config = json.loads(loaded.stdout)
    transport = config['transport']
    args = [codex, 'app-server', '--stdio']
    for key in ['command', 'args', 'cwd']:
        args += ['-c', 'mcp_servers.sleuth_game.' + key + '=' + json.dumps(transport[key])]
    messages = queue.Queue()
    report = ROOT / 'test-results/codex-discovery.json'
    with (ROOT / 'test-results/codex-discovery-stderr.log').open('w') as err:
        p = subprocess.Popen(args, cwd=ROOT, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                             stderr=err, text=True, encoding='utf-8')
        def read():
            for line in p.stdout:
                try:
                    messages.put(json.loads(line))
                except ValueError:
                    pass
        threading.Thread(target=read, daemon=True).start()
        def request(identifier, method, params):
            p.stdin.write(json.dumps({'id': identifier, 'method': method, 'params': params}) + '\n')
            p.stdin.flush()
            deadline = time.monotonic() + 40
            while time.monotonic() < deadline:
                msg = messages.get(timeout=max(.1, deadline - time.monotonic()))
                if msg.get('id') == identifier:
                    return msg
            raise TimeoutError(method)
        try:
            request(1, 'initialize', {'clientInfo': {'name': 'sleuth-validation', 'version': '1.0'}})
            p.stdin.write(json.dumps({'method': 'initialized', 'params': {}}) + '\n')
            p.stdin.flush()
            result = request(2, 'mcpServerStatus/list', {'serverName': 'sleuth_game', 'detail': 'toolsAndAuthOnly'})
            report.write_text(json.dumps({'project_config': config, 'discovery': result,
                'method': 'Codex app-server with project settings read by codex mcp get; no thread created'}, indent=2))
            data = result.get('result', {}).get('data', [])
            print(json.dumps(data)[:4000])
            if not data or not any(s.get('tools') for s in data):
                raise RuntimeError('Codex did not discover tools; see ' + str(report))
        finally:
            p.stdin.close()
            try:
                p.wait(timeout=5)
            except subprocess.TimeoutExpired:
                p.terminate()
                p.wait(timeout=5)


if __name__ == '__main__':
    main()
