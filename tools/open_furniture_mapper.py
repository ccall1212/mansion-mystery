"""Open the standalone furniture mapper using the project's configured Godot."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--background', help='Optional res://assets/... image to annotate')
    parser.add_argument('--dry-run', action='store_true', help='Print the launch command without starting a window')
    args = parser.parse_args()
    config_path = ROOT/'tools/dos-game-mcp/local.json'
    config = json.loads(config_path.read_text()) if config_path.is_file() else {}
    candidates = [config.get('godot_gui'),config.get('godot'),shutil.which('godot'),shutil.which('godot4')]
    executable = next((value for value in candidates if value and Path(value).is_file()),None)
    if not executable:
        parser.error('Configure Godot in tools/dos-game-mcp/local.json or add it to PATH.')
    command = [executable,'--path',str(ROOT),'res://src/furniture/furniture_editor.tscn']
    if args.background:
        path = args.background
        if not path.startswith('res://assets/') or '..' in Path(path).parts or not (ROOT/path.removeprefix('res://')).is_file():
            parser.error('Background must be an existing res://assets/... image. Copy new images into assets first.')
        command += ['--','--background='+path]
    if args.dry_run:
        print(json.dumps(command))
        return
    flags = subprocess.CREATE_NO_WINDOW if sys.platform == 'win32' else 0
    subprocess.Popen(command,cwd=ROOT,creationflags=flags)


if __name__ == '__main__':
    main()
