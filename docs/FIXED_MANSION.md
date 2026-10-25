# Compact playable mansion

The default `src/mansion/playable_mansion.tscn` now uses seven functional rooms
and two circulation screens, with a different existing background for each.

| Floor | Main rooms | Circulation |
| --- | --- | --- |
| Ground | Foyer, Library, Dining Room, Kitchen | Main Stair Hall |
| Upstairs | Main Bedroom, Study | Upstairs Landing |
| Basement | Basement Storage | None |

Routes: Foyer ↔ Main Stair Hall ↔ Library ↔ Dining Room ↔ Kitchen ↔ Basement Storage.
Main Stair Hall ↔ Upstairs Landing, which connects separately to Bedroom and Study.
All eight connections have reciprocal endpoints. Removed duplicate basement rooms,
extra bedroom/washroom and service routes are deferred, with their art and furniture
tags preserved. The north/front foyer door remains locked.

## Review and remaining mismatches

[Open all nine current room screenshots and exact connections](../test-results/compact-mansion/index.html).
The foyer/stair-hall connection still bends between two south-facing thresholds.
The kitchen south exit leads through an offscreen basement stair flight to the
storage room's rear doorway. These need matching doorway/stair artwork before we
claim a physically faithful floor plan. The dining room still uses salon furnishings
and the kitchen uses a bar/counter background. No source artwork was modified.
Unused painted openings have no route marker and are not active exits.

## Play and persistence

WASD/arrows move; E enters a marked threshold or interacts. TAB shows the current
floor, visited rooms and immediate connections. N opens notes, Z changes view and
F11 changes fullscreen. F4 begins/reviews the [first case](FIRST_PLAYABLE_CASE.md).
Its ground-floor evidence and three suspects are retained. Char's separate F7/F8
pose test still uses her three existing kitchen/library/foyer contacts.

The new layout ID is `fixed-manor-compact-1`. Old 18-space saves remain on disk but
are rejected by this layout rather than silently moved into a different house.
Start a new case; F5 explicitly saves and F9 loads a compatible compact session.
Objects formerly placed in removed rooms are relocated to retained rooms.

`tools/build_fixed_mansion.py` authors the compact JSON. Definitions for deferred
rooms remain authoring options, not runtime destinations. `fixed_session.gd`
validates traversal, positions and snapshots. All active backgrounds retain their
existing furniture lookup. The older blueprint/art/tag galleries remain expansion
references, not the current playable room list.

## Verification

The focused physics traversal visits all nine active spaces and walks all sixteen
directed endpoints, checks reverse arrivals, evidence, upstairs travel and save/load.
Char's lifecycle checks now cover 63 room/pose visits. The first-case checks verify
that its evidence/accusation loop survives the reduction. Native Compatibility
captures come from `tools/capture_compact_mansion.gd`; the review builder is
`tools/build_compact_mansion_review.py`. Visual art approval is still separate.

A future small map near the top of the screen should highlight the current room,
show the current floor and main-room count, using the same active room graph.
It is documented in GAME_DESIGN_BRAINSTORM.md and has not been implemented yet.

## Approved room integration — 2026-10-24
The main game now uses eight approved room revisions plus the unchanged foyer (nine spaces, seven functional rooms). Future bar remains outside the active mansion. tools/reworked_mansion_geometry.py supplies new feet-level walk regions/obstacles and eight reciprocal connections. Main staircase rises straight to its north door and upstairs arrival is from the south facing up. Library uses east/south doors; its south door reaches the dining east door via an explicit turning passage. The foyer south-to-stair-hall south vestibule and kitchen-to-basement stair also remain offscreen connections. These are not a geometrically measured seamless floor plan.

Layout identity is fixed-manor-compact-2: old saves remain on disk but are rejected because their positions/geometry may be invalid. Library floor clue moved to [202,279]; the bust moved to [292,220]. Case story and solution are unchanged. Main Char fit selection resolves approved revised-library contacts; general procedural furniture staging and other room pose masks remain pending. Nine native overview screenshots are in test-results/compact-mansion/index.html.


Door destination labels: every active portal now displays its target room name continuously, including Up/Down for stairs, with a dark backing and edge-clamped text. The foyer north door explicitly says Front door / Locked. Labels are shared rendering; no per-room label art is baked into backgrounds.
