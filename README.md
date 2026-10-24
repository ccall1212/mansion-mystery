# Sleuth 2D haunted-mansion remake — development environment

**Current compact scope:** four ground-floor rooms, two upstairs rooms and one
basement room, plus a main stair hall and upstairs landing (nine spaces total).
Every active background is unique. Earlier 18-space descriptions below are historical.
[Current room review](test-results/compact-mansion/index.html). A top-of-screen floor/current-room map is recorded as future work.

**First playable case:** press **F4** and choose **Begin the first case**. Investigate,
question three guests, collect evidence and accuse in the foyer. **N** records
objects, statements and floor findings. [Controls and prototype limits](docs/FIRST_PLAYABLE_CASE.md).
Char's three chair fits and the case screens are ready for [visual review](test-results/first-case/index.html).

Remake the DOS murder mystery as a **2D pixel-art haunted mansion** in **Godot 4 / GDScript**:
explore furnished rooms from an elevated three-quarter view, inspect objects and
question suspects. The user's Wild Arms PS1 references guide the visual direction;
the haunted-mansion brief supersedes the previous first-person 3D plan.
This initialization preserves the existing Godot project and provides a local
stdio MCP server for observing and testing both games. The first playable foyer is
now available at `src/foyer/foyer.tscn`.

Future gameplay concepts, confirmed direction, proposed balance values and open
questions are preserved in [Mansion mystery gameplay brainstorm](docs/GAME_DESIGN_BRAINSTORM.md).
See [the development plan](docs/DEVELOPMENT_PLAN.md) for implementation status.

Current character prototype: shared 64-pixel adult stature, faster distance-synchronized
walking, revised Eleanor, and seven seeded temporary guests with stable statements.
See [character rendering and temporary guests](docs/CHARACTER_RENDERING.md).

Image approval and retention: [shared image workflow](docs/IMAGE_ASSET_WORKFLOW.md). Show drafts, record explicit approval, then promote approved files; retain useful results/instructions rather than every experiment.

Live Char pose test: press **F7** in the game, **F8** for a new room/pose, **F10**
to exit. One global assignment prevents duplicates. See [controls and limits](docs/CHAR_LIVE_TEST.md).

Furniture orientation IDs and a visual background mapper are available:
`python tools/open_furniture_mapper.py`. See [Furniture IDs and mapping](docs/FURNITURE_IDS.md).

## Dependencies and layout

Validated on Windows 11 with Python 3.14.7, Godot 4.7.2, DOSBox-X 2026.10.01
SDL2, Git 2.54.0 and Codex CLI 0.163.0-alpha.11.1. Python 3.11+ is required.
Existing emulator and engine installations were reused; no emulator installer was run.

- `project.godot`, `src/`, `assets/`: existing engine project and future original work.
- `tools/dos-game-mcp/`: SDK 2.3.0 server, setup and verification clients.
- `tests/`: archive, safety, process and stdio protocol tests.
- `docs/`: findings, 2D visual direction, development priorities and testing.
- `reference/original/`, `reference/inventory.json`, `reference/screenshots/`: private reference copies and captures.
- `test-results/`: disposable game copies, emulator diagnostics, smoke, Codex discovery and test reports.
- `logs/`: reserved for future remake logs.

Reference material, generated output, the virtual environment and local path settings
are ignored by Git. Git was initialized without commits. The archive remains untouched;
its hash and preservation policy are recorded in docs/ORIGINAL_GAME_ANALYSIS.md.

## Setup and Codex connection

The current machine is already configured. To recreate the environment from the project root:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r tools/dos-game-mcp/requirements-lock.txt
.\.venv\Scripts\python.exe tools/dos-game-mcp/setup_local.py --archive "<path-to-sleuth.zip>" --emulator "<path-to-existing-dosbox-x.exe>" --godot "<path-to-godot-console.exe>"
codex mcp get sleuth_game --json
.\.venv\Scripts\python.exe tools/dos-game-mcp/verify_codex.py
```

The setup script safely extracts only when no reference directory exists; otherwise
it checks the existing files against the archive. It creates ignored `local.json` with
actual paths and emulator/archive hashes, and project-scoped `.codex/config.toml`.
Existing unrelated project and user MCP settings are preserved. Stable absolute local
paths are necessary in the ignored config; rerun setup after moving the project or
recreating the environment, and resolve an existing differing server table manually.

Close and reopen this project in Codex (or restart the app), then check `/mcp` for
`sleuth_game`. To open a fresh CLI session from this directory, run **`codex`**.
Project settings require a trusted project. If Codex presents a trust prompt, review
the project and accept it there; setup does not change global trust settings.

Codex's config loader recognizes this project server. Its app-server discovery has
also returned all 15 tool definitions using the settings read by `codex mcp get`.
That isolated check creates no chat and uses no model. An unbound app-server has no
project/thread context, so the verifier passes those loaded server settings as CLI
overrides. The existing desktop chat's tool registry has not been reloaded; verify
the new connection after reopening rather than assuming hot reload occurred.

## Launch, inspect and test

In a connected Codex session, call `get_game_environment`, `inspect_game_archive`,
then `launch_original_game`. Wait about eight seconds for the animated title to
finish, capture it with `capture_game_screenshot`, and send `keys=["ENTER"]` with
`send_game_input` to reach the menu. Press `a` for Basic Sleuth. Capture again to
verify the response. Finish with `stop_game`.

The launcher mounts a new disposable copy under `test-results/run-*/game`, uses
fixed 1,000 CPU cycles and VGA emulation, and runs only the verified `SLEUTH0.EXE`.
Neither the archive nor the reference copy is mounted into DOSBox. The historical
batch launcher also displays a promotional file after exit; this adapter omits that.
`reset_game` restarts from a fresh copy; it does not guarantee the same random mystery.

For a standalone end-to-end test including a real game window:

```powershell
.\.venv\Scripts\python.exe tools/dos-game-mcp/smoke.py
```

For automated tests without launching the game:

```powershell
.\.venv\Scripts\python.exe -m pytest tests -q --junitxml=test-results/pytest.xml
```

The MCP tool `run_project_tests` runs that fixed suite with a 90-second deadline,
records JSON/JUnit results, and exposes them via `get_test_results`.
Start the raw stdio server for troubleshooting with:

```powershell
.\.venv\Scripts\python.exe tools/dos-game-mcp/server.py
```

It waits for MCP JSON messages on stdin; use the supplied clients to test it.
It opens no network listener. See docs/TESTING.md for tool coverage and evidence.

## Remake and limitations

### Fixed walkable mansion — current default

F5 in Godot now launches one fixed 18-space mansion, starting in the foyer. Ground,
upper and basement floors each have four main rooms and two circulation spaces.
Approach marked passages and press E to enter. TAB shows the room/floor directory;
Z toggles zoom. Collect the magnifier from the foyer reading stand, then investigate
the knife in the library. The front entrance remains locked.

F5/F9 in the running game save/load room, position, visits and investigation state.
Some room dressing and stair/door artwork is provisional. See
[Fixed mansion controls, routes and art gaps](docs/FIXED_MANSION.md) and
`assets/mansion/review/fixed-mansion-contact.png`. The older foyer and art-review
scenes remain available independently. A complete murder case is still pending.

### Furniture tags and Char pose planning

All 18 playable rooms have directional furniture annotations, using 84 orientation
IDs and 118 object tags across 14 backgrounds. F6 toggles the development overlay.
Use the visual mapper to tag future backgrounds. See
[tagged room screenshots](docs/TAGGED_ROOM_SCREENSHOTS.md),
[furniture IDs and mapper](docs/FURNITURE_IDS.md) and
[Char's planned pose set](docs/CHAR_POSE_PLAN.md). Contacts remain drafts;
automatic seating and new character pose art are pending.

The [full pose audit](docs/CHARACTER_POSE_AUDIT.md) adds personality, emotional,
questioning and murderer-reveal requirements to the furniture subset. Start future
character production with the [repeatable workflow](docs/CHARACTER_POSE_PRODUCTION_WORKFLOW.md)
and [parameterized prompt](docs/CHARACTER_POSE_PRODUCTION_PROMPT.md). Char's
production manifest is initialized for planning; no new pose artwork exists yet.

### Object inspection and evidence

The fixed house places the knife in the library, with an innocent broken hand mirror
and a collectible magnifier in the foyer. The standalone legacy foyer retains its
original three-object layout. E opens inspection, D gives
detail, C collects allowed objects, and M explicitly uses the collected lens.
N opens the clue book; left/right browses entries and Enter reopens an object.
F5/F9 explicitly save/load the current investigation, including collected items,
ordinary inspections, magnified observations and the clock note.

Eleven original props have two physical variants each, plus one magnifier asset.
The production review scene is src/evidence/evidence_review.tscn (F6); it includes
all variants without populating unfinished rooms. Find lens then C enables its
local tool checks. Object and forensic data live in assets/objects/object-manifest.json.
See docs/OBJECT_VARIANTS.md, EXAMINATION_DESCRIPTIONS.md and EVIDENCE_ASSET_QA.md.
This is an investigation slice; generated cases and accusation remain pending.

### Mansion blueprint review

Four compact seeded three-floor blueprints are now available: four main rooms and
two hallway/stair spaces per floor. The north-facing front door is locked; there
is no playable route outside. Open
src/mansion/blueprint_review.tscn and press F6 to inspect plans, rehearse logical
routes, check main/service stair returns, and save/load the blueprint session.
1-4 selects a plan, F1-F3 changes the viewed floor, Enter rehearses the route to the
selected room, and R starts a new seeded review. The review chooses its logical
template once at startup; --mansion-seed=1234 reproduces it.
These four layouts remain review plans. The default game uses the separate fixed
walking layout described above; its room art and some passage alignments are provisional.
See docs/MANSION_BLUEPRINTS.md, docs/MANSION_ASSET_REQUIREMENTS.md and the offline
assets/mansion/review/blueprint-gallery.html.

### Environment art review

Nine environment types now have two distinct layouts each (18 separate 480 x 320
backgrounds). See docs/ROOM_ROSTER.md for all filenames, observed entrance directions
and collision work. Open src/environments/environment_review.tscn and press F6:
1-9 selects a room, V selects its alternate layout, arrows browse, Z toggles zoom,
A toggles comparison characters and P toggles separate props. These are art-review
controls; selected backgrounds now have separate fixed-house collision/exit metadata.
The local gallery and contact sheets
are under assets/rooms/review/. See docs/ENVIRONMENT_ART_GUIDE.md and
docs/ENVIRONMENT_ASSET_QA.md for style, provenance and actual validation.

Open `project.godot` in the installed Godot editor and press **F5**. The main scene
is the mansion foyer. Walk with **WASD or arrow keys**, approach the grandfather clock
on the left and press **E or Enter** to inspect it. **Enter or Escape** closes the
description. **R** resets the character to the starting position, keeping discovered clues.
Restarting the game clears the clue. The north/front doors are locked and have an inspection response;
they do not lead outside. There is one house guest you can question; the
full mystery and sound are not implemented yet. Other rooms are now reachable in
the fixed house; their scene-specific art gaps are documented separately.

**Eleanor Vale** stands at the right-hand window. Approach her and press **E/Enter**.
Use **Up/Down** to select a question and **Enter** to ask it. Enter returns from her
answer to the question list; **Escape** leaves. Ask about her alibi, unusual noises,
or the clock. Inspecting the clock first changes her answer about it. Her responses
are an authored prototype conversation, not a complete generated murder case.

The investigator is now 48 logical pixels tall (increased from 29 to improve his
scale beside the furniture). A close 2x camera follows him within the room bounds;
press **Z** to toggle the whole-room overview. The header, prompts and dialogue stay
fixed on screen while the world zooms. Collision remains anchored at his feet.

The project uses a 480 x 360 logical canvas with integer scaling, a 960 x 720 initial
window, nearest texture filtering and Godot's Compatibility renderer for this 2D
prototype. Its original generated art is documented in `assets/foyer/ASSET_NOTES.md`.
The character, furniture collider, clue state and UI remain separate from the backdrop.

With the MCP connection active, use `launch_remake`, `send_game_input(game="remake",
keys=["LEFT"], hold_ms=500)` and `capture_game_screenshot(game="remake")`. The key tool
targets the owned window. `get_game_status(game="remake")` includes live position,
clue and dialogue state so acceptance can be checked independently of screenshots.
Use `reset_game(game="remake")` for a fresh scene and `stop_game(game="remake")` to
finish. The launcher validates the configured Godot GUI executable's hash, imports
resources with a deadline, then waits for both an owned window and scene readiness.

```powershell
.\.venv\Scripts\python.exe tools/dos-game-mcp/smoke_remake.py
```

This real-window smoke walks to the clock, inspects it, checks the live state,
captures screenshots, closes the dialogue, verifies a fresh restart, and stops the
owned game. It also walks to Eleanor, asks for her alibi and questions her about the
clock. Pytest additionally runs fourteen checks inside Godot's physics loop.
See docs/GAME_DESIGN.md for the current visual brief; the next milestone is a second
room and a second guest whose account can be compared with Eleanor's.

Mouse input is currently unsupported. Keyboard input uses PID-verified Win32 messages
and has been observed controlling both games; each call confirms window delivery.
The smoke additionally checks semantic acceptance using the remake's reported state.
Original screenshots use PrintWindow and software surface output; remake screenshots
come from Godot's rendered viewport through a local capture request. Both require an
owned game window. The development state/capture hook is enabled only by a launcher
argument restricted to a generated directory under test-results; it opens no port.
Minimized, locked, disconnected or elevated desktop sessions may not work. Pixel
comparison is diagnostic only. Sound behavior and complete gameplay are not validated.
Do not change the emulator binary without re-verifying and updating local settings.

Character next-phase planning: [directional assets, expressions and interactions](docs/CHARACTER_DIRECTIONAL_PIPELINE_PLAN.md). Char’s seven alignment samples have artwork approval; runtime pose integration remains pending.

Browse [Char by direction](assets/characters/poses/char/index.html), [Char’s chair contexts](assets/characters/poses/char/review/alignment_01/index.html), and [all tagged rooms with side contacts](assets/furniture/review/all-rooms/index.html). Open the relevant index.html whenever associated work changes.

Larger presentation preview: 960×720 internal viewport, up to 1280×960 window, 80-unit shared character height. Z toggles detail/overview; F11 toggles fullscreen. [Compare before/after](test-results/presentation-review/index.html).
