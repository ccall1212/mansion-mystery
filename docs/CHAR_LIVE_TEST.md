# Char live room and pose test

Run the normal game, then press **F7**. This is an opt-in placement/fit test, not an
autonomous NPC schedule or completed procedural staging system.

- **F7** starts the test or finds Char at her existing assignment. It does not reroll.
- **F8** replaces her assignment with a randomized compatible room/approved pose,
  then takes the detective there. It never appends another Char.
- **F10** exits the test and restores the original seeded NPC roster and persistence.
- **Z** toggles detail/overview. **F11** toggles fullscreen. The test starts with a closer view of Char; movement resumes detective camera following.
- Walk/use doors normally to inspect other rooms. Char stays in her assigned room;
  returning does not reroll her. The HUD reports global and visible Char counts.
- Save/load is disabled during the test, including the evidence controller's early
  input handler. Test assignments are session-only and cannot overwrite normal saves.

The seven approved directional PNGs are loaded from Char's explicit asset index.
Standing poses use reachable clear floor candidates, avoiding other occupants.
Seated poses use only the three alignment_01 contacts: kitchen lower chair east,
library armchair south, foyer armchair west. Their manual contact calibration,
skirt clearance and foreground chair masks remain **provisional**, despite artwork
approval. No new artwork or mirroring is involved.

## Identity and rendering contract

`char_pose_session.gd` replaces the roster entry keyed `likeness-photo01` in one
assignment operation. The old prototype Char entry is removed, while all other
identities remain. Room loading removes previous actor nodes synchronously before
spawning current-room occupants and blocks duplicate IDs in a room. Exactly one
global Char record exists; zero or one rendered actor exists according to her room.
The assignment is independent of room entry and persists until an explicit reroll
or test exit. It does not simulate a journey between rooms.

`pose_npc.gd` verifies approval and file hash and draws the current asset. The shared
renderer now supports common standing-reference source units plus pose-specific
floor/contact landmarks. Char uses the shared runtime height (currently 80)/1673 source scale for all postures; seated
poses stay shorter. Nodes, shadows and collision use estimated floor feet, while
the source seat lands on the furniture seat. Existing standing/animation rendering
keeps its previous path. Furniture masks and general-purpose occupancy/staging are
still future work, not enabled by this test.

## Reproduce and review

```powershell
python tools/check_image_approval.py assets/characters/poses/char/batches/alignment_01.json
python -m pytest tests/test_char_pose_live.py -q
python tools/dos-game-mcp/char_live_test.py
# To leave the owned interactive game open until the user closes it:
python tools/dos-game-mcp/char_live_test.py --handoff
```

The native lifecycle harness checks all seven poses across all 18 rooms (126 room
visits), 100 rerolls, exact source-contact transforms, constant standing scale,
immediate old-node removal, unchanged assignments on room visits, save/load safety,
and exact original-roster restoration. The owned-window MCP smoke uses real F7/F8
input, verifies uniqueness from live state, and captures all seven samples.

[Open live review index](../test-results/char-live-test/index.html).
This disposable gallery contains actual runtime screenshots, not new source art.
Open/show it after each refresh and request visual review of placement; automated
identity checks do not approve seating fit. The handoff process retains ownership
of its game and stops/cleans it up when its session ends; close the game when done.
