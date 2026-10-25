"""Launch the isolated walkable library seating review with the configured Godot."""
import json
from pathlib import Path
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[1]
config=json.loads((ROOT/'tools/dos-game-mcp/local.json').read_text())
flags=subprocess.CREATE_NO_WINDOW if sys.platform=='win32' else 0
process=subprocess.Popen([config.get('godot_gui',config['godot']),'--path',str(ROOT),
                          'res://src/characters/char_library_live.tscn'],cwd=ROOT,creationflags=flags)
print(f'Library live review launched (PID {process.pid}). F8 next seat; F10 main game.')
