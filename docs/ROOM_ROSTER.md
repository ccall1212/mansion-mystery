# Mansion room roster

Current room-specific user feedback and doorway targets: [ROOM_ART_REWORK.md](ROOM_ART_REWORK.md).
All source backgrounds now have separate cardinal doorway counts in
`assets/rooms/doorway-catalog.json`; those provisional visual labels do not create routes.
Replacement art must pass doorway, furniture and pose clearance review before integration.

Nine environments, each with two distinct layouts (18 separate backgrounds).
All runtime backgrounds are opaque 480 x 320 PNGs, matching the preserved
foyer region. Higher-resolution 3:2 masters are in assets/rooms/masters.
Entrance directions describe observed artwork, not implemented door triggers.

| Room | Purpose | Layout A | Layout B | Required before playable |
| --- | --- | --- | --- | --- |
| 01 Guest Room | Private bedroom; bed, dresser, hearth and intimate furnishings. | [room-guest-bedroom.png](../assets/rooms/room-guest-bedroom.png) — east, south | [room-guest-bedroom-alternate.png](../assets/rooms/room-guest-bedroom-alternate.png) — east, south-east | Bed base, dresser, fireplace hearth and chair; doorway and approach must be traced after art review. |
| 02 Firelit Entry | Column-framed passage, warm fires and a guiding runner. | [room-firelit-entry.png](../assets/rooms/room-firelit-entry.png) — west, east, south-west | [room-firelit-entry-alternate.png](../assets/rooms/room-firelit-entry-alternate.png) — north-west, east, south | Column plinths, hearths and rear doorway threshold; paired destination remains undefined. |
| 03 Grand Hall | Tall windows, chandelier, statues and a broad central axis. | [room-grand-hall.png](../assets/rooms/room-grand-hall.png) — north, west, east, south | [room-grand-hall-alternate.png](../assets/rooms/room-grand-hall-alternate.png) — west, east, south-west | Statue plinths and side furniture; door/spawn and chandelier occlusion require design. |
| 04 Torchlit Stone Chamber | Cool masonry, arches and small localized fire pools. | [room-torchlit-stone.png](../assets/rooms/room-torchlit-stone.png) — west, north-east | [room-torchlit-stone-alternate.png](../assets/rooms/room-torchlit-stone-alternate.png) — east, south-west | Trace piers, side recesses and upper threshold; central floor must remain clear. |
| 05 Library | Bookshelves, ladder, reading furniture and a separate evidence book. | [room-library.png](../assets/rooms/room-library.png) — west, east | [room-library-alternate.png](../assets/rooms/room-library-alternate.png) — north-east, west, south | Trace desk, chair, ladder and bookcases; split desk foreground for actor occlusion. |
| 06 Reception Hall | Formal counter, runner and broad conversation floor. | [room-reception-hall.png](../assets/rooms/room-reception-hall.png) — east, south | [room-reception-hall-alternate.png](../assets/rooms/room-reception-hall-alternate.png) — west, east, south-east | Counter, wall seating and side table; reserve central standing space. |
| 07 Night Exterior | Cool foliage, dark mansion facade and a narrow approach. | [room-night-exterior.png](../assets/rooms/room-night-exterior.png) — north-east-front-door, south-west-path, east-garden | [room-night-exterior-alternate.png](../assets/rooms/room-night-exterior-alternate.png) — north-west-service-door, east-path, south-east-path | Trace path edges, vegetation, stair treads and door threshold; no exterior connection implemented. |
| 08 Cold Statue Hall | Teal/charcoal stone, paired statues and restrained cold light. | [room-cold-statue-hall.png](../assets/rooms/room-cold-statue-hall.png) — west, east, south | [room-cold-statue-hall-alternate.png](../assets/rooms/room-cold-statue-hall-alternate.png) — west, east, south | Statue bases, wall piers and doorway threshold; no magic/monster mechanics. |
| 09 Dark Stairwell | Readable treads, turning stairs and a dim upper route. | [room-dark-stairwell.png](../assets/rooms/room-dark-stairwell.png) — south, west, upstairs | [room-dark-stairwell-basement.png](../assets/rooms/room-dark-stairwell-basement.png) — west, south-west, basement-down | Separate landings from stair treads; choose ascent logic and paired exits before movement. |

## Integration boundary

Open src/environments/environment_review.tscn for engine art review.
1-9 select a room, V switches its layout, arrows browse all layouts, Z toggles
1x/2x, A toggles comparison actors and P toggles separate props.
The library evidence book is a separate visual prop, not an implemented clue.
The main playable foyer and its original files are preserved. New background
assets are registered for loading; no gameplay transitions or collision data
are invented. Trace geometry, split occluding props, and validate one connected
room before expanding the playable house.
