# Environment asset QA

Validated 2026-10-23. Nine requested environments now have two distinct floor plans
each: 18 separate runtime backgrounds and 18 corresponding selected source masters.
These are original built-in imagegen assets, exported/composed with Godot.

## Inspection and preservation

Read AGENTS, README, original-game analysis, game design, development plan and test
documentation. Inspected foyer scene/scripts, player and Eleanor sprite renderers,
original foyer background, current character review, and all nine supplied room
screenshots. All nine reference files were found in the documented batch-03 directory.
The engine is Godot 4.7.2, Compatibility renderer, 480 x 360 viewport with a 480 x 320
background region at (0,24), 48-pixel investigator and 47-pixel Eleanor.
There was no room-transition implementation: the existing foyer's doors were sealed
inspection targets with fixed hand-authored collision rectangles.

The original foyer PNG, scene, scripts, sprite sheets and project main scene remain
unchanged. References and private photos were not copied into runtime assets.
The rejected foyer-like library style test and bright-window exterior were removed during cleanup; current selected room masters and backgrounds remain unchanged.

## Visual review

The first library generation matched the foyer layout too closely. It was replaced
with a lateral reading room, side doors, L-shaped shelf divider, oval green rug and
right-hand desk. Its native and close engine renders were inspected before the other
layouts were generated. The user's variation feedback expanded scope to two
floor plans per room. The original exterior's warm windows were individually revised
to dark blue-green panes, retaining one restrained entrance lamp.

All 18 native backgrounds were reviewed together on layout A/B contact sheets and
all 36 engine captures on actor comparison sheets at 1x/2x. The upstairs and basement
versions were also inspected separately to verify clearly different stair direction.
The library's burgundy book is a separate transparent prop on the desk, with no
implemented clue behavior. Comparison actors were placed on sampled clear floor
or paths, ahead of foreground railings. These are review placements, not spawn data.

| Criterion | Result |
| --- | --- |
| Separate images | 18 unique backgrounds; no combined image used as a room asset |
| Source dimensions | 1536 x 1024, opaque PNG, 3:2; originals preserved |
| Runtime dimensions | 480 x 320, opaque RGB PNG; nearest export, no aspect stretch |
| Pixel rendering | Consistent nearest-sampled grid, clustered detail, warm outlines; no photographic surfaces observed |
| Palette/materials | Slate/teal manor stone, carved walnut, aged brass, burgundy/green textiles |
| Room identities | Bedroom, lateral firelit entry, grand galleries, stone service chamber, libraries, reception, night grounds, statue halls, stairs |
| Layout variation | Furniture plans and entrance positions vary; no repeated centered-door template across all rooms |
| Lighting | Visible source-based warm pools, cool recesses; dark exterior windows corrected |
| Character visibility | Investigator and Eleanor readable at inspected floor/path samples in both camera views |
| Routes/exits | Side thresholds, bottom openings and upper doors are visible; final collision tracing pending |
| Stairs | A rises to upper landing; B descends into a bounded floor opening |
| Artifacts | No baked characters, visible text, logos, watermarks or UI observed |
| Firelit floor | Decorative runner only; no glowing symbol, portal or teleport system |
| Evidence layer | Separate 24 x 16 RGBA library book; alpha and file paths verified |

Native sampling necessarily reduces fine source detail. These are detailed generated
pixel-art environments, not a claim that every source pixel was hand-authored on a
fixed indexed palette. Window/floor depth uses a consistent elevated stage-like
presentation with some illustrated side-wall foreshortening. Final gameplay
calibration should check chosen character designs and furniture in the connected room.

## Integration and automated evidence

assets/rooms/room-manifest.json registers the 9 rooms, their 18 layouts, source and
runtime files, saved prompts, observed entrance directions, review positions and
future collision requirements. src/environments/environment_review.tscn loads
normal imported Godot textures, uses the existing actor renderers, draws a separate
prop layer, and keeps UI in screen space. It is deliberately an art-review scene.
The project still starts in the playable foyer.

- Asset contract: 9 room IDs, 18 unique layout/asset IDs, safe existing asset paths,
  opaque native images, 3:2 masters, upstairs/downstairs distinction.
- Real headless Godot review checks: 24 passed, covering all 18 texture loads,
  locked comparison actors, selection wrap, room/variant selection, zoom and toggles.
- Full pytest suite: 28 passed, including existing foyer physics/clue/dialogue tests.
- Real Compatibility renderer: 36 separate 480 x 360 screenshots, one overview and
  one 2x view per layout; render processes exited successfully.
- Validator passed source/runtime sizes, alpha behavior, unique hashes, contact-sheet
  dimensions, prop alpha/size and all capture paths.

Evidence: assets/rooms/review/asset-checks.json; test-results/environment-engine-tests.json;
test-results/environments/engine-review.json; test-results/pytest.xml.
Visual evidence: environment-contact-sheet.png, environment-layouts-a.png,
environment-layouts-b.png, engine-actors-1x.png and engine-actors-2x.png in the review
directory. environment-gallery.html links every native image, master, prompt and
individual engine capture.

## Remaining gameplay work

No room collision coordinates, pathfinding, doorway triggers, house connections,
stair traversal or evidence interactions were invented. Existing architecture did not
support connected rooms. Navigation is visually planned, not gameplay-validated.
Baked furniture and foreground rails cannot yet occlude a moving actor correctly;
split relevant foreground art and add y-sorted props before allowing movement.
Do not reuse the old foyer collision rectangles in these new rooms.

Next implement and validate one adjacent playable room: trace its actual geometry,
define two paired doors and safe arrival positions, retain clue state across the
transition, and test walking/occlusion/interactions. Establish the mansion floor plan
before assigning all 18 variants to house locations. The final character cast and
walk-cycle polish remain separate pending work.
