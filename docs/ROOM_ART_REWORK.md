# Room art review and doorway contract

User feedback recorded 2026-10-23. This is the current rework brief. Existing
backgrounds remain placeholders until replacement art and placement are reviewed.
The seven-room scope is retained; a bar and bathroom are future expansion options.

| Room | Review | Required change | Target usable openings |
| --- | --- | --- | --- |
| `g_foyer` | Connection gap still open | Resolve the bent south vestibule when revising the entrance layout. Keep the north/front door locked. | N locked front door; S internal passage |
| `g_main_stair` | Revised request 2026-10-24 | One straight flight directly to a visible north door; no twist, return or wrapping balcony. Keep west library doorway and south foyer threshold. | N upstairs door at top of flight; W library; S foyer |
| `g_library` | Rework | Remove the case/ladder in front of the window. Separate chair, side table and shelving with accessible pose space. No ambiguous stool/chair cluster. | W and E only |
| `g_dining` | Rework | Real adult-sized dining table and usable chairs. Remove the unused lower exit; maintain walkable routes around furniture. | W and E only |
| `g_kitchen` | Rework | Create an actual kitchen: range/hearth, prep surface, sink/basin and food storage. Preserve the current bar-like art as a future bar reference. A future bar needs distinct stools facing the counter and their own seat anchors. | E dining; S basement stairs |
| `u_main_stair` | Rework | Upstairs arrival must be from the bottom/south, facing north so continued Up movement enters the floor. Connect carpet runners from that entrance to both side doors. Remove the unused north doorway. | S stair return; W bedroom; E study |
| `u_master` | Rework | Remove unused left opening, reduce purposeless lower empty space, and provide coherent adult bedroom furniture. A connecting bathroom is an alternative future expansion, not an added room now. | E landing only |
| `u_study` | Rework | Remove both unused openings; furniture and architecture must read as one study. | W landing only |
| `b_store` | Rework | Remove unused west doorway. Add believable shelves, crates, trunks and barrels; preserve open access aisles and inspection positions. Do not fill every walking tile. | N return via basement stairs only |

## Machine-readable labels

`assets/rooms/doorway-catalog.json` owns **observed painted openings**, their
canonical screen directions and the per-side counts for every existing background,
including inactive variants. `doors` include usable door-shaped openings, locked
doors and open thresholds; stair flights and exterior paths are counted separately.
An arch containing shelves/fireplace/window is not a door. Multiple leaves of one
double door count as one opening. Directions describe the wall/edge containing the
opening; a north door can be on the right half of the north wall. No stored diagonal
direction: use north/east/south/west plus a position hint.

Each entry retains the historical visual-review label and whether a count needs
closer inspection. Observed tags do not create runtime portals. The active review
also displays required replacement openings and the current portal sides separately.
This exposes extras rather than quietly counting only working exits.

Before pairing rooms, require reciprocal endpoint directions where physically
appropriate, compatible widths, clear approaches, stable return endpoints and
matching floor change. An offscreen turning passage needs an explicit note; simple
direction counts alone are not proof that two rooms fit. Stairs record ascent/descent
separately from screen side. Windows are tagged as windows, not route openings.

## Production and approval

### Current generated batch — 2026-10-24

[Review all nine new drafts](../assets/rooms/revisions/2026-10-24-room-rework/index.html).
The user authorized recreation using the room-specific feedback and a new straight
main staircase ending at a door. Eight active-room candidates and a separate future
bar concept were created through the built-in image-generation workflow, one image
per request. All are 1536×1024 opaque masters. Exact prompts, reference/output hashes,
door-side requirements and provisional marker locations are in the sibling
`manifest.json`. The library candidate in this batch leaves the window approach
clear and moves the reading chair away from it; the earlier v2 remains a prior draft.

**All candidates await user approval.** No runtime background, collision, furniture
layout, chair mask or room graph was changed. The bar is not a new playable room.
The kitchen candidate contains a small work stool despite its exclusion in the
prompt; the gallery flags it for a keep/remove decision. The doorway catalog stores
these entries as inactive candidates. Review labels are HTML/SVG overlays rather
than baked image pixels. Do not infer staging approval from attractive empty floor.

The straight stair's new axis and all revised furniture require fresh calibration
after art approval. Preserve the south/bottom upstairs arrival facing north when
integrating the landing. No extra upstairs bathroom or active bar was added.

Every replacement brief fixes door count/sides before generation. No extra arches,
fake exits, blocked windows, fused furniture or redundant clutter. Keep deliberate
pixel clusters, consistent projection, readable furniture silhouettes and adult
scale. The open foreground of a cutaway room is not automatically an exit.

Review the clean art and a separately labeled overlay. Do not bake IDs, compass
labels or doorway counts into runtime pixels. Confirm the look, then author new
colliders, furniture instances, approach/contact points and occlusion masks. Old
furniture IDs describe old geometry; preserve identity only where the same furniture
exists, and recalibrate coordinates. Never reuse old chair masks on a new background.

First replacement candidate: `assets/rooms/revisions/library/library_west_east_draft_v2.png`.
Built-in image generation edited the existing library as a reference, using the exact
prompt and hashes in the sibling `review.json`. Status: **draft, awaiting user review**.
It is not registered as a runtime asset and has no calibrated furniture contacts.
The new layout puts the reading chair in front of the visible window: the bookshelf
obstruction is gone, but separate window approach/side-view clearance still needs
review. Do not call all window poses validated from this image alone.

Current upstairs route already arrives at `[240,292]`, facing north, from its south
threshold `[240,326]`. That navigation contract is preserved; the replacement art
must depict the same orientation. The main stair return is separate and unchanged.

Review: [current rooms, doorway labels and rework notes](../test-results/compact-mansion/index.html).


### Furnishing density revision — 2026-10-24

User requested useful furniture in the bar/study middle and lower floor instead
of broad empty space and an isolated rug. Current v2 candidates add a round pub
table with four chairs in the bar, and a four-chair document/conversation table
on a fitted rectangular rug in the study. Retain access aisles, window approaches
and stool clearance. Both remain unapproved drafts. Revision prompts and previous
candidate records are in the batch manifest and revision-requests.json.

2026-10-24 library revision: user approved the other eight gallery designs and requested a fuller library with EAST/SOUTH entrances and west-wall bookshelves. Candidate g_library_n0_e1_s1_w0_draft_v2.png uses the built-in image-generation edit workflow; exact prompt/input/output hashes are in the batch manifest. Library v2 awaits review. Before integration, redesign reciprocal connections for the changed west-to-south entrance and recalibrate all furniture contacts, masks and collision. Runtime routes remain unchanged.


Library v3: user authorized enlargement of the four undersized reading-table chairs. Built-in image edit produced g_library_n0_e1_s1_w0_draft_v3.png, preserving east/south entrances and existing room composition. Gallery now compares v2 with v3. Artwork review and Char contact-fit remain pending; no runtime background or furniture anchors changed.
