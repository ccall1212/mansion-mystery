# Character pose coverage and production audit

Current status (2026-10-23): all seven alignment_01 artwork samples are user-approved. Original review images/labels and executed prompts are preserved; contact calibration, masks and runtime integration remain pending. See [next-phase plan](CHARACTER_DIRECTIONAL_PIPELINE_PLAN.md).

**Subsequent production update:** [Char alignment_01](CHAR_ALIGNMENT_01_REVIEW.md) has seven generated drafts pending pose approval. The initial planning audit below is historical; the derived master matrix reads current production status. Runtime integration remains absent.

Recorded 2026-10-23. **Planning/documentation only. No artwork generated, designs
changed, runtime pose integration added or new appearances approved.**

## What exists and what is planned

| Evidence | Actual state | Consequence |
| --- | --- | --- |
| `src/characters/prototype_npc.gd`, `prototype/roster.json` | Seven temporary NPC identities use one existing standing PNG each | No furniture, emotional or dialogue pose selector exists |
| `src/foyer/guest.gd` | Revised Eleanor uses one standing PNG; `addressed` does not select different art | Historical references to her turning between two artworks do not describe current rendering |
| `src/foyer/foyer.gd`, `src/mansion/playable_mansion.gd` | Authored questions/statements, player facing and movement lock | Questioning works; refusal/personality, accusation and reveal logic do not |
| `src/evidence/evidence_state.gd` | Inspection, explicit tool use, collection and notebook state work | These UI operations do not prove hand-held object or magnifier poses exist |
| `src/characters/character_render.gd`, `rendering.json` | Shared 64-pixel adult stature; standalone images normalize by their own opaque height | A new shared reference-height/contact adapter is needed before nonstanding poses can be integrated |
| Furniture catalog/layouts and `furniture_library.gd` | Directional tags, anchors, required pose IDs and room-scoped lookup exist | All contacts remain provisional; no occupancy, pose matching or foreground masks are implemented |
| Active `review-v8/cast-catalog.json` | 17 designs: 01–15, 20–21; selected looks and archived variants | Appearance selection is separate from pose approval and fictional personality/guilt |
| `assets/characters/production.json` | Earlier 15-character art experiment with historical names/head rules | Historical archive, **not** active cast or pose authority; never overwrite it for Char |
| Detective horizontal animation | Existing experimental assets remain on disk | User delegated animation elsewhere after rejecting the result; excluded from this production task |

The requested measurement-standard file was absent. The new
[measurement standard](CHARACTER_MEASUREMENT_STANDARD.md) records the current
renderer, canonical references and missing measurements without pretending earlier
48-pixel or three-head prescriptions are current approvals.

## Coverage result

- **18 rooms, 14 background layouts, 118 unique objects / 149 room instances.**
- **209 room contacts:** 163 enabled, 46 disabled; zero approved for staging.
- 102 enabled approaches pass the current local feet-footprint test; 61 fail it.
  This is neither pathfinding nor body/pose fitting. NPC occupancy was excluded.
- **84 furniture orientation IDs:** 38 used in current rooms, 46 catalog-only.
  Catalog-only variants are expansion coverage, not 46 missing current-room assets.
- **40 exact furniture action/alignment IDs.** Four-direction standing idle,
  talking and listening coverage produces **45 concrete pose requirements**.
- **34 semantic action/reaction/event families** supplement those concrete IDs.
  Families are not 34 additional unique images, and are not multiplied by every
  direction, posture, personality and cast member automatically.

See the [master concrete matrix](pose-audit/MASTER_POSE_MATRIX.md),
[all room/contact mappings](pose-audit/FURNITURE_POSE_MAPPING.md),
[full mapping CSV](pose-audit/furniture-contact-map.csv),
[full mapping JSON](pose-audit/furniture-contact-map.json) and
[all orientation IDs](pose-audit/orientation-coverage.csv).
The machine-readable authoring inventory is
`assets/characters/poses/pose-requirements.json`; semantic provenance is in
`requirements-brief.json`. Neither is loaded by gameplay.

## Essential shared capability

Every participating speaking character should eventually support standing idle,
talk and attentive listening in north/east/south/west, because the detective or a
conversation partner can be on any side. This is a future common capability,
not an assertion that all 12 assets currently exist. Talking/listening may share
approved base body art with expressions or small gestures.

Shared reaction vocabulary should support shock, fear, suspicion, anger, sadness,
embarrassment, relief, confidence, annoyance, nervousness, confusion and disbelief.
These are semantic states; an expression on a compatible existing pose can satisfy
one. Do not give every character identical hands-to-face shock, crossed arms or
head scratching. Do not infer a permanent personality from a photograph.

Produce additional directions only when an actual scene or interaction needs them.
Back-facing emotion may need head/shoulder body language because its face is hidden.
The front/south-facing expression sheet proposed for review is not four-direction
runtime coverage and must not be listed as such.

## Furniture and orientation coverage

| Actual interaction | Current required alignment | Art/contact dependencies |
| --- | --- | --- |
| Chairs, armchairs, sofas, benches, bed sides | Seated idle/read/talk east, south, west | Seat landmark, knee/foot position, skirt spread, seat occupancy and armrest/front-edge masks |
| Desk work / vanity | Seated write south/west; seated reading; standing inspect/read north/west | Pen/paper and handedness, real work surface, chair contact and desk foreground |
| Shelves, cabinets and tables | Inspect north/east/west as mapped; reach north/east/west; read as mapped | Target height, leading hand, grip if retrieving something, foreground overlap |
| Windows | Standing look-out north | Gaze at window, feet on floor, window/bench access |
| Clock, paintings, statues | Standing inspect and look-up north | Head/gaze target, correct floor projection; keep whole-body scale |
| Fireplace/fire baskets | Standing warm-hands/inspect north/east; kneeling inspect north/east | Safe hand/flame spacing, grounded knees, fire basket is not an invented hearth |
| Doors and stair entries | Inside-side inspect/listen/peek in actual actor direction | Contact side distinct from travel; no new passage or trap implied by a label |
| Beds | Lying north_south, head north; sitting on enabled accessible side | Pelvis plus head/heel landmarks, mattress height, rail/blanket mask and accessible approach |
| Bar counter | Standing idle/talk/drink north | Counter surface height, cup/glass grip; no usable stool currently tagged |

Seated north, horizontal beds and alternative headboards exist in the vocabulary
but have no enabled current-room demand. Stools require a real stool asset and a
linked counter before producing stool-fit poses. Do not silently add them to Char's
first set. A body action such as sleeping must not be inferred from `lying_idle`.

The CSV/JSON contains **every enabled and disabled contact**, not just examples:
type, orientation, exact room/instance/anchor, posture/action, actor facing or lying
axis/head, feet/seat/knees/pelvis landmark, local and resolved world coordinates,
clearance, props/hand requirements, target furniture, occupancy grouping and mask
status. Shared backgrounds remain separate room instances. Disabled contacts
request zero production poses; their template IDs are retained for diagnosis only.

## Overlooked actions and their status

| Need | Source / status | Minimal representation and constraints |
| --- | --- | --- |
| Questioned, annoyed, refusing | Brainstorm §4–5, confirmed future | Listen/talk base + expression; optional turn-away or closed-off gesture; preserve alternative clue routes |
| Looking down at floor | §7, proposed hint | Gaze/head change and separately recorded floor target; clean floors may prompt the same action |
| Touching a surface then inspecting a finger | §8, confirmed future accidental discovery concept | Touch → same-hand finger inspection → reaction/comment → return; material must exist in source evidence |
| Kneeling / crouching | §5 and current user request | Distinct body geometry with knees/feet contacts; a crouch is not squeezed standing art |
| Inspecting with magnifier or showing/holding evidence | §9 partly implemented as UI; physical handling is a proposal | Actor eligibility, item scale/grip and hand decision; do not require every NPC to carry the detective's tools |
| Pointing out a discovery | Historical art examples / production proposal | Optional target-oriented arm/gaze; not already assigned to Char |
| Hiding under furniture | Historical art guide / optional proposal | Requires an approved hiding mechanic, capacity, complete crouched sprite and real mask; removed boy is not active cast |
| Chris's hat-on/head-scratch | §5 and explicit user request, identity-specific | Existing selected masters exist, but no directional runtime pose binding; same Chris, no extra cast member |
| Stalking, locking a door, threatening, capture | §5, §10–12 | Record full dependency chain; exact trap/attack choreography and directions need decisions; locomotion is external |

## Personality and emotional reuse

[Personality, emotion and mystery-event matrices](CHARACTER_REACTION_MATRIX.md)
cover shared vocabulary, candidate traits, signature actions and all documented
ending situations. The twelve brainstorm personality types are candidates, not
approved assignments. Char's personality is **unassigned**. Case-dependent guilt
is also unassigned for all likeness-based characters.

Use separate planned fields for posture, activity, facing/alignment, expression,
gesture, prop, mystery role, knowledge and personality. Expression layers are a
production/reuse strategy, not an already implemented sprite layering system.
Only approved visual equivalents may reuse an output. Do not assume automatic
mirroring is safe for a ribbon, sash, hat, facial asymmetry, lighting or handedness.

## Group and reveal acceptance

Reserve real seats/standing positions with valid approaches. At a reveal:
1. Stop/interrupt current activities without dropping or duplicating props.
2. Identify the accused, actual culprit, detective and informed witnesses from case state.
3. Select individual responses compatible with posture, knowledge and personality.
4. A seated person uses a compatible seated reaction, or a validated stand-up
   transition and clear standing position; never paste a standing body on a seat.
5. Maintain partner-facing, gaze targets, layered furniture and enough exit space.
6. Release reservations at real transitions; persist activity/reaction/role state
   across room changes and load. Exact simulation/event implementation is future work.

The master vanity and its chair share `master_vanity`: one physical seat, not two.
Paired restraint requires two people and paired hand/body targets. A single
threatening sprite cannot supply a two-person capture scene. First-case group size,
capacity fallback and whether a reveal gathers everyone are still undecided.

## Coverage gaps and production order

| Gap | Before it can be called complete |
| --- | --- |
| Char has one selected identity PNG, no validated new directional set | Review seven alignment samples; record exact approvals per pose |
| 61 blocked approaches / all contacts provisional | Calibrate against actual navigation and the chosen pose, not just visual rectangles |
| Nonstanding renderer stretches occupied height to 64 | Shared standing-reference scale, pose contacts, separate floor/shadow/depth landmarks and tests |
| Current furniture validator accepts standing/seated/kneeling/lying only | `crouching` is a planned extension; approve metadata/consumer changes before binding crouch assets |
| Baked furniture has no masks | Author/test foreground masks or compatible draw layers; don't erase character limbs into masters |
| Personality and mystery event selectors absent | Agree cases/traits/roles, then integrate supported combinations with explicit fallbacks |
| Only 38 orientations in rooms | Keep 46 unused definitions visible as future expansion; add art only when rooms demand it |
| Handedness and carried props undecided | Approve grips, asymmetric art rules and object/hand targets per activity |
| Display looks too small (user follow-up) | Review fullscreen/window scale versus higher internal detail before final export/canvas standards |
| Pose persistence and offscreen activity absent | Future save/event schema and continuity tests; no silent reroll on load |

Recommended batches: **1 alignment (7 samples)** → **2 conversation** →
**3 furniture activity in actual orientations** → **4 shared emotional samples** →
**5 floor/accidental discoveries and crouch** → **6 accusation/reveal subset** →
**7 selected danger/group transitions and optional signatures**. These batches are
a proposal for review, not artwork authorization. Char should demonstrate a reusable
production process without becoming responsible for every detective-only action.

## Reproduce and maintain this audit

Run `python tools/audit_character_poses.py`, then
`python tools/audit_character_poses.py --check` from the project root. The generator
reads actual room tags and the authored semantic brief, regenerates derived maps,
and initializes Char's manifest only if absent. Existing production records and
approvals are never overwritten; new requirement IDs require an additive reviewed
manifest update. Source fingerprints detect stale audit inputs and changed identity art.

The previous `char-pose-plan.json` and room screenshot generator remain the original
furniture-only subset. They are not the full emotion/event audit. See
[Char's plan](CHAR_POSE_PLAN.md), [the workflow](CHARACTER_POSE_PRODUCTION_WORKFLOW.md)
and [the reusable prompt](CHARACTER_POSE_PRODUCTION_PROMPT.md) for production.

## Decisions before artwork

1. Choose presentation review: larger window/fullscreen at current detail, or a
   coordinated higher internal-resolution target. Do not change dimensions silently.
2. Confirm Char's seven alignment samples as the first art batch.
3. Select the first personality subset, or retain a neutral unassigned Char for alignment.
4. Select first-case accusation/reveal branches and whether seated reactions or
   stand-up transitions take priority. No need to resolve the whole ending library now.
5. Decide prop hand/grip conventions when approving reading, writing and drinking.

No new pose generation has been authorized by this planning task. Review these
decisions and the concrete batch before producing art, then review artwork before
final approval and integration.

Current side-contact extension: windows/pictures/clocks add 38 unique side anchors. The regenerated master matrix has 47 concrete pose IDs and 247 room contacts (201 enabled, 46 disabled). See FURNITURE_IDS.md and the linked gallery; all placements remain unapproved for staging. Char’s approved exports are now organized and named by direction as documented in CHARACTER_DIRECTIONAL_PIPELINE_PLAN.md.
