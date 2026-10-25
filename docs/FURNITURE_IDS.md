# Furniture IDs and background mapping

Shared chair/stool sizing targets: [Furniture size standard](FURNITURE_SIZE_STANDARD.md).
`assets/furniture/size-standards.json` defines seat dimensions relative to the current
shared adult stature. Catalog `size_profile_id` is independent of orientation;
existing painted furniture still needs measurement and pose-fit review.

The orientation catalog and background mapper are implemented. They label painted
furniture and record reusable interaction contacts. They do not redraw furniture,
generate character poses or automatically seat NPCs.

## Open the mapper

From the project folder:

```powershell
python tools/open_furniture_mapper.py
```

The launcher reuses the configured Godot installation. Alternatively, open
`src/furniture/furniture_editor.tscn` in Godot and run that scene. The main game
remains `src/mansion/playable_mansion.tscn`.

## Add labels to a new background

1. Copy the new PNG, JPEG or WebP into the project's `assets/` folder.
2. Click **Open background** and select the image. Existing annotations reopen
   automatically; an unregistered image starts with an empty layout.
3. Choose a furniture type and orientation in the right-hand dropdowns.
4. Click **Draw furniture**, then drag a rectangle around the visible object.
   This rectangle describes the painted object, not a character or a new sprite.
5. Select the object. Its instance ID can be renamed. Drag to move the annotation;
   drag its lower-right square to resize it. **Undo** restores the previous edit.
6. Choose an interaction point. Use **Mark contact** and click the actual seat,
   mattress/body contact, feet or knees location. Use **Mark approach** to mark a
   reachable floor location from which someone can approach it. Confirm **Actor
   faces** separately from the furniture orientation.
7. Uncheck **Use this interaction point** for blocked or inapplicable positions.
   For a bar stool, put the associated counter's instance ID in **Target ID**.
8. Click **Save** or press Ctrl+S. The layout is saved and registered to that image.
   A title-bar asterisk marks unsaved edits; closing offers save/discard choices.
   **Pose list** opens a selectable, copyable list of pose requirements, grouped
   by furniture and contact. No additional art is generated.

The tool initially opens the foyer. All **18 playable rooms / 14 unique backgrounds**
now have annotations: **118 unique object tags / 149 room-scoped instances**.
Their contacts remain drafts, with **Contact points reviewed for staging** unchecked.
Wall-side bed contacts, the exterior front-door contact and inaccessible shelves
behind the kitchen counter are disabled. Calibrate contacts against the eventual
pose landmarks and actual navigation before enabling NPC placement.
See [all room screenshots](TAGGED_ROOM_SCREENSHOTS.md) and
[Char's first pose plan](CHAR_POSE_PLAN.md).

**Apply preset / reset anchors** changes an existing object's orientation while
keeping its rectangle. It replaces its contact calibration with that preset's
defaults; Undo can restore the previous calibration. Moving preserves local
contacts, while resizing scales their offsets with the rectangle. Geometry edits
clear the staging-review flag.

## Orientation IDs

There are **84 IDs across 21 types** in `assets/furniture/catalog.json`.
For the following types, append `_north`, `_east`, `_south` or `_west`:

| Type prefix | Meaning | Example |
| --- | --- | --- |
| `chair` | Ordinary chair | `chair_west` |
| `armchair` | Upholstered chair | `armchair_south` |
| `sofa` | Sofa, with two separate seat contacts | `sofa_east` |
| `bar_stool` | Stool facing a counter | `bar_stool_north` |
| `desk` | Desk's usable front | `desk_south` |
| `bookshelf` | Shelves' usable front | `bookshelf_south` |
| `table` | Table or reading stand's designated interaction front | `table_east` |
| `bar_counter` | Counter's designated front | `bar_counter_south` |
| `fireplace` | Hearth's usable front | `fireplace_south` |
| `window` | Window's usable front | `window_south` |
| `doorway` | Opening's designated front | `doorway_south` |
| `bench` | Bench with one draft seat | `bench_south` |
| `cabinet` | Cupboard or storage shelving | `cabinet_south` |
| `statue` | Statue viewing side | `statue_south` |
| `crate` | Crate inspection side | `crate_west` |
| `barrel` | Barrel inspection side | `barrel_south` |
| `mirror` | Mirror's usable front | `mirror_east` |
| `painting` | Picture's viewing side | `painting_south` |
| `stairway` | Stair entry side; travel uses portals | `stairway_north` |
| `clock` | Clock's viewing side | `clock_south` |

Beds use four explicit axis/headboard combinations:

- `bed_east_west_head_west`
- `bed_east_west_head_east`
- `bed_north_south_head_north`
- `bed_north_south_head_south`

North means screen up, east right, south down and west left. Orientation labels
never rotate or mirror the painted artwork. Front/side/rear depiction remains a
separate catalog field. These IDs describe the art that is actually present; they
are not a promise that every background contains every orientation.

## Keep these identifiers separate

| Identifier or field | Example | Purpose |
| --- | --- | --- |
| Orientation ID | `armchair_west` | Reusable type/orientation definition |
| Background instance ID | `foyer_armchair_01` | This particular painted armchair |
| Contact ID | `seat` | One usable position on that armchair |
| Actor facing | `west` | Direction the seated character faces |
| Pose requirement ID | `seated_read_west` | Required posture, activity and direction |
| Runtime room key | `g_foyer::foyer_armchair_01` | Scopes the instance to a room when backgrounds are reused |

A south-facing desk can have a seated worker behind it facing south and a standing
visitor in front facing north. The example library desk records exactly that.
For lying poses, use body axis and head direction instead of pretending that a
standing-facing label describes a body on a bed.

Pose requirement examples include `seated_idle_west`, `seated_talk_west`,
`standing_read_north`, `kneeling_inspect_north` and
`lying_idle_north_south_head_north`. These are requirements for future artwork,
not claims that those character poses already exist. Disabled contacts yield no
pose requirements. Character-to-contact assignment comes later.

## Storage and coordinate contract

- `assets/furniture/catalog.json`: orientation IDs and provisional contact templates.
- `assets/furniture/backgrounds.json`: background resource path → layout resource path.
- `assets/furniture/layouts/<layout_id>.json`: instances, rectangles, origins,
  footprints, local contact/approach offsets, actor-facing or lying alignment,
  activities, disabled contacts and manual staging-review flags.
- `src/furniture/furniture_library.gd`: shared loading, validation, ID generation,
  pose requirement naming, save and coordinate resolution.

New backgrounds default to a **480-unit width**, with height derived from the image
aspect ratio. This coordinate space is local to the image's upper-left corner;
it does not include the game's 24-pixel header. Higher source-image resolution
does not require manually multiplying every annotation. An existing layout may
use another positive coordinate size with the same image proportions.

Instances use a bottom-centre origin for their marked rectangle. `bounds`,
`footprint`, `contact` and `approach` are local offsets from that origin.
The rectangle is the entire visible object; the footprint is an initial occupancy
hint and is not automatically installed as game collision.

Contact kinds are `feet`, `seat`, `knees` and `pelvis`. A seat contact is **not**
the character's feet origin: future placement must subtract the matching pose's
seat landmark. Lying poses need their pelvis/body axis and head direction aligned.
This prevents the labels from implicitly introducing floating or misaligned actors.

The resolver accepts the actual destination background rectangle and uses uniform
scale with centred letterboxing. The fixed mansion currently resolves to
`Rect2(0,24,480,320)`, matching its existing 3:2 backgrounds. When adding an image
with another aspect ratio to gameplay, render that image using the resolver's
`background_rect` too; the older room renderer stretches images to fill 480 × 320.
The mapper already displays arbitrary aspect ratios without stretching.

Saving registers by background path, so any current or future room using that
image can find the same annotations. A room may set `furniture_layout` to a specific
layout resource path when the same background needs a different annotation set.
Changing a layout ID creates a new sidecar; older files remain available for that
explicit override. A layout ID belonging to a different image cannot be overwritten.

Catalog templates can be rebuilt with `python tools/build_furniture_catalog.py`.
That command changes only the catalog; it never overwrites hand-edited layouts.
New types/presets require catalog entries, not separate character implementations.

## Game integration and limits

`FixedSession.furniture_for_room(room_id)` returns resolved instance IDs, visual
bounds, footprint hints and contact/approach positions. F6 toggles an in-game label
overlay; `--furniture-debug` enables it on launch. Missing annotations return an
empty result, so new rooms continue to work before they are tagged. Restart a
running game after saving external mapper changes to refresh its registry.

Saving checks IDs, duplicates, orientations, finite geometry, image bounds,
lying alignment and counter references. A staging-reviewed bar stool requires a
valid counter target. Reviewed enabled contacts must remain inside the image.
Layout writes and registry writes use temporary files and atomic replacement.
If registry writing fails after a layout save, the tool reports that partial
result and asks for another save; it does not silently claim registration succeeded.

The review checkbox records manual calibration. It does not verify walkable
approaches, character-pose availability or occupancy reservations. Automatic pose
selection, chair/bed placement, schedules, collision generation and foreground
occlusion remain future work. Tagging a doorway does not create a transition or
unlock the front door. Existing NPC placement and gameplay are preserved.

## Validation

`python -m pytest tests/test_furniture.py -q` verifies catalog regeneration and runs
221 engine checks. These cover orientation vocabulary, bed alignment, local/world
transforms, aspect ratio, rejected corrupt/duplicate data, isolated save/reload,
actual mouse-driven drawing/moving/resizing, contact calibration, undo, deletion,
background registration and the game overlay. The same harness runs with the
Compatibility renderer using `--capture`, producing mapper screenshots under
`test-results/furniture/`. Tests save temporary layouts in `user://`, preserving
the project's background registry.

The owned-window check `python tools/dos-game-mcp/smoke_furniture.py` also confirms
the four foyer IDs and F6 overlay via the documented MCP workflow, captures the
viewport, checks diagnostics and stops its owned game process.

## Full room coverage and review reproduction

The master-bedroom vanity and chair share optional `occupancy_group` metadata
(`master_vanity`), recording one physical seat. Future staging must enforce this;
automatic occupancy is not implemented. Portable evidence props keep their own
IDs. Furniture tags do not duplicate or replace the evidence system.

`python tools/tag_mansion_furniture.py` previews missing authored tags; `--apply`
appends tags and registers missing backgrounds, preserving existing IDs and
calibrated instances. For arbitrary new backgrounds, use the visual mapper.

Run configured graphical Godot with `--path . --script tools/capture_tagged_rooms.gd -- --npc-seed=20261023`,
then `python tools/build_furniture_review.py`. The native Compatibility renderer
captures all 18 actual rooms, three floor sheets, a clearance audit and Char's
source-linked pose requirements. A headless rendering driver cannot capture art.
These tools do not generate character or background artwork.

## Side viewing contacts and gaze targets

Windows, paintings and clocks now have reusable `view_from_west` / `view_from_east`
contacts for north/south-facing furniture (or north/south-side contacts for east/west
furniture). The side describes actor location; facing is independently opposite that
side. A north-wall `window_south` retains its ID while its west-side actor faces east
and its east-side actor faces west. Each supports inspect and look_up. Its original
look_out contact also supports look_up. Do not rotate the window or change its
orientation ID to represent a person moving around it.

Optional `gaze_target` is an instance-local point, transformed/scaled together with
contact/approach during creation, resizing and world resolution. `interaction_side`
uses canonical directions. The validator rejects nonfinite gaze points or invalid
sides. `look_up` distinguishes gaze/action from actor facing. These fields describe
requirements, not an implemented eye/head controller or an existing Char look-up sprite.

`python tools/add_furniture_side_views.py` additively upgrades existing backgrounds,
preserving calibrated front anchors and skipping existing side IDs. It added 38
provisional contacts across 19 unique windows/pictures/clocks in this mansion.
New backgrounds receive the templates from the current catalog via the mapper.
All side placements require visual review and navigation/pose/occlusion calibration;
no staging flags were approved. Outside-image contacts are disabled by the upgrader.

Latest coverage: 247 room-scoped contacts, 201 enabled, 46 disabled; 133 locally clear
approaches and 68 blocked, across the same 18 rooms / 14 backgrounds. This is 47
concrete pose requirements including common conversation coverage, not 47 approved
Char drawings. The two new look-up E/W requirements are planned artwork.

Open [the tagged-room gallery](../assets/furniture/review/all-rooms/index.html).
Screenshots show pale facing arrows and purple gaze lines. Each room also has an
expandable exact-ID contact table with facing, side, pose IDs and approach status.
The gallery must be shown to the user whenever it changes; technical checks do not
substitute for visual review.

## Approved revised room backgrounds — 2026-10-24
Nine selected room revisions now have 126 fresh object tags in layouts/*_rework_v*.json, registered by exact background path. Original layouts remain unchanged. The catalog has 88 orientation IDs including stool_north/east/south/west for low work stools, distinct from bar_stool. Tall bar stools target future_bar_bar_counter; table chairs identify their table. Desk seated contacts are disabled where a separate chair tag supplies the seat. All new staging flags remain false. See [tagged screenshots and contacts](../test-results/reworked-furniture/index.html). Source art approval does not certify these manually estimated contact points. The bar remains a future room concept; active routes and masks are unchanged.

Regenerate using python tools/tag_reworked_rooms.py --apply (preserves existing layout calibration), configured Godot --path . --script tools/reworked_furniture_preview.gd, then python tools/build_reworked_furniture_review.py. Exact per-contact Char coverage is assets/furniture/reworked-room-pose-contacts.json. North-facing seated art and tall-stool-specific pose fit are gaps. The canopy bed retains east-west body axis/head-east metadata, but all contacts are disabled pending mattress/pelvis calibration.
