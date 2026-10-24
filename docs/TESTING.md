# Testing and validation

## Char alignment_01 review assets

Seven separate built-in image-generation jobs produced transparent masters. The native Compatibility review tool completed without Godot errors, verified pixel-preserving blank padding, and captured a comparison, three contexts and a closeup sheet. `python tools/validate_char_alignment.py` passes source/input hashes, seven RGBA assets, padded pixel recovery/margins, contact offsets, common scale, shorter seated extents, exact furniture IDs and five image dimensions. Reports: `test-results/char-alignment-review.log` and `test-results/char-alignment-validation.json`. No runtime code or game integration changed, so the full gameplay suite was not rerun. The user subsequently approved the seven artwork samples. Masks, collision/navigation/occupancy and actual fit remain pending. See [the review](CHAR_ALIGNMENT_01_REVIEW.md).

## Character pose planning audit — 2026-10-23

This documentation/metadata task produced no artwork, renderer change or gameplay
implementation. The derived inventory records 45 concrete pose IDs, 34 semantic
families, all 209 room contacts (163 enabled / 46 disabled), and all 84 orientation
IDs (38 currently used). Current native Godot capture evidence agrees with every
enabled contact's pose IDs and local-clearance result: 102 clear / 61 blocked.
Zero contacts are staging-approved. Char's seven proposed alignment jobs have no
executed generation prompts, tool calls, outputs or approvals. Her manifest links
the planning deliverables and preserves the existing identity reference hashes.

Validation commands:

```powershell
python tools/audit_character_poses.py
python tools/audit_character_poses.py --check
python tools/validate_character_pose_audit.py
```

The validator checks native-report parity, complete CSV/JSON correspondence,
source/family/pose references, unique seven-sample batch IDs, locally clear first
seat approaches, artifact/source hashes and documentation links. It does not
validate art, pose fit, path reachability or future event selectors. Results are
in `test-results/character-pose-audit-validation.json`. Existing native capture
evidence was reused because room data and runtime code were unchanged. The full
gameplay regression suite was not rerun for these documentation-only changes;
the previous completed runtime milestone is recorded below.

## Previous room furniture coverage

Latest room furniture coverage: **43 tests pass** in the full suite (59.34 s).
The furniture harness passes **616 engine/editor assertions**, including all 18
rooms, 14 registered backgrounds, unique room-scoped IDs, 84 orientation IDs,
mouse-driven calibration/save/reload and disabled-contact behavior. The official
MCP SDK owned-window smoke passes the expanded eight foyer IDs, F6 toggle,
overlay capture and clean Godot diagnostics; it stops its owned game process.

The native Compatibility renderer captured **18 individual 1440x960 tagged room
screenshots and three 1440x1560 floor sheets** without Godot errors. All three
floor sheets and dense dining/bedroom/storage examples were visually inspected.
Gold bounds and numbered legends identify furniture; orange/cyan marks identify
draft contact/approach points. All 118 unique tags remain unapproved for automatic
staging. There are 149 room-scoped instances; 102 of 163 enabled room contacts have
a clear local approach footprint under current colliders. This is not a pathfinding
or pose-fit approval; remaining contacts need calibration and/or navigation changes.
No NPC placement, collision, room connectivity, character artwork or animation was
changed. Char's 42 planned requirements include seven initial alignment samples;
these are planning records, not newly generated poses.

Reports: `test-results/furniture-tests.json`, `furniture-mcp.json`,
`tagged-room-coverage.json`, `tagged-room-capture.log` and `pytest.xml`.
Review [TAGGED_ROOM_SCREENSHOTS.md](TAGGED_ROOM_SCREENSHOTS.md) and
[CHAR_POSE_PLAN.md](CHAR_POSE_PLAN.md). The tag bootstrap was rerun and added zero
duplicate tags; existing mapper calibrations were preserved, with the locked front
door's exterior contact explicitly disabled.

```powershell
python tools/open_furniture_mapper.py
.venv/Scripts/python.exe -m pytest tests/test_furniture.py -q
.venv/Scripts/python.exe tools/dos-game-mcp/smoke_furniture.py
```

Latest character prototype: **39 tests pass**, including **1,560 character/occupancy
assertions** over 64 NPC seeds. The character harness also passes with the real
Compatibility renderer. Reports: `test-results/character-prototype-tests.json` and
`test-results/character-prototype-gui.log`; screenshots are in
`test-results/character-prototype/`. The owned-window MCP smoke records targeted
keyboard movement, Eleanor questioning, lens/library investigation and reset/cleanup
in `test-results/remake-smoke.json`. See [CHARACTER_RENDERING.md](CHARACTER_RENDERING.md)
for scope and remaining animation/background limitations.

```powershell
.venv/Scripts/python.exe -m pytest -q
# Configured Godot executable, headless or with --capture for native screenshots:
godot --headless --path . --script tools/character_prototype_checks.gd -- --npc-seed=20261023
.venv/Scripts/python.exe tools/dos-game-mcp/smoke_remake.py
```

Previous fixed-house integration: **38 tests pass**, including **222 actual-physics
walking/investigation assertions**. The same checks pass with the Compatibility
renderer, producing native captures of all 18 spaces. Every directed doorway/stair
endpoint (44) is walked, and save/load is checked from another floor. See
[FIXED_MANSION.md](FIXED_MANSION.md) for scope, reproducible commands and art gaps.
The earlier blueprint-only counts below describe historical validation.

Validated on 2026-10-23, America/Denver. Reports and captured reference material are
local and excluded from Git. No game binaries or captures should be published.

Latest blueprint validation: **34 automated tests passed**, exit code 0, including real stdio
discovery in modern and legacy modes. The original-game baseline exercised all 15
tools before the remake existed. The separate remake smoke now validates the real
launch, keyboard movement, inspection, captures, reset and process cleanup. Mouse
support still correctly returns unavailable.
The original title, main menu and Basic Sleuth entrance screen were captured and
visually inspected. The archive SHA-256 still matches the initial reference hash.

## Repeatable commands

Blueprint additions: tests/test_mansion_blueprints.py validates all four physical
door graphs, opposite ports, non-overlapping cells, aligned stair shafts and complete
reachability after removing either shaft. A real Godot run passes 180 compact-layout session checks:
seed reproduction, stable art, stair reversal/floor memory, JSON round trips, room
memory and corrupt-state rejection. Twelve rendered review captures cover all floors.
The checks include actual save-file write/read/replacement, arrival-port ownership
and map browsing without changing the current logical floor. The real-window foyer
smoke passed with startup blueprint metadata and stable selection during movement,
while preserving the clock, Eleanor, reset and owned-process cleanup checks.
These are logical topology/session tests, not physical walking or collision tests
for the unconnected new room paintings. See MANSION_BLUEPRINTS.md for the boundary.

Compact revision: each plan now has four functional rooms and two hallway/stair
spaces per floor. Tests reject the former oversized-plan save schema and verify
that the north front door is locked, has no destination and cannot be traversed.
The foyer's fourteenth engine assertion verifies its locked-front-door response.
test-results/screenshots/foyer-locked-front-door.png was rendered and inspected.
The previous real-window smoke predates the dialogue-only wording change; current
foyer engine checks and the native door capture cover that change.

Environment additions: tests/test_environments.py validates 18 assets and invokes
24 real Godot review checks. All 36 native/2x actor preview captures were rendered
and inspected; assets/rooms/review/asset-checks.json records dimensions, alpha,
unique hashes and paths. ENVIRONMENT_ASSET_QA.md details the visual review and the
remaining gameplay collision/transition boundary.

Run from the project root:

```powershell
.\.venv\Scripts\python.exe -m pytest tests -q --junitxml=test-results/pytest.xml
.\.venv\Scripts\python.exe tools/dos-game-mcp/smoke.py
.\.venv\Scripts\python.exe tools/dos-game-mcp/smoke_remake.py
codex mcp get sleuth_game --json
.\.venv\Scripts\python.exe tools/dos-game-mcp/verify_codex.py
```

Pytest does not launch the original. The explicit smoke client does: it starts the
stdio server, discovers tools, launches an owned DOSBox-X window, waits eight seconds,
captures the title, sends ENTER twice to accommodate title timing, captures the menu,
presses A, captures Basic Sleuth, restarts, captures again and stops the owned process.
It runs the fixed pytest suite through MCP and reads its persisted results. Test
reports: `test-results/smoke.json`, `latest-tests.json`, `pytest.xml` and the
`run-*/emulator.log` files. Every smoke invocation adds a fresh run and unique captures.

## Actual tool coverage

| Tool | Validation performed |
| --- | --- |
| inspect_game_archive | Real 33-file ZIP, expected SHA-256, no execution |
| get_game_environment | Real host/runtime/path/capability report |
| get_project_status | Current tree, tests and playable foyer status |
| launch_original_game | Real DOSBox-X window, title and Basic Sleuth captured and inspected |
| launch_remake | Real Godot foyer, verified owned HWND and readiness state |
| get_game_status | Not launched, live owned HWND/PID and terminated exit status |
| stop_game | Actual emulator terminated and waited; unrelated-process safety test |
| send_game_input | PID-targeted original menu input and remake movement/inspection, verified by live state; unsupported keys and durations rejected |
| send_mouse_input | Explicit unsupported result; no global mouse injection |
| capture_game_screenshot | Original PrintWindow PNGs and Godot viewport PNGs; foyer and clue panel visually inspected; absent game rejected |
| reset_game | Original fresh copy; remake fresh process resets player and clue state |
| read_game_logs | Bounded real emulator/Godot output and its actual path |
| run_project_tests | Real subprocess suite via MCP, exit code, timeout bound and JSON/JUnit evidence |
| get_test_results | Read back matching saved exit code and test summary |
| compare_game_screenshots | Real capture compared with itself, synthetic changed pixels/dimensions, unsafe path rejection |

SDK clients exercised both automatic protocol negotiation and legacy initialization
over real stdio subprocesses. Malformed game enums are rejected by SDK input validation.
Tests cover traversal, drive/absolute names, Windows devices, alternate data streams,
unsafe ZIP names, symlinks, case collisions, overwrite refusal and reference hash.
They also check missing executables, nonzero child exit, command deadline expiry,
emulator startup failure/timeout cleanup and stopping only a tool-owned process.

The first run exposed a ZIP path-normalization test issue and SDK structured-output
annotation issue. Both were corrected; final runs must be read from latest-tests.json,
not the retained initial failure report. No remaining test failures are known.

## Codex integration evidence and final desktop check

`codex mcp get sleuth_game --json` recognizes the project server without changing
global configuration. `verify_codex.py` feeds those returned settings to the installed
Codex app-server and requests `mcpServerStatus/list`; it discovered all **15** tools.
Evidence is `test-results/codex-discovery.json`. No chat or model run was created.
An app-server without a bound chat does not load project context automatically;
the verifier explicitly supplies the loaded server settings as command-line overrides.

This proves Codex runtime compatibility and discovery. It does not prove that the
already-open desktop chat has refreshed its registry. Close and reopen the project
or restart Codex, then check `/mcp`. For a fresh CLI connection, run `codex` from this
project directory and check `/mcp`. Trust the project if the client requests it.
The current conversation cannot hot-add the new tool namespace.

## Limits and troubleshooting

The server runs only stdio, with no listener. Local configuration allowlists the
external archive and emulator; model callers cannot supply alternative executables,
commands or shell text. All caller-supplied image paths stay inside approved project
screenshot directories, including resolved symlink checks. Output filenames are
validated and unique. Raw logs are bounded and are not interpreted as instructions.

Window control requires one visible top-level HWND with the child process's PID.
Key messages go directly to that HWND; they do not use desktop-wide SendInput.
Delivery only confirms that Windows handled the message. Screenshot inspection
confirmed the tested title/menu/A sequence; other keys and full parser behavior
require observation. Software surface rendering was selected so PrintWindow works.
Black/uniform images are rejected, but a screenshot cannot by itself prove semantic
correctness. Captures currently include whatever frame PrintWindow returns.

Games are tracked per server instance. A graceful server shutdown stops owned games;
an abrupt OS kill can leave an orphan which a new instance intentionally will not
adopt or terminate. Stop games before restarting the server. Multiple independent
clients may each have their own emulator, which is safe but potentially confusing.
All waits and subprocess operations have deadlines. Win32 message waits are bounded
per key; key batches are limited to 120. Shutdown uses terminate/kill and waits.

No emulator installation or system-wide automation setup is pending. The existing
interactive desktop was sufficient. Elevated, minimized, locked or remote sessions
may require separate validation. Full sound behavior is untested. Remake launch,
optional remake mouse controls and deterministic mystery scenarios remain pending
for later milestones. Foyer engine checks are now implemented.
Current get_project_status reports the available main scene.

## Playable foyer validation

The pytest suite includes a real headless Godot run of `--foyer-test`. Fourteen assertions
exercise actual CharacterBody2D movement and collision against a wall, the clock and
foreground furniture; opening, closing and repeating the clue interaction; and pausing
movement during dialogue. Five of the assertions cover starting guest questioning,
recording her alibi, returning to the menu, the evidence-dependent clock answer and
releasing the player on exit. Result: `test-results/foyer-engine-tests.json`. Missing
Godot causes a clearly reported skip on machines without the local configuration.

`smoke_remake.py` uses the official MCP client over stdio to launch the configured
Godot GUI binary. On Windows, the console executable is a wrapper which spawns the
GUI as another PID. Using the GUI binary directly is necessary for reliable ownership,
window targeting and shutdown. Both executable hashes are stored by setup_local.py.
An initial wrapper-based launch failed its readiness check; its verified child was
cleaned up. The corrected GUI-based launch and shutdown both passed.

The smoke sends a timed right-arrow hold and checks actual x movement, returns to the
entry, walks left/up to the clock, presses E, verifies clue_found/dialogue_open, saves
the rendered clue panel, presses Escape and confirms it closes. It restarts and checks
the initial position and cleared clue, then stops the exact owned process. Evidence:
`test-results/remake-smoke.json`, per-run state.json/remake.log and unique screenshot
paths inside the report. No global keyboard injection or model-selected commands occur.

The real-window smoke now also walks around the reading stand to Eleanor's window,
opens the question menu through E, asks for her alibi, checks the recorded topic and
actual answer text, returns to the menu and asks about the clock after examining it.
It captures the question menu and alibi, verifies Escape releases the player, and
checks that a restart clears the question history. An initial direct route collided
with the stand; the test route was corrected to walk around it. No collision was
disabled to make the conversation test pass.

A later restart exposed a transient status-snapshot validation failure. The status
reader now revalidates and retries briefly while the snapshot is being replaced,
without relaxing its project-path restriction. A regression test injects a transient
validation failure and verifies the next approved snapshot is returned. The final
26-test suite and real-window conversation/reset smoke both passed.

The camera update adds a default 2x following view and a Z overview toggle. The same
real-window smoke verifies camera_zoom starts at 2, changes to 1 and returns to 2,
then exercises clock inspection with the close view active. Entry, overview and
dialogue screenshots verify the larger investigator and fixed screen-space UI.
The actor's world-space height is 48 logical pixels, independently of the camera.

The remake's development hook is enabled only by the fixed launcher's --dev-session
argument matching `res://test-results/remake-<32 hex digits>`. It writes state and
handles a fixed capture.request filename. It accepts no command code or arbitrary
output paths and opens no network listener. Godot viewport captures avoid graphics
driver limitations of PrintWindow for the OpenGL renderer. Writes use temporary
files and rename when complete. Normal F5 launches do not enable this hook.

The main project uses the Compatibility renderer, nearest texture sampling, a
480 x 360 logical canvas and integer scaling. A separate default-renderer launch
captured `test-results/screenshots/foyer-native.png` at 480 x 360; the real-window
smoke captures at 960 x 720. Both sizes were visually checked. Artwork and generated
prompt provenance are documented in assets/foyer/ASSET_NOTES.md. The reading stand
is placeholder art; baked room lighting and minimal dust are the current atmosphere,
not a dynamic lighting or sound system. Whole-mystery gameplay is not implemented.

## Official API and configuration references consulted

Evidence milestone (2026-10-23): the complete suite passes 36 tests, including 76
headless evidence assertions. A separate actual Compatibility-rendered playtest
passes 39 assertions with Godot keyboard dispatch, collection, tool gating,
innocent controls, notebook, file persistence, invalid-save rejection and all
production variants. Native captures were visually inspected. The existing
real-window MCP smoke passed movement, zoom, clock and Eleanor regression checks.
See EVIDENCE_ASSET_QA.md for exact commands, artifacts and remaining scope.

Character review-v8 verification (2026-10-23): Godot parsed the contact-sheet tool
and rendered both sheets successfully. The gallery validator passed for 17 active
designs, 15 named photo-based identities, 24 views and seven alternate-look cards.
Numbers 16-19 are absent from the active roster; sources remain archived. Art
selections 01-15 match v7, including Sarah Jo's unchanged approved PNG hash recorded
in review-v8/change-checks.json. Jessica and John's cartoon faces and the complete
overview were visually inspected. Runtime assets and gameplay were not changed;
these checks do not establish runtime sprite scale or animation quality.

- [MCP Python SDK](https://py.sdk.modelcontextprotocol.io/) — current SDK 2.3.0, MCPServer and stdio transport.
- [SDK testing](https://py.sdk.modelcontextprotocol.io/get-started/testing/) and [client transports](https://py.sdk.modelcontextprotocol.io/client/transports/) — supported Client API.
- [Serving legacy clients](https://py.sdk.modelcontextprotocol.io/run/legacy-clients/) — compatibility testing.
- [Codex MCP configuration](https://learn.chatgpt.com/docs/extend/mcp?surface=cli) — project-scoped stdio configuration and MCP management commands.
- [Codex configuration basics](https://learn.chatgpt.com/docs/config-file/config-basic) — trusted project configuration.
- [Godot CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html) and [custom 2D drawing](https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html) — movement, top-down motion mode and drawing APIs.

The installed Codex CLI's generated app-server JSON schemas, held under
`test-results/codex-schema/`, established the exact discovery request fields.

## Directional next-phase planning validation — 2026-10-23

No art or runtime implementation was produced. SHA-256 comparison confirms all 112
existing character PNGs are unchanged, including the seven approved masters and
seven padded exports. Directional index validation checks all seven IDs, directions,
scoped approvals, file hashes and exact furniture contact references. The pose audit
check, contact/native-evidence parity validator and Char alignment validator pass.
Reports: `test-results/next-phase-planning-validation.json`,
`test-results/character-pose-audit-validation.json` and
`test-results/char-alignment-validation.json`. Native images/logs are previous review
evidence, not new runtime tests. No new screenshots or full gameplay run were needed
for this documentation/metadata change. Runtime contact calibration remains pending.

## Image approval and cleanup — 2026-10-23

Explicit approval preflight passes Char's 14 approved source/export files and the
four finalized detective frames. Negative checks reject missing/pending approval
and a changed approved hash. The Godot alignment exporter exits with code 2 and
IMAGE_APPROVAL_LOCK before any writes when a batch contains approved samples.
No new image generation, resampling or gameplay logic changes occurred.

The focused detective/character/environment/evidence/furniture/fixed-house/blueprint/
foyer suite produced 17 passes and one obsolete assertion requiring a duplicate
original PNG. That assertion now protects the canonical original using its recorded
hash and manifest path; its focused rerun passes (18 relevant tests passed in total).
Approved images and all other retained assets/reference images are byte-identical.
Markdown links and literal runtime asset references resolve; formatted screenshot
output templates are not missing input assets. Pose-audit and alignment validators
are rerun after refreshing retained-artifact fingerprints. Reports are under
`test-results/image-approval-validation.json` and `test-results/asset-cleanup-validation.json`.

## Directional folders and side-contact integration — 2026-10-23

Furniture catalog regeneration and native Godot furniture/editor tests pass after
adding side anchors and gaze-target transform/validation checks. Graphical Godot
Compatibility capture refreshed all 18 tagged rooms and three floor sheets without
script errors. The review gallery now includes facing arrows, gaze targets and exact
contact tables. Char's seven exports were moved and consistently renamed; approval
preflight still verifies the same source/export hashes. The full pose/contact audit
is updated to 247 room contacts, 201 enabled, 47 concrete pose IDs. All staging flags
remain false; locally clear endpoints are not pathfinding or sprite-fit approval.
Each relevant index.html is opened and linked for user review under the project-wide
rule. See test-results/directional-assets-side-contacts-validation.json for checks.

## Opt-in Char live placement test — 2026-10-23

F7 starts/finds Char, F8 randomizes her room and approved pose, F10 restores normal
mode. One identity-keyed roster replacement removes the old Char assignment; room
loads remove old actor nodes before spawning current occupants. Shared contact
rendering uses common 64/1673 scale and floor feet independently of chair seat.
All seven approved images remain unchanged. Seated masks/clearance/contact fit are
provisional and require visual review; this is not general NPC scheduling/staging.
Native checks cover 126 room visits, 100 rerolls, all seven poses, contact alignment,
save/load protection and roster restoration. The real owned-window smoke also
captured all seven poses and verified unique live assignments. See CHAR_LIVE_TEST.md
and test-results/char-live-test/index.html. No art approval or image hashes changed.

## HD/readability presentation preview — 2026-10-23

User reported Char and the overall game were too small. The internal viewport is
now 960×720, with up to a 1280×960 window, monitor-fit sizing and F11 fullscreen.
Shared adult stature is 80 instead of 64; identity ratios/proportions are preserved.
World/physics/furniture coordinates stay 480×360. The presentation adapter scales
camera/HUD/inspection UI into HD; detail zoom is 1.5× and Z provides full overview.
F7/F8 now focus Char in detail mode instead of forcing overview. Her source masters,
exports, approval hashes and original alignment metadata remain unchanged; 64 in
those source-review records is historical. Runtime source scale is 80/1673.

The live owned-window smoke captured all seven poses at 1280×960 and verified both
Z modes, F11 fullscreen on/off, and one Char assignment. Native checks verify HD
HUD/inspection scaling and preserve contact transforms/unique identity across room
visits/rerolls. Character/foyer/evidence, fixed-mansion, furniture and environment
checks pass. [Presentation comparison](../test-results/presentation-review/index.html)
uses two retained previous-runtime captures and current actual captures; source art
is never resampled. Presentation and chair fit still await user visual review.
Current room backgrounds retain their existing authored pixel detail; the change
increases display/readability, not the detail contained in those background files.


## First authored case and chair fit preview — 2026-10-23

F4 opens The Silent Library: three suspects, room-owned rug observation, evidence
gates, statements in the notebook, accusation and written ending. Wrong accusations
allow retries in this prototype. Case progress and roster round-trip through the
fixed session snapshot. The focused native integration run passes 31 checks;
actual Compatibility captures are in test-results/first-case/index.html. Three
Char chair offsets/foreground polygons are preview-only and await visual review.
Approved character PNGs are unchanged. See [FIRST_PLAYABLE_CASE.md](FIRST_PLAYABLE_CASE.md)
for controls, reproduction and remaining group/reveal/randomization work.


## Compact mansion scope — 2026-10-23

The active graph is nine unique backgrounds: seven main rooms plus two circulation
spaces. Physics traversal checks sixteen directed endpoints. Char room/pose coverage
is now 63 visits; older 18-room/44-endpoint reports above are historical. Native
current-room captures and explicit art gaps are in test-results/compact-mansion/index.html.
The first case retains all ground-floor evidence and suspect locations.
