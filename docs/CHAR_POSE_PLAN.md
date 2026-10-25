# Char — first complete furniture pose plan

This is the original furniture-only subset (42 IDs). The full source-linked audit adds conversation coverage (45 concrete IDs) and semantic reaction/event families. See [the full audit](CHARACTER_POSE_AUDIT.md), [master pose matrix](pose-audit/MASTER_POSE_MATRIX.md), [workflow](CHARACTER_POSE_PRODUCTION_WORKFLOW.md) and [reusable production prompt](CHARACTER_POSE_PRODUCTION_PROMPT.md). The current production record is `assets/characters/poses/char/production-manifest.json`.

This is the original furniture requirement subset. Current generation/approval progress lives in the production manifest and [alignment review](CHAR_ALIGNMENT_01_REVIEW.md); do not interpret these requirement rows as missing or approved art automatically.

Char is cast #01: the approved cream blouse, teal-green long skirt, burgundy sash, cream ribbon and long brown wavy hair. Preserve her face, adult anatomy and established pixel-art detail. Use the approved design reference recorded in her production manifest; the existing character art standard remains authoritative.

## Start with seven alignment samples

Four standing facings (north/east/south/west) and three seated facings (east/south/west). The tagged furniture currently does not require seated north. Approve these proportions and contact landmarks before producing action variants. These are static pose samples; walking animation remains a separate task.

Fit the seated-west sample to the foyer armchair, seated-south to the library chair, and seated-east to the kitchen chairs. Fit tests must check the actual chair surface, feet, skirt volume and which furniture pixels cover the character. A clear approach is not proof that a pose fits.

## Full action coverage

The enabled furniture contacts request **42 distinct action/direction combinations**. Adding the east/west standing base samples gives **44 planned pose requirements**. These are requirements, not necessarily one unique image per ID: compatible actions may share an approved base drawing. No mirroring or art reuse is assumed safe.

| Pose requirement | Room contacts | Clear approach footprints | Phase |
| --- | ---: | ---: | --- |
| `kneeling_inspect_east` | 2 | 2 | 2 |
| `kneeling_inspect_north` | 5 | 2 | 2 |
| `lying_idle_north_south_head_north` | 2 | 1 | 2 |
| `seated_idle_east` | 6 | 2 | 1 |
| `seated_idle_south` | 12 | 2 | 1 |
| `seated_idle_west` | 11 | 5 | 1 |
| `seated_read_east` | 6 | 2 | 2 |
| `seated_read_south` | 12 | 2 | 2 |
| `seated_read_west` | 11 | 5 | 2 |
| `seated_talk_east` | 6 | 2 | 2 |
| `seated_talk_south` | 9 | 2 | 2 |
| `seated_talk_west` | 10 | 5 | 2 |
| `seated_write_south` | 3 | 0 | 2 |
| `seated_write_west` | 2 | 0 | 2 |
| `standing_drink_north` | 1 | 1 | 2 |
| `standing_idle_east` | 0 | 0 | 1 |
| `standing_idle_north` | 2 | 2 | 1 |
| `standing_idle_south` | 1 | 0 | 1 |
| `standing_idle_west` | 0 | 0 | 1 |
| `standing_inspect_east` | 36 | 25 | 2 |
| `standing_inspect_north` | 76 | 51 | 2 |
| `standing_inspect_south` | 6 | 6 | 2 |
| `standing_inspect_west` | 42 | 35 | 2 |
| `standing_listen_east` | 9 | 6 | 2 |
| `standing_listen_north` | 12 | 11 | 2 |
| `standing_listen_south` | 7 | 6 | 2 |
| `standing_listen_west` | 17 | 13 | 2 |
| `standing_look_out_north` | 14 | 12 | 2 |
| `standing_look_up_east` | 19 | 13 | 2 |
| `standing_look_up_north` | 23 | 21 | 2 |
| `standing_look_up_west` | 19 | 18 | 2 |
| `standing_peek_east` | 9 | 6 | 2 |
| `standing_peek_north` | 11 | 10 | 2 |
| `standing_peek_south` | 6 | 6 | 2 |
| `standing_peek_west` | 17 | 13 | 2 |
| `standing_reach_east` | 1 | 1 | 2 |
| `standing_reach_north` | 17 | 16 | 2 |
| `standing_reach_west` | 2 | 2 | 2 |
| `standing_read_east` | 3 | 2 | 2 |
| `standing_read_north` | 11 | 7 | 2 |
| `standing_read_west` | 4 | 2 | 2 |
| `standing_talk_north` | 1 | 1 | 2 |
| `standing_warm_hands_east` | 2 | 1 | 2 |
| `standing_warm_hands_north` | 5 | 2 | 2 |

Phase 2 adds reading/talking/writing, looking outside/upward, inspecting/reaching, listening/peeking, warming hands, kneeling and lying. Produce these in small review batches after the seven alignment samples.

## Integration contract

- Store a pose-specific contact landmark: feet, seat, knees or pelvis. Place that landmark on the furniture contact; do not snap every sprite’s bottom edge to a chair seat.
- Standing actor facing is separate from furniture facing. Lying uses the bed axis and headboard direction.
- Keep the shared adult rendering scale. Do not resize or stretch Char independently to fit each piece of furniture.
- Respect disabled contacts, draft status, occupancy and movement clearance. The master-bedroom vanity and its chair share the `master_vanity` occupancy group; this is metadata for future staging, not implemented automatic occupancy.
- Supply appropriate foreground masks/layers before hiding skirt/legs behind a desk or bed. Existing baked room art does not automatically provide occlusion.
- The machine-readable plan lists every exact room/object/contact source and its current local-clearance result: `assets/characters/char-pose-plan.json`.

[Review all tagged rooms first](TAGGED_ROOM_SCREENSHOTS.md). Character looks and pose batches must be shown to the user before finalization.

## Current user sequence — 2026-10-24
Foyer visual fits are approved. Review the 15 dining/kitchen/upstairs seat comparisons and four missing seated-north contacts, then complete Char’s directional actions, book poses, personality gestures, emotions and reveal reactions. Complete other character pose sets before randomized NPC staging. See [the current batch checklist](CHAR_NEXT_POSE_BATCHES.md); this supersedes earlier staging-first recommendations. No new artwork or staging was implemented in the seat comparison task.
