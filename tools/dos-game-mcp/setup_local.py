"""Repeatable local setup. Never downloads emulators or executes archive content."""
import argparse
import hashlib
import json
import sys
import tomllib
from pathlib import Path
from archive import extract_reference, inventory

ROOT = Path(__file__).resolve().parents[2]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--archive', type=Path, required=True)
    parser.add_argument('--emulator', type=Path, required=True)
    parser.add_argument('--godot', type=Path)
    options = parser.parse_args()
    archive, emulator = options.archive.resolve(strict=True), options.emulator.resolve(strict=True)
    if emulator.name.lower() != 'dosbox-x.exe':
        parser.error('This adapter is validated only for dosbox-x.exe (Windows SDL2 build)')
    original = ROOT / 'reference/original'
    report = inventory(archive)
    if original.exists():
        import zipfile
        with zipfile.ZipFile(archive) as z:
            for row in report['files']:
                if not row['directory'] and (original / row['name']).read_bytes() != z.read(row['name']):
                    parser.error('Existing reference differs from archive; nothing overwritten')
    else:
        report = extract_reference(archive, original)
    for row in report['files']:
        if not row['directory']:
            row['sha256'] = hashlib.sha256((original / row['name']).read_bytes()).hexdigest()
    for name in ['reference/screenshots', 'test-results', 'logs', '.codex', 'src', 'assets']:
        (ROOT / name).mkdir(parents=True, exist_ok=True)
    (ROOT / 'reference/inventory.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
    local = {'archive': str(archive), 'archive_sha256': report['sha256'], 'emulator': str(emulator),
             'emulator_sha256': hashlib.sha256(emulator.read_bytes()).hexdigest(),
             'godot': str(options.godot.resolve()) if options.godot else None}
    if options.godot:
        local['godot_sha256'] = hashlib.sha256(options.godot.resolve(strict=True).read_bytes()).hexdigest()
        gui = options.godot.resolve().with_name(options.godot.name.replace('_console.exe', '.exe'))
        if gui.is_file():
            local['godot_gui'] = str(gui)
            local['godot_gui_sha256'] = hashlib.sha256(gui.read_bytes()).hexdigest()
    Path(__file__).with_name('local.json').write_text(json.dumps(local, indent=2), encoding='utf-8')
    settings = {'command': sys.executable, 'args': [str(Path(__file__).with_name('server.py'))],
                'cwd': str(ROOT), 'startup_timeout_sec': 20, 'tool_timeout_sec': 120}
    path = ROOT / '.codex/config.toml'
    existing = path.read_text(encoding='utf-8') if path.exists() else ''
    previous = tomllib.loads(existing).get('mcp_servers', {}).get('sleuth_game')
    if previous and previous != settings:
        parser.error('Existing sleuth_game settings differ; local reference is ready, but project Codex config was preserved. Update that table manually.')
    if not previous:
        block = '\n[mcp_servers.sleuth_game]\n' + '\n'.join(f'{key} = {json.dumps(value)}' for key, value in settings.items()) + '\n'
        path.write_text(existing + block, encoding='utf-8')
    print('Reference verified; local paths and project-scoped Codex MCP configuration ready.')


if __name__ == '__main__':
    main()
