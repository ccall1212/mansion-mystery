# Shared furniture size standard

The machine-readable defaults are in `assets/furniture/size-standards.json`.
These are proposed production targets, pending a visual fit review with Char.
They do not certify or resize existing painted furniture.

Use the current shared **80-unit standing adult** in the **480 × 320 background
coordinate space**. At 1536 × 1024 source resolution, multiply these measurements
by 3.2. Camera zoom and window resolution must scale furniture and actors together.
This supersedes the environment guide's older 48-unit character comparison.

| Profile | Seat above floor | Usable seat width | Projected seat depth | Approx. full width × height |
| --- | ---: | ---: | ---: | ---: |
| Ordinary chair | 22 | 26 | 16 | 32 × 46 |
| Armchair | 22 | 26 | 18 | 44 × 50 |
| Bar stool | 32 | 22 | 14 | 26 × 36 |
| Bench | 22 | 26 per person | 16 | 72 × 28 |
| Sofa | 22 | 26 per person | 18 | 88 × 50 |

Allow approximately 15% variation as an initial review band. Seat height and usable
width matter more than decorative backs and arms. Full bounding dimensions are
composition guides, not automatic pass/fail measurements. Side/rear views will
have different projected silhouettes; don't stretch them into identical rectangles.
Stool height excludes an optional back. Its proposed footrest is 12 units above
the floor, and must align with a dedicated stool pose. A low work stool can use
the ordinary seated height through an explicit future profile, not `bar_stool`.

## Authoring and tagging every room

1. Include this profile table and the approved Char reference in every new room
   or furniture generation request. Require separate visible seats and readable
   floor contact, footrests and access space. Preserve the mansion camera.
2. Use existing orientation IDs such as `armchair_west`. The catalog's
   `size_profile_id` adds sizing without inventing new orientation synonyms.
3. Measure each painted seat independently. Record the instance's `size_profile_id`,
   `size_review` and `size_measurements` using the JSON contract. Both floor and
   seat points are local to the furniture origin. A floor point must be directly
   below the seat, not the nearest front leg or approach position.
4. Compare the seat-to-floor rise and usable dimensions with the profile. Old
   annotation bounds and anchor presets are provisional and cannot prove fit.
5. Preview Char at her shared standing-reference scale in each required direction.
   Check pelvis on seat, feet on floor/footrest, skirt clearance, back/arm overlap,
   approach path and masks. Ordinary and armchair poses may share a base only if
   their contacts and occlusion actually fit. Bar stools need separate leg poses.
6. If the painted chair is too large/small, revise its artwork or replace it with
   an approved reusable furniture asset. Do not resize the character to compensate.
   An overlay needs a clean background so the original chair is not visible below it.
7. Keep contact staging disabled until visual fit is approved. Art approval of a
   room does not approve furniture scale or Char's placement automatically.

## Existing rooms and future production

Run `python tools/audit_furniture_sizes.py` to inventory every annotated seat and
report missing measurements or size deviations. The report is a review queue,
not automatic staging approval. New room candidates without annotations cannot
be measured by this audit yet; tag them after artwork selection.

Existing layouts are preserved. The next useful visual checkpoint is Char beside
one ordinary chair, one armchair and one bar stool, then seated in each. Approve
that reference set before correcting every painted seat. Longer-term, separate
reusable furniture sprites will provide stronger consistency than AI-generated
chairs baked independently into each room.
