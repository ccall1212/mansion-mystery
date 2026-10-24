import asyncio
import subprocess
import sys
from pathlib import Path
import pytest
from PIL import Image
from mcp import Client
from mcp.client.stdio import StdioServerParameters
import server


@pytest.mark.parametrize('path', ['../README.md', 'C:/Windows/win.ini', 'src/data.png', 'reference/screenshots/a.png:secret'])
def test_path_rejection(path):
    with pytest.raises(ValueError):
        server.inside(path, ('test-results',), False)


def test_output_rejection():
    for name in ['../escape', 'C:/escape', 'bad name', 'a' * 65]:
        with pytest.raises(ValueError):
            server.output('test-results/screenshots', name)


def test_run_failure_timeout():
    failure = server.run_bounded([sys.executable, '-c', 'raise SystemExit(7)'], server.ROOT, 3)
    assert failure['exit_code'] == 7 and not failure['ok']
    timed = server.run_bounded([sys.executable, '-c', 'import time;time.sleep(10)'], server.ROOT, .1)
    assert timed['timed_out'] and not timed['ok']
    missing = server.run_bounded(['C:/not-a-real-executable.exe'], server.ROOT, 3)
    assert not missing['ok'] and missing['exit_code'] is None


def test_no_arbitrary_window_input(monkeypatch):
    configured = server.config()
    monkeypatch.setattr(server, 'config', lambda: {**configured, 'godot': None, 'godot_gui': None})
    assert not server.send_game_input(['ENTER'], 'remake')['ok']
    assert not server.send_game_input(['ALT+F4'])['ok']
    assert not server.send_mouse_input()['ok']
    assert not server.capture_game_screenshot(game='remake')['ok']
    assert not server.launch_remake()['ok']
    assert not server.reset_game('remake')['ok']
    assert server.stop_game('remake')['stopped'] is False


def test_comparison():
    a = server.output('test-results/screenshots', 'synthetic-a')
    b = server.output('test-results/screenshots', 'synthetic-b')
    Image.new('RGB', (10, 10), 'red').save(a)
    Image.new('RGB', (10, 10), 'blue').save(b)
    assert server.compare_game_screenshots(str(a), str(a))['identical']
    assert server.compare_game_screenshots(str(a), str(b))['changed_pixels'] == 100
    assert not server.compare_game_screenshots('../README.md', str(a))['ok']
    Image.new('RGB', (12, 10), 'blue').save(b)
    assert not server.compare_game_screenshots(str(a), str(b))['same_dimensions']


def test_only_owned_process_stopped():
    unrelated = subprocess.Popen([sys.executable, '-c', 'import time;time.sleep(30)'])
    owned = subprocess.Popen([sys.executable, '-c', 'import time;time.sleep(30)'])
    try:
        server.PROCESSES['remake'] = {'process': owned, 'run_dir': 'test', 'log': 'test'}
        assert server.stop_game('remake')['stopped']
        assert owned.poll() is not None and unrelated.poll() is None
    finally:
        unrelated.terminate()
        unrelated.wait(timeout=5)
        server.PROCESSES.pop('remake', None)


def test_game_status_survives_snapshot_replacement(tmp_path, monkeypatch):
    from types import SimpleNamespace
    import json
    monkeypatch.setattr(server, 'ROOT', tmp_path)
    folder = tmp_path / 'test-results/remake-snapshot'
    folder.mkdir(parents=True)
    (folder / 'state.json').write_text(json.dumps({'guest_questioned': True}))
    validate = server.inside
    attempts = []
    def changing_snapshot(*args, **kwargs):
        attempts.append(1)
        if len(attempts) == 1:
            raise ValueError('Transient resolution during snapshot replacement')
        return validate(*args, **kwargs)
    monkeypatch.setattr(server, 'inside', changing_snapshot)
    monkeypatch.setattr(server, 'windows', lambda pid: [])
    server.PROCESSES['remake'] = {'process': SimpleNamespace(pid=123, poll=lambda: None), 'run_dir': str(folder)}
    try:
        result = server.get_game_status('remake')
        assert result['ok'] and result['game_state']['guest_questioned']
        assert len(attempts) == 2
    finally:
        server.PROCESSES.pop('remake', None)


def test_stdio_discovery_and_calls():
    async def check(mode):
        params = StdioServerParameters(command=sys.executable, args=[str(server.ROOT / 'tools/dos-game-mcp/server.py')], cwd=str(server.ROOT))
        async with Client(params, mode=mode, read_timeout_seconds=20) as client:
            listed = await client.list_tools()
            names = {t.name for t in listed.tools}
            assert len(names) == 15
            for name in ['inspect_game_archive', 'get_game_environment', 'get_project_status', 'get_game_status']:
                result = await client.call_tool(name, {})
                assert not result.is_error and result.structured_content['ok']
            result = await client.call_tool('send_game_input', {'keys': ['ALT+F4']})
            assert not result.structured_content['ok']
            invalid = await client.call_tool('get_game_status', {'game': 'not-a-game'})
            assert invalid.is_error
    for mode in ['auto', 'legacy']:
        asyncio.run(check(mode))


@pytest.mark.parametrize('initial_exit', [None, 7])
def test_emulator_startup_timeout_and_failure(monkeypatch, initial_exit):
    class Child:
        pid = 123456
        returncode = initial_exit
        def poll(self):
            return self.returncode
        def terminate(self):
            self.returncode = 1
        def wait(self, timeout):
            return self.returncode
    child = Child()
    monkeypatch.setattr(server.subprocess, 'Popen', lambda *args, **kwargs: child)
    monkeypatch.setattr(server, 'windows', lambda pid: [])
    clock = iter([0, 100])
    monkeypatch.setattr(server.time, 'monotonic', lambda: next(clock))
    try:
        result = server.launch_original_game()
        assert not result['ok'] and result['exit_code'] is not None
        assert child.poll() is not None
    finally:
        server.PROCESSES.pop('original', None)
