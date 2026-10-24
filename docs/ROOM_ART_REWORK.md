# Room art review and doorway contract

User feedback recorded 2026-10-23. This is the current rework brief. Existing
backgrounds remain placeholders until replacement art and placement are reviewed.
The seven-room scope is retained; a bar and bathroom are future expansion options.

| Room | Review | Required change | Target usable openings |
| --- | --- | --- | --- |
| `g_foyer` | Connection gap still open | Resolve the bent south vestibule when revising the entrance layout. Keep the north/front door locked. | N locked front door; S internal passage |
| `g_main_stair` | User: “looks alright” | Preserve the current appearance; still validate doorway/flight pairing. | W library; S foyer; separate upstairs flight |
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
