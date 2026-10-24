# Walking, shared stature and temporary guests

Current presentation preview: 960×720 internal viewport, up to 1280×960 window,
shared adult reference height 80, detail camera 1.5×. `src/presentation.gd` scales
the existing 480×360 coordinate space into HD; HUD and inspection panels scale
with it. Z toggles overview and F11 fullscreen. No source character PNG changes.
See [the measurement standard](CHARACTER_MEASUREMENT_STANDARD.md) and
[before/after review](../test-results/presentation-review/index.html). Earlier
milestone measurements below describe the previous 64-unit/480×360 presentation.


Current implementation update: [the opt-in Char live test](CHAR_LIVE_TEST.md) now consumes all seven approved samples through the shared standing-reference/contact renderer. Production staging, general pose selection and chair masks remain pending. Existing measurements and approved artwork are unchanged.

For new pose production read [the measurement standard](CHARACTER_MEASUREMENT_STANDARD.md)
and [pose audit](CHARACTER_POSE_AUDIT.md). The inspected standalone renderer still
uses each image's own opaque height. Seated/kneeling/crouched/lying art needs an
authorized shared standing-reference/contact adapter before integration; this
documentation does not change the renderer. Walking is being handled separately.

Current prototype, 2026-10-23. This changes walking, display scale and temporary
occupancy only. It does not finalize character designs or implement a murder case.

## Shared rendering rule

`assets/characters/rendering.json` sets adult stature to **64 logical pixels**.
`src/characters/character_render.gd` applies it to the investigator, Eleanor and
every reusable prototype NPC. The old player height was 48 and Eleanor's was 47.
Original images retain their resolution and aspect ratio; backgrounds are unchanged.
Camera zoom scales the entire scene together, so zoom is not the stature fix.

Single sprites are measured from opaque artwork, excluding transparent padding.
Animation sheets use one maximum opaque height across all cells, rather than
independently normalizing each frame (which made the body change size). A median
torso axis corrects inconsistent cell centering; the lowest opaque row anchors the
feet to the collision origin. Shadows share that anchor. Nearest filtering remains
enabled. Jessica has an intentional 0.85 height ratio because the user described her
as a particularly short adult; source-image padding never determines stature.

New cast additions should use this renderer and a feet origin, not custom height
constants or hand-resized files. A height ratio expresses intended stature only.
The player retains its small feet collider for the existing elevated perspective.

Eleanor now uses the existing revised, larger-head green-dress design from
`review-v2/masters/eleanor-proportion-v2.png`, technically trimmed to
`prototype/eleanor-revised.png`. The old two-pose source is preserved. The revised
source has one standing pose, so her conversation no longer visually turns between
two artworks. Her questions, answers and saved conversation state still work.
A maid outfit and additional directions remain future artwork decisions.

## Walking

Movement increases from 78 to **112 logical pixels/second** (about 44% faster).
Cardinal facing uses the dominant movement axis and remains stable on diagonals;
diagonal velocity stays normalized. There is no added acceleration delay.

The existing 4 by 4 sheet has down, left, right and up rows. Its existing order
0,1,2,3 is retained after frame inspection. Animation advances by distance actually
traveled, one cycle per 56 pixels (two cycles/second at full speed). Walls and
dialogue cannot advance a stationary character's walk. Releasing input returns to
frame 1; minor physics collision recovery cannot restart the animation.

There is no new pose, invented leg movement or regenerated sprite sheet. Existing
side-view frames have very similar leg silhouettes, so residual sliding remains
an artwork limitation. Timing and consistent frame scale improve the current walk;
a stronger alternating-leg cycle will require separately authorized art work.

## Temporary occupancy and statements

Seven distinct existing designs are used: Char, Justin, Gage, Chris, Sarah Jo,
Jessica and John. `prototype/roster.json` separates their identities, original
sources, display ratios and technically extracted transparent sprites. This does
not promote draft designs to final approval. `tools/prepare_prototype_characters.gd`
recreates the cutouts from the current review catalog, without resizing source art.

`prototype/spawning.json` configures placement clearance. `prototype_roster.gd`
assigns one character to each of seven distinct furnished rooms, excluding the
foyer and circulation spaces. Candidates use existing feet geometry, reachable
navigation cells, clearance around furniture, evidence objects, all incoming
arrival positions and exits. Existing object placement data now lives in the
fixed mansion manifest so spawning and scene placement use the same coordinates.

A new process/test session picks an independent NPC seed. For reproduction:

```powershell
# Use the configured Godot executable with these arguments:
godot --path . -- --npc-seed=20261023
```

The fixed mansion itself does not randomize. Each character receives one of two
room-specific placeholder statements from `prototype/statements.json`. Different
rooms have different statements. E near a guest opens the existing dialogue UI,
clearly labeled PROTOTYPE STATEMENT. Repeating a question returns the same text.
These statements are not evidence or coherent alibis for a generated case.

Session assignments live independently of room nodes. Transitions recreate only
the current room's actors, with small solid feet colliders and normal depth sorting.
Save/load persists the seed and assignments, validating against deterministic
generation before accepting them. Earlier fixed schema-3 saves without NPC fields
receive seed 0; a legacy position colliding with a newly added guest is rejected.
Changing the roster, spawn rules or statement indexing later needs explicit save
migration, since the current prototype validates against those versioned files.

No schedules, furniture poses, autonomous movement or complete dialogue trees are
implemented. A new session currently means relaunch/reset, not an added menu.

## Validation and remaining art constraints

`tools/character_prototype_checks.gd` runs 1,560 assertions, including 64 seeded
layouts, clear reachable positions, seven varied statements, four movement rows,
distance-based phase, idle, real walking to all seven guests, repeat conversations,
room revisits, fresh-session restore, corrupt-save rejection and legacy migration.
It passes headless and with the real Compatibility renderer. Captures compare the
foyer door/chair/table, open floor, library shelving and main bedroom/bed.

The existing fixed-house suite still walks all 44 directed endpoints across 18
spaces. The owned-window MCP smoke checks keyboard movement, revised Eleanor's
questioning, lens collection, library inspection, captures, reset and cleanup.
See `TESTING.md` for the latest suite totals and reports.

At 64 pixels adults read closer to the chairs and beds without stretching artwork.
Some painted rooms still exaggerate tall doors and furniture, and the placeholder
bar/kitchen and cellar dressing retain their existing scale differences. Baked
background furniture has no separate foreground occlusion layer: passing in front
is supported, passing behind tall furnishings is still an environment-art task.
These constraints do not justify regenerating every room for this prototype.

## User-finalized left-walk source delivery

The user supplied finalized L1, L2, L3 and L4 artwork in that explicit playback
order while finishing the right-facing set. Byte-identical sources and SHA-256
hashes are preserved at `assets/characters/detective-walk-final/left/` with a manifest.
No cleanup, cropping, resampling, mirroring, timing adjustment or runtime replacement
was performed on this delivery. The current experimental runtime animation remains
unchanged until an integration task is requested.
# Idle dialogue portrait preview — 2026-10-24

`src/characters/dialogue_portrait.gd` enlarges the current idle texture behind the
dialogue box for the case, ordinary guest statements and Eleanor. It uses source
alpha bounds, feet pivots and shared stature at 3× with a uniform screen-fit cap.
The world actor, pose, artwork and facing are unchanged. Authored west poses use
the right side; other current idle views use the left. Closing a dialogue, changing
rooms or opening a case page hides the portrait. Case conversation panels move
to the bottom; non-conversation case pages retain their larger layout.

Preview: [eight current speakers](../test-results/dialogue-portraits/index.html).
Native capture: `tools/dialogue_portrait_preview.gd`; gallery builder:
`tools/build_dialogue_portrait_review.py`. The first-case checks still pass (31),
and the eight-speaker graphical capture completed. The user approved this presentation for now on 2026-10-24: “They look great for now.”
Exact capture and implementation hashes are saved in `assets/characters/dialogue-portrait-approval.json`.
Automatic turning, activity transitions, new facial art and the countdown remain
future work. This is the user-authorized idle-only first version.

