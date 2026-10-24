# Mansion blueprint art requirements

Four proposed layouts are the source of truth for required exits. The
existing art is a reference selection, not a claim that these doors already
exist. No backgrounds were redrawn for this blueprint milestone.

## Compact first-playable scope

Each floor has four rooms and two hallways/landings, with stairs integrated into those hallways.
The north foyer door is a locked boundary. There is no exterior playable room or escape link.
Target a short deduction slice first; 10-15 minutes is a playtest goal, not a measured duration.
A clue book for examined objects and collected items is planned separately.

## Shared additions

- Kitchen, dining room, bathroom, utility/store room and wine-cellar art.
- Compact hallway and landing variants with the exact paired doorway positions.
- Three-level main/service stair landings: current ascent and descent images each show only one flight.
- Distinct foyer side exits for each template; preserve the current playable foyer until those are built.
- Separate door/foreground layers and safe arrival positions after the blueprints are approved.

## Per-template port review

### West Hall House

| Room | Floor | Required ports | Best existing reference | Needed |
| --- | --- | --- | --- | --- |
| Foyer (g_foyer) | 0 | east, north, south | original-foyer | east |
| Library (g_library) | 0 | south, west | library-alternate | No cardinal port gap; collision/scale review still required |
| Main hall (g_main_stair) | 0 | down, east, north, south, up | dark-stairwell | east, north; matching stair flight / landing |
| Service passage (g_service_stair) | 0 | down, north, south, up, west | dark-stairwell | north; matching stair flight / landing |
| Dining room (g_dining) | 0 | east, north | — | New room art |
| Kitchen (g_kitchen) | 0 | north, west | — | New room art |
| Master bedroom (u_master) | 1 | south | guest-bedroom | No cardinal port gap; collision/scale review still required |
| Guest bedroom A (u_guest_a) | 1 | south | guest-bedroom | No cardinal port gap; collision/scale review still required |
| Main landing (u_main_stair) | 1 | down, east, north, south | dark-stairwell-basement | east, north, south |
| Service landing (u_service_stair) | 1 | down, north, south, west | dark-stairwell-basement | north, south |
| Bathroom (u_bath) | 1 | north | — | New room art |
| Guest bedroom B (u_guest_b) | 1 | north | guest-bedroom | north |
| Wine cellar (b_wine) | -1 | east, south | — | New room art |
| Records archive (b_archive) | -1 | south, west | library-alternate | No cardinal port gap; collision/scale review still required |
| Main landing (b_main_stair) | -1 | east, north, south, up | dark-stairwell | east, north |
| Service landing (b_service_stair) | -1 | north, south, up, west | dark-stairwell | north |
| Utility room (b_utility) | -1 | east, north | — | New room art |
| Store room (b_stores) | -1 | north, west | — | New room art |

### East Hall House

| Room | Floor | Required ports | Best existing reference | Needed |
| --- | --- | --- | --- | --- |
| Library (g_library) | 0 | east, south | library | south |
| Foyer (g_foyer) | 0 | north, south, west | original-foyer | west |
| Service passage (g_service_stair) | 0 | down, east, north, south, up | dark-stairwell | east, north; matching stair flight / landing |
| Main hall (g_main_stair) | 0 | down, north, south, up, west | dark-stairwell | north; matching stair flight / landing |
| Kitchen (g_kitchen) | 0 | east, north | — | New room art |
| Dining room (g_dining) | 0 | north, west | — | New room art |
| Guest bedroom A (u_guest_a) | 1 | south | guest-bedroom | No cardinal port gap; collision/scale review still required |
| Master bedroom (u_master) | 1 | south | guest-bedroom | No cardinal port gap; collision/scale review still required |
| Service landing (u_service_stair) | 1 | down, east, north, south | dark-stairwell-basement | east, north, south |
| Main landing (u_main_stair) | 1 | down, north, south, west | dark-stairwell-basement | north, south |
| Guest bedroom B (u_guest_b) | 1 | north | guest-bedroom | north |
| Bathroom (u_bath) | 1 | north | — | New room art |
| Records archive (b_archive) | -1 | east, south | library | south |
| Wine cellar (b_wine) | -1 | south, west | — | New room art |
| Service landing (b_service_stair) | -1 | east, north, south, up | dark-stairwell | east, north |
| Main landing (b_main_stair) | -1 | north, south, up, west | dark-stairwell | north |
| Store room (b_stores) | -1 | east, north | — | New room art |
| Utility room (b_utility) | -1 | north, west | — | New room art |

### Central Study House

| Room | Floor | Required ports | Best existing reference | Needed |
| --- | --- | --- | --- | --- |
| Kitchen (g_kitchen) | 0 | east, south | — | New room art |
| Foyer (g_foyer) | 0 | east, north, south, west | original-foyer | east, west |
| Library (g_library) | 0 | south, west | library-alternate | No cardinal port gap; collision/scale review still required |
| Main hall (g_main_stair) | 0 | down, east, north, up | dark-stairwell | east, north; matching stair flight / landing |
| Dining room (g_dining) | 0 | east, north, west | — | New room art |
| Service passage (g_service_stair) | 0 | down, north, up, west | dark-stairwell | north; matching stair flight / landing |
| Master bedroom (u_master) | 1 | south | guest-bedroom | No cardinal port gap; collision/scale review still required |
| Guest bedroom A (u_guest_a) | 1 | south | guest-bedroom | No cardinal port gap; collision/scale review still required |
| Bathroom (u_bath) | 1 | south | — | New room art |
| Main landing (u_main_stair) | 1 | down, east, north | dark-stairwell-basement | east, north |
| Study (u_study) | 1 | east, north, west | library | north |
| Service landing (u_service_stair) | 1 | down, north, west | dark-stairwell-basement | north |
| Wine cellar (b_wine) | -1 | east, south | — | New room art |
| Utility room (b_utility) | -1 | east, south, west | — | New room art |
| Store room (b_stores) | -1 | south, west | — | New room art |
| Main landing (b_main_stair) | -1 | east, north, up | dark-stairwell | east, north |
| Records archive (b_archive) | -1 | east, north, west | library | north |
| Service landing (b_service_stair) | -1 | north, up, west | dark-stairwell | north |

### North Landing House

| Room | Floor | Required ports | Best existing reference | Needed |
| --- | --- | --- | --- | --- |
| Main hall (g_main_stair) | 0 | down, east, south, up | dark-stairwell | east; matching stair flight / landing |
| Foyer (g_foyer) | 0 | east, north, south, west | original-foyer | east, west |
| Service passage (g_service_stair) | 0 | down, south, up, west | dark-stairwell | No cardinal port gap; collision/scale review still required; matching stair flight / landing |
| Library (g_library) | 0 | east, north | library | north |
| Dining room (g_dining) | 0 | east, north, west | — | New room art |
| Kitchen (g_kitchen) | 0 | north, west | — | New room art |
| Main landing (u_main_stair) | 1 | down, east, south | dark-stairwell-basement | east, south |
| Study (u_study) | 1 | east, south, west | library | south |
| Service landing (u_service_stair) | 1 | down, south, west | dark-stairwell-basement | south |
| Master bedroom (u_master) | 1 | north | guest-bedroom | north |
| Bathroom (u_bath) | 1 | north | — | New room art |
| Guest bedroom A (u_guest_a) | 1 | north | guest-bedroom | north |
| Main landing (b_main_stair) | -1 | east, south, up | dark-stairwell | east |
| Records archive (b_archive) | -1 | east, south, west | library | south |
| Service landing (b_service_stair) | -1 | south, up, west | dark-stairwell | No cardinal port gap; collision/scale review still required |
| Wine cellar (b_wine) | -1 | east, north | — | New room art |
| Utility room (b_utility) | -1 | east, north, west | — | New room art |
| Store room (b_stores) | -1 | north, west | — | New room art |
