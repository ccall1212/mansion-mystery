# Mansion blueprints and floor memory

The default playable game now uses the separate [fixed walking layout](FIXED_MANSION.md).
The four plans documented here remain schematic review alternatives; their grid
geometry is not the same as the provisional fixed-house passage network.

Four compact layouts are in assets/mansion/blueprints.json. Each has exactly
four functional rooms plus two hallways/landings per floor: six spaces per floor,
18 total across ground, upper and basement. The two stair shafts are integrated
into the hallways, not counted as extra rooms. This supersedes the oversized
32-36-space drafts. All four remain available for seeded selection.

These are schematic review plans, not measured construction drawings or decoded
DOS maps. The room positions, paired doors and stair shafts come from one shared
data source. The review gallery and all-floor diagrams are in assets/mansion/review.

| Version | Arrangement |
| --- | --- |
| manor-1 / West Hall House | North-west foyer; two adjacent central halls; living rooms above/below |
| manor-2 / East Hall House | North-east foyer; mirrored public/service circulation |
| manor-3 / Central Study House | North-center foyer; dining room and upstairs study connect the stair wings |
| manor-4 / North Landing House | North-center foyer between the two stair landings; rooms sit to the south |

## Locked front door and floors

The top of the plan is north and the front of the house. The existing foyer painting
already puts its main door at the top; the plan is corrected to match it rather than
rotating that artwork. The front door is a locked boundary with no destination,
no traversable graph edge and no playable grounds room. North is the foyer's initial
arrival port, recording that the player entered before the doors were locked.
In the playable foyer, examining those doors explicitly says no one is leaving.
R resets the existing safe starting position; it is not a new front-door spawn.

Every version has basement (-1), ground (0) and upper (1). Main and service stairs
connect all three floors at aligned grid positions. All rooms remain reachable
if either complete stair shaft is removed. The alternate route is another stair
shaft, not a requirement to subdivide each floor into many corridor rooms.
Doors pair north/south or east/west across neighboring cells; open hallway links
are archways. Stair links pair up/down on consecutive floors. Reversing a link
returns to its exact endpoint and arrival port.

## Small-first playtest scope

The first connected playable target is the four ground-floor rooms: foyer,
library, dining room and kitchen, with the two connecting hallway/stair spaces.
The current physical prototype remains the foyer; the compact plan is not a claim
that those other rooms can already be walked through. Fit art/doors and implement
that slice before opening the whole upper floor/basement or expanding room count.

A 10-15-minute case is a playtest target, not measured playtime. Judge the first
slice by whether inspecting, collecting, questioning and making a deduction feels
complete. Add rooms only when they support new evidence or useful suspect routes,
not simply to lengthen walking. The user's 2-5-minute description of the original
is design context rather than a timing measurement made by this project.

A clue book is planned to distinguish examined objects, collected items, clues and
suspect statements. Exact entries and deduction behavior should follow the first
small case. This change does not implement a notebook or a full mystery save.
The locked-house, closed-circle tone is inspired by the user's Knives Out reference;
its plot, dialogue and characters are not copied.

## Runtime session

MansionWorld is a small Godot autoload. A fresh launch starts a new seeded session.
The template is selected from the four versions using the seed; references to the
existing room-art variants are selected once and remain fixed on revisits.
Random selection can repeat a version. Supply --mansion-seed=1234 to reproduce a
particular new game. Review hotkeys can force a template for comparison.

The session stores:

- schema version 2, seed and template ID;
- stable per-room asset selections, including empty selections for missing art;
- current room and floor derived from that room, plus the exact arrival port;
- visited rooms, discovered links and the last 64 traversals;
- a per-room memory dictionary reserved for position/clue/interaction state.

Older oversized-plan saves use schema version 1 and are rejected safely.
S/L in the blueprint review saves/loads user://mansion-blueprint-session.json using
a temporary file and rename. Restoring validates template, seed, asset selections,
room/floor consistency, ports, link IDs, history and room-memory ownership before
replacing the live state. Damaged data is rejected without partial mutation.
JSON numbers in generic room memory follow JSON numeric semantics.

This is blueprint/session persistence, not a complete mystery-game save. The current
foyer's clock/conversation and actual player movement are not yet migrated to this
session. R in the playable foyer still resets the entrance position; it does not
select a new mansion. The development status hook additionally reports selected
mansion seed, template, logical room and floor.

## Review controls

Open src/mansion/blueprint_review.tscn in Godot and press F6.
1-4 selects a version; F1/F2/F3 or the floor buttons show basement/ground/upper.
Click a room to inspect its assigned reference and required art changes.
Enter rehearses the shortest logical route to that room. The current-room label,
floor, visited markers and arrival port update together. Exit buttons traverse one
paired link. R creates a new seeded session; S/L saves/loads the review session.

The review uses a larger 1120 x 700 window only for readable plans; the playable
game retains its 480 x 360 viewport and original main scene.

## Art follows the blueprints

MANSION_ASSET_REQUIREMENTS.md lists required ports per room and the nearest existing
art reference. Missing cardinal directions and incompatible stair flights remain
explicit. Stair direction is prioritized when selecting an existing reference.
Kitchen, dining, bathroom, utility/store-room and wine-cellar art are missing.
The three-level stair landing also requires new combined up/down views.

Existing room paintings remain unchanged for this milestone. Reference selection
does not mean a painting fits the blueprint or is safe for movement. Once the
blueprints are reviewed: adjust doors/room proportions, split foreground layers,
trace collisions, define exact arrival pixels, and integrate a paired room/stair
transition using the tested stable endpoint IDs. Choose one version as the first
playable test while keeping all four as generation templates.

## Validation

Python topology checks validate all four plans: unique rooms/ports/links, no cell
overlap, cardinal adjacency, opposite endpoint ports, aligned stair shafts,
consecutive floor changes, complete reachability and either-shaft redundancy.
The real Godot session tests exercise deterministic selection, stair reversal,
floor memory, stable art on returning, JSON round trips, preserved room memory and
rejection of corrupted or unrelated exits. Current report:
test-results/mansion-engine-tests.json (see the current report for the check count, including real file
save/load, replacement of an existing save, bad arrival-port rejection and review
floor browsing without changing the current logical floor).

The real-window foyer smoke also passed after the autoload integration: startup
reported a selected template/seed, movement kept it stable, the clock and Eleanor
interactions worked, and a fresh process selected a new seeded session. This does
not establish physical transitions into the new room backgrounds.

Twelve real engine screenshots cover each template/floor; four all-floor diagrams
and one combined overview are generated from the same blueprint data.
Run pytest for the full suite; tools/build_mansion_blueprints.py regenerates the
data and art-gap report. tools/mansion_blueprint_contact.tscn renders overview
diagrams, and --blueprint-capture on the review scene creates the floor captures.
The offline gallery/checks are assembled by tools/build_blueprint_gallery.py.
