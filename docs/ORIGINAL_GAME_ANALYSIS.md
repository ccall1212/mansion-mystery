# Original game evidence

## Full data-table audit — 2026-10-25

All 33 ZIP entries match the preserved reference hashes. The archive contains no
program source. A read-only data audit identified 36 delivery/refusal/repeat
fragments, 56 statement endings with seven regularly spaced reveal slots, two
120-record activity tables and two 33-slot object tables. Exact original selection
logic and personality counts remain unknown; table bank counts are not personality
counts. Printable executable data was inspected without disassembly/decompilation.

See [Dialogue and case randomization research](DIALOGUE_RANDOMIZATION_DESIGN.md)
for evidence levels, complete file-family coverage, current-code gaps and a proposed
truth-first replacement. Reproduce with `tools/audit_original_dialogue.py`; decoded
original text remains only in ignored local output. No live original-game behavior
was newly verified and no gameplay implementation changed in this audit.

Inspection date: 2026-10-23 (America/Denver).

## Preservation and inventory

The supplied ZIP is `sleuth.zip` in the user's Downloads directory. The exact source
path and emulator path are recorded in ignored `tools/dos-game-mcp/local.json`.
The original ZIP SHA-256 is:

`b294d2815ee285cd1f03c377af4d866a420676994abcf6348ff75e4ccb4bada8`

The archive has 33 files, 57,959 compressed archive bytes. A separately extracted
reference resides at `reference/original/`. `reference/inventory.json` records sizes,
types, compressed sizes and individual extracted SHA-256 hashes. Launch verifies
all inventoried files and emulator identity, then copies the reference to a unique
disposable run directory. No original executable was decompiled or modified.

| Group | Files | Interpretation |
| --- | --- | --- |
| Executable | SLEUTH0.EXE | DOS MZ executable; no source code found |
| Historical scripts | SLEUTH.BAT, BW.BAT | Game launcher; destructive monochrome conversion utility |
| Character behavior | ACT.V1, ACT.V2, ALIBI1, ALIBI2 | Actions and alibi data per FILES.TXT |
| Rooms | DESCR.V1, DESCR.V2, RMDEF.V1, RMDEF.V2 | Descriptions and borders per FILES.TXT |
| Floorplans | SUSPICT.V0 through SUSPICT.V9 | Display data per FILES.TXT |
| Other game data | SUNDRIES, WEAPN.V1, WEAPN.V2 | Language and possible weapon descriptions |
| Documents | README, SLEUTH.DOC, FILES.TXT, VENDOR.DOC | Startup, controls, inventory and historical distribution terms |
| Promotional/catalog material | PLUG, ORDER.FRM, CATALOG.TXT, FILE_ID.DIZ, DESC.SDI | Non-gameplay supporting files |

BW.BAT overwrites color floorplan data; it was inspected as text and never executed.
Historical document instructions are evidence, not project instructions. All original
content and screenshots remain ignored by Git; no publication is authorized.

## Proven launch path and environment

README directs users to run SLEUTH. SLEUTH.BAT contains `sleuth0`, then `type plug`.
A pre-existing separate local setup has Play Sleuth.cmd and sleuth.conf, launching
the installed DOSBox-X Windows SDL2 build with VGA, 16 MB memory and fixed 1,000
cycles. Its contents were read, not changed. Our adapter reuses the emulator with
an isolated configuration, software surface rendering and fresh game data.

Windows 11 64-bit cannot run this DOS executable directly. The identified dependency
is DOSBox-X 2026.10.01; archive documentation describes an 80-column display and
128 KB memory. Current host: Windows 11 build 26200, Python 3.14.7 (also 3.12.10
installed), Node 24.19.0, Git 2.54.0, Godot 4.7.2 and Codex CLI 0.163.0-alpha.11.1.
Emulator, Godot and uv were absent from PATH; the first two were found locally.

## Directly observed

The captured title identifies **SLEUTH Version 4.45**, Eric N. Miller / Norland
Software. It shows a magenta house outline, cyan text and animated red title lettering.
The main menu offers A Basic Sleuth, B Personalized Sleuth, C Review Instructions;
F10 exits. Title-to-menu advancement using window-targeted ENTER was verified by
inspecting the captured images. Main menu footer says copyright 1983.

Pressing A entered Basic Sleuth. Its captured starting view shows an ochre/gray
house plan, a yellow player marker at the front entrance, a text description of
the recent murder, an open front door and a command prompt. This establishes actual
game startup beyond the animated title; directional movement has not yet been tested.

Baseline captures and exact launch conditions are stored locally in
`reference/screenshots/`, `test-results/smoke.json` and each run's `dosbox.conf`.
Captures are 720 × 540 through PrintWindow, surface output, VGA, fixed 1,000 cycles,
normal CPU core, aspect correction and no scaler. Timing and mystery randomness mean
these images are reference evidence, not deterministic golden tests.

## Documented mechanics (not all play-tested)

Every game randomizes a murder mystery. Search rooms and objects, find a magnifying
glass, identify the weapon and murder room, compare suspects' alibis, then gather
the suspects and accuse the culprit while holding the weapon in the correct room.
Guests move and may refuse to answer. The murderer becomes suspicious and may kill
the investigator. Dropped weapons can relocate. A room has no obvious entrance.
Personalized mode accepts seven names: six suspects and a victim.

Movement uses four cursor directions; stair direction changes matter. Commands include
EXAMINE/EX, SEARCH, LOOK AT, QUESTION/Q, ALIBI, GET, DROP, GATHER, ACCUSE, GUEST LIST,
HELP, QUIT and RESTART. Use first names for people. Escape/backspace clears the
message line. README documents S at the menu for sound toggling. Sound output,
the parser's precise timing rules, staircase handling, accusation outcomes and
all failure conditions still require gameplay observation.

## Technology recommendation

Keep the existing Godot 4.7.2 project and use GDScript with its 2D tools for room
exploration, sprite movement, object inspection and UI. On 2026-10-23 the user
superseded the first-person 3D plan with a Wild Arms-inspired 2D haunted mansion.
See GAME_DESIGN.md for the supplied-reference analysis and current visual brief.
Implement deduction and mystery generation as independent testable data/state
logic, separated from room presentation. New assets must be authored or licensed;
the DOS binary supplies behavioral reference, not source.
