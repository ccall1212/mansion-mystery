# Sleuth: haunted mansion in 2D

**Current compact scope:** four ground-floor rooms, two upstairs rooms and one
basement room, plus a main stair hall and upstairs landing (nine spaces total).
Every active background is unique. Earlier 18-space descriptions below are historical.
[Current room review](../test-results/compact-mansion/index.html). A top-of-screen floor/current-room map is recorded as future work.

For the consolidated future gameplay concepts and unresolved decisions, read
[Mansion mystery gameplay brainstorm](GAME_DESIGN_BRAINSTORM.md). This document
retains the visual brief and the history of the playable foyer.

Furniture metadata now has 84 directional IDs and a visual background mapper.
See [Furniture IDs and mapping](FURNITURE_IDS.md). This labels existing painted
furniture and exposes contacts; automatic NPC seating and pose generation remain future work.

## Current direction

The default game now runs one [fixed walkable mansion](FIXED_MANSION.md), starting
in the foyer and connecting 18 spaces across three floors. Room dressing and some
door/stair depictions are provisional. The original foyer remains independently
runnable; its historical milestone notes below do not describe the full current
walking scope. Seven temporary guests now randomize room and statement at session
start; this is a placement/conversation test. The complete murder case, schedules
and personality-driven NPC behavior remain unbuilt. Shared stature and the revised
Eleanor are documented in [CHARACTER_RENDERING.md](CHARACTER_RENDERING.md).

Compact-house update: use four main rooms plus at most two hallway/stair spaces
per floor. Start by connecting the ground-floor foyer, library, dining room and
kitchen into a small deduction case before expanding the playable floors. The
10-15-minute target needs playtesting. A first clue book now tracks examined objects,
collected items and explicitly magnified observations in the foyer. The front of the house is NORTH/top: the existing
foyer's top double doors are the locked front door, with no playable outside route.
This supersedes the older bottom-entrance composition proposal below. Main and
service stair routes remain, with stable return endpoints and floor memory.

Updated 2026-10-23: the user switched to **2D**, using supplied Wild Arms PS1
screenshots as visual inspiration, with a haunted-house or scary-mansion atmosphere.
This supersedes the first-person 3D plan. Keep Godot 4 and GDScript; use its 2D tools
for rooms, characters and objects. The first playable foyer now implements movement,
clock inspection, clue recording, dialogue and an original four-direction investigator.

The core experience remains exploring rooms, inspecting specific objects, questioning
suspects and solving Sleuth's murder mystery. Make the mansion inviting to explore
and uncomfortable to linger in.

## Reading the supplied references

| Reference | Qualities to carry into original artwork | Mansion interpretation |
| --- | --- | --- |
| Ship deck with characters | Elevated three-quarter view, expressive sprites, detailed readable props | Furnished rooms with cabinets, portraits, clocks and potential evidence |
| Characters facing a distant ship | Foreground/background separation, weather and distant silhouettes | Storm-lit windows and unsettling glimpses of the grounds |
| Stone entrance and statues | Symmetrical architecture, clear paths, warm lights, detailed masonry | Grand foyer, stair landing, statues and shadowed doorways |
| Characters on a cliff | Layered scenery, scale and atmosphere | Later views over the estate or from a balcony |

### Additional examples and foyer composition

The seven subsequent user-supplied examples are preserved locally under
`reference/art-direction/wild-arms/` (ignored by Git). The image numbers below refer
to that second batch. These refine the brief without adding new gameplay systems.

- **Image 3, gothic landing:** primary architectural reference. Use a raised central
  doorway, shallow stairs, paired statues or columns, carved trim and dark recesses.
  Retain enough floor contrast to see the player and the route through the room.
- **Image 7, furnished interior:** primary furnishing reference. Rugs, shelves,
  fireplace, chairs and small objects make a compact room feel inhabited. Preserve
  clear walking space between these clusters and make evidence individually recognizable.
- **Image 2, dialogue room:** use a lower-screen bordered panel with pale readable
  text, a speaker/object heading and a continuation indicator. For our mansion,
  try a charcoal/navy panel and subdued brass border. The panel pauses movement
  during inspection; it must not hide the selected object or interaction prompt.
- **Images 1 and 6, timber exterior/town:** maintain the scale relationship between
  compact characters, full-height doors, tall visible walls and detailed small props.
  Characters should feel situated inside the architecture rather than filling it.
- **Images 4 and 5, stone courtyard/castle walkway:** repeat masonry and floor patterns
  consistently, with architectural edges, columns and light sources defining paths.

For the first foyer, propose an entrance at the bottom, a central runner leading to
a short stair and sealed double doors at the top, a portrait or grandfather clock
on one side and a furnished candlelit corner on the other. Warm highlights against
cold shadows establish the haunted-mansion mood. Stairs and the far doorway can be
scenery for the first prototype; only the foyer and one inspection need to work.

Judge the look at gameplay scale: readable sprite poses, visible wall faces and
furniture depth, textured materials, and deliberate light placement. Use crisp source
pixels rather than reproducing screenshot blur, compression, scanlines or logos.

Use these images for composition, proportions and mood. Author new tiles, sprites,
characters, props and UI. Wild Arms game assets are not part of the remake.

## Proposed visual treatment

### Third reference batch: room identity and lighting

Nine additional user-supplied references are saved locally in
`reference/art-direction/wild-arms/batch-03/`. Image numbers in this subsection refer
only to that batch. These are visual references, not confirmation of new mechanics.

| Images | Design guidance |
| --- | --- |
| 1, guest room | Distinguish private rooms with beds, bedside objects and a fireplace; compose furniture around usable walking space. |
| 2, firelit entry | Frame a dark doorway with columns and warm fire; use a bordered runner to guide the eye. The glowing floor symbol does not imply a magic or teleport mechanic for our game. |
| 3, grand hall | Establish mansion scale through tall windows, curtains, chandeliers, statues and a long central axis. |
| 4, torchlit stone | Let small flames create local highlights against cold stone; keep the player's silhouette readable. |
| 5, library | Give the library dense bookshelves and isolated books that can later serve as inspectable evidence. |
| 6, reception hall | Use counters, runners and broad floor space to stage suspect conversations without crowding movement. |
| 7, night exterior | Main exterior mood reference: blue-green foliage and stone, dark windows, an imposing door and a narrow approach. |
| 8, cold statue hall | Main ominous-interior mood reference: charcoal/teal masonry, paired statues, cold light and strong architectural symmetry. |
| 9, dark stairwell | Use sparse light and a constrained view to suggest unexplored space; preserve enough contrast to read steps and exits. |

Proposed room palette: cold teal/blue-green for the exterior and unwelcoming stone
halls; muted wood and amber firelight for occupied guest rooms, reception and the
library. Use the contrast to make movement between rooms atmospheric. Keep the foyer
as the first playable milestone; these examples guide later room identities rather
than expanding the initial build. Cold-flame effects, statues and the apparent
haunting are visual possibilities; the supernatural explanation remains undecided.

For the foyer, combine the earlier gothic landing's structure with this batch's
image 8 palette. Place a warm candle near the inspectable clock or portrait so the
evidence remains easy to find against the colder surroundings.

- Elevated three-quarter 2D rooms showing floors, back walls and furniture fronts.
  Keep a consistent projection with a fixed camera orientation.
- Compact, expressive sprites with clear silhouettes and four facing directions.
  Sort characters and props by their feet so walking behind furniture reads correctly.
- Rich wood, worn rugs, aged wallpaper, dusty shelves, tarnished brass and stonework.
  Give each room recognizable objects and a distinct arrangement.
- Midnight blue, charcoal, muted green and brown, punctuated by amber candlelight.
  Keep paths and clues readable in shadow.
- Subtle candle flicker, rain at windows, occasional lightning and drifting dust.
  Start with one or two effects so clues stay legible.
- Crisp pixels, nearest filtering and a consistent asset scale. Test a 320 x 240
  logical canvas as a starting proposal; settle resolution after checking dialogue
  readability and integer scaling.

These are proposed choices based on the images, not claims about the reference game's
internal renderer or the DOS original.

## Investigation and atmosphere

Approach and face an object to inspect it through a contextual prompt. Present its
description or a suspect conversation in a compact dialogue panel. Preserve the clue,
alibi, weapon and accusation loop as the foundation.

Creaking floors, stopped clocks, ambiguous portraits, locked rooms, distant footsteps
and changing light can create tension. Whether the haunting is real or staged remains
open; supernatural appearances do not yet change the murder-mystery rules. Combat and
a full RPG system are outside the prototype scope.

Keep room/object IDs, descriptions, clue state, inventory and suspects separate from
tilemaps and sprites. Add deterministic test seeds before randomized cases. Observe
the original before deciding how movement and actions advance suspicion.

## First playable milestone

Build one mansion foyer with a controllable placeholder sprite, collision, correct
draw order and one inspectable portrait or clock that opens a text panel. Include a
candle or storm-lit window to test atmosphere at gameplay scale. Proposed controls:
arrows/WASD to move, E/Enter to interact, Escape to close dialogue. These controls are
implemented; R returns to the entrance without clearing the clue. The initial room
uses a 480 x 360 logical canvas to leave room for readable text and architectural detail.

Acceptance: explore without crossing walls or furniture, inspect the object, read
and close its description, and repeat the interaction. Capture and inspect native
and enlarged screenshots. Validate launch_remake and targeted keyboard input against
the actual remake window. Expand only after this slice works.

## Open decisions

Final sprite size/resolution, grid versus continuous movement, art production workflow,
mansion layout, degree of supernatural content, accessibility and controller support
remain open. Windows is the current development target. The next visual checkpoint
is the foyer, not a complete mansion asset set.

## Character references

The user supplied two Wild Arms character compilation sheets. They are saved under
ignored `reference/art-direction/wild-arms/characters/` for proportions, facing
directions and walking-pose reference. No extracted frames enter runtime assets.
Our original investigator uses chestnut hair, a charcoal-teal coat, burgundy waistcoat,
cream collar and leather boots. Four directional rows with four frames per row are
rendered from `assets/foyer/investigator-sheet.png`; frame alpha bounds align feet.
The generated first-pass animation remains subject to visual and movement feedback.

## First house guest: Eleanor Vale

Eleanor stands at the right-hand window and looks outside while idle. She faces the
player during a conversation. Her original silver-haired, green-dressed sprite has
back and front poses. Near her, E/Enter opens a four-item menu: alibi at 11:47,
unusual sounds, the clock, and leave. Up/Down chooses a topic; Enter asks or returns
to the menu; Escape exits. Movement is paused throughout the exchange.

Her alibi places her at the window watching a carriage leave. She mentions upstairs
footsteps and a quiet door. After the clock has been inspected, she recalls it still
ticking and someone opening the case. These are newly authored prototype dialogue,
not observations of the DOS game. Topic history is recorded in this session; there
is no accusation logic or truth model yet. The later evidence milestone adds a
persistent object notebook; conversation topic history remains session-only.

The user's floating/leg-motion feedback remains an animation-art task. The current
small pass anchors sprites using alpha >= 0.5, tightens the contact shadow, advances
walking frames by actual distance travelled and enables camera smoothing. This does
not replace the nearly similar generated walking poses with a polished new cycle.

## Character scale and camera feedback

The user found the initial investigator too small relative to the room, as well as
too distant on screen. His world-space sprite height is now 48 logical pixels rather
than 29, preserving his proportions and foot anchor. The default camera follows at
2x magnification, clamped within the room; Z switches to the whole-room overview.
UI uses a separate CanvasLayer so reading size and panel positions stay stable.
These are separate adjustments: sprite height controls scale against furniture;
camera zoom controls how much of the room is visible.

Two additional supplied environment sheets, Malduke Area 21 (Statue Area) and Maze
of Death, are saved in ignored `reference/art-direction/wild-arms/environment-sheets/`.
They provide references for masonry, statues, trim and fire animation. No sheet tiles
have been extracted into runtime assets; future environment art remains original.

## Current room furniture coverage

All 18 prototype rooms resolve background-local orientation and interaction tags,
with 118 unique visible-object tags across 14 backgrounds (149 room-scoped
instances). See [TAGGED_ROOM_SCREENSHOTS.md](TAGGED_ROOM_SCREENSHOTS.md).
Contacts remain drafts; automatic staging, pose-specific placement and foreground
occlusion are pending. Char is the first planned full static pose set, starting
with seven alignment samples after room review; see
[CHAR_POSE_PLAN.md](CHAR_POSE_PLAN.md). Walking animation remains a separate task.
