# Mansion environment art guide

Current room-specific user feedback and doorway targets: [ROOM_ART_REWORK.md](ROOM_ART_REWORK.md).
All source backgrounds now have separate cardinal doorway counts in
`assets/rooms/doorway-catalog.json`; those provisional visual labels do not create routes.
Replacement art must pass doorway, furniture and pose clearance review before integration.

## Inspected baseline

Godot 4.7.2 / Compatibility, 480 x 360 logical viewport, initial 960 x 720 window,
integer window scaling and nearest texture filtering. The foyer's original
1536 x 1024 PNG occupies a 480 x 320 region at (0,24); its 3:2 aspect is preserved.
The default gameplay camera zooms 2x; Z shows the whole room. Investigator height
is 48 logical pixels, Eleanor 47, with character origins at their feet.

The existing foyer uses independent Sprite2D background, static rectangle colliders,
y-sorted actors and a separate foreground table. UI is a CanvasLayer. Furniture in
the background cannot automatically occlude an actor. Doors currently display an
inspection response; there is no connected-room manager or transition architecture.

## Shared art direction

Primary references are the original investigator, Eleanor and existing foyer.
The nine reference screenshots are present under the ignored
reference/art-direction/wild-arms/batch-03 directory, numbered in room-roster order.
Their compositions and moods inform original art; no screenshot pixels, characters,
logos, typography or ripped tiles are exported as runtime assets.

Fixed elevated three-quarter orthographic view: show the floor from above, the
back wall and furniture fronts. Horizontal architectural lines stay horizontal;
floor depth edges stay parallel, with no distant vanishing point or diamond layout.
Room view is an open-front stage. No ceiling or tall foreground wall hides actors.
Make back-wall architecture roughly the upper 40-45 percent, leaving readable floor.
Keep the center-to-bottom route open and peripheral furniture well separated.

Use crisp illustrated pixel clusters, warm dark outlines, grouped material highlights
and restrained texture. Render at a consistent 480 x 320 logical grid, with nearest
sampling for the source-to-runtime export and enlarged display. Source PNGs retain
the higher-resolution generated artwork; final runtime files all use the native grid.
Do not interpret the generation source size as proof of a native hand-pixeled grid.
Inspect native and enlarged renders for noisy or disappearing detail.

Architecture is a late-Victorian gothic country manor: slate/teal stone, plaster,
dark walnut, carved pilasters, pointed and rounded arches, leaded windows, brass
candle fixtures and worn burgundy runners. Avoid fantasy fortifications, technology,
modern furniture, glossy 3D materials, photographic lighting and readable writing.
Doors should be around 75-95 logical pixels tall; furniture uses the investigator's
48-pixel height as a comparison. Generous architecture does not imply tiny furniture.
Beds are adult size, chairs have readable seats and backs, stairs show separate treads.

Shared palette anchors: charcoal #101a21, slate #263b42, dark teal #234c50,
muted green #3f5140, walnut #4e382d, burgundy #59323b, aged brass #9d8050,
amber #d5a663. These guide grading rather than enforcing a fixed indexed palette.
Cold exterior/moonlit recesses contrast with local warm flames. Upper-left ambient
light and shadows down/right remain consistent; secondary fire/window pools are
justified by visible sources. Floors stay lighter than the investigator's coat.
Avoid crushed black walkways, broad bloom, blur, unexplained saturated glowing
symbols and indiscriminate texture behind actors. No teleportation symbols/mechanics.

## Layers and integration

Each of nine rooms has TWO distinct layouts, with opaque 3:2 source PNGs and
separate 480 x 320 runtime backgrounds: eighteen usable backgrounds in total.
Side-edge and bottom thresholds vary with each floor plan. Stairwell A ascends
upstairs; B visibly descends into a floor well leading to the basement. The first
library style test was too close to the foyer layout and is superseded/archived.
No baked characters, UI, captions, borders, or floating evidence indicators.
Static fixtures can be baked; future important evidence should use separate props.
The library's conspicuous evidence book is a separate transparent asset, not text
painted into the floor or a claim of an implemented clue.

The manifest registers all nine backgrounds and their provenance. A standalone
Godot art-review scene loads them with the existing investigator at native scale,
supports room selection and 1x/2x inspection, and exports comparable screenshots.
Its comparison positions are visual samples, not collision coordinates or spawns.
It provides no walking, interaction, teleportation or gameplay room transitions.
The playable foyer, clue state, conversations and main scene remain preserved.

Before making any room playable: trace actual floor and furniture from the exported
image, define feet colliders, separate occluding foreground props, choose paired
doors/spawns and validate movement and interaction in the engine. Do not copy foyer
collision rectangles onto a different painting or treat review positions as navigation.

## Production and QA sequence

1. Generate library style test against original sprites and foyer; inspect at native
   scale beside the investigator before creating remaining rooms.
2. Reuse its technically reviewed rendering direction, original sprite and per-room
   screenshot mood reference for the remaining separate generations. Follow the
   explicit floor-plan brief per variant; do not copy the library layout.
3. Retain approved/necessary masters and selected reusable prompts under IMAGE_ASSET_WORKFLOW.md. Export by Godot using nearest sampling only;
   validate full alpha opacity, 3:2 aspect, native dimensions and manifest paths.
4. Inspect all nine separately and on a contact sheet, plus Godot overview and 2x
   actor-placement captures. Revise perspective, scale, readability or style outliers.
5. Present actual candidates and stop for explicit user artwork approval before finalization/integration or another art batch. Record exact file hashes, evidence, scope and retention choices under IMAGE_ASSET_WORKFLOW.md. Record actual results and remaining limitations in ENVIRONMENT_ASSET_QA.md.

Generation uses the built-in imagegen tool. Godot handles technical image sizing,
contact-sheet composition and engine previews; it does not redraw the artwork.
