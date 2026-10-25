# Version 0.1.2 — mansion routes and Char pose checkpoint

Source release, 2026-10-25. Open the project in Godot 4.7.2 to run the prototype.
This release does not include a packaged game executable.

- Integrates the approved opposite-door room artwork and reciprocal routes across
  the compact mansion, with automatic walking transitions and safe arrivals.
- Adds a current-floor connection map and retains the authored Silent Library case.
- Saves Char's directional book, reading, conversation, reaction and observation
  artwork, source hashes and approval/calibration metadata. East, south and west
  looking-down artwork is explicitly approved; north is intentionally omitted.
- Includes the local furniture mask editor and saved seat adjustments.

Validation: fixed mansion 108 checks, first case 31 checks, and opposite-door
direction/trigger checks pass. Exact hashes pass approval preflight for the four
integrated room candidates and three approved looking-down exports.

Runtime pose calibration, general NPC furniture staging and packaged exports remain
unfinished. Source-image loading warnings still require export packaging work.
Preserved source/reference candidates are not all runtime-ready artwork; use the
owning manifest's selected record and approval status, not folder presence.

Next artwork: reaching at table height, followed by low reaching and crouched
inspection. Generate only useful directions and stop for approval after each image.
Complete character pose sets before implementing randomized NPC activity staging.
