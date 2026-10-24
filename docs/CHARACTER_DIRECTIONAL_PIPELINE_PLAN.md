# Directional character assets and interaction pipeline

Current implementation update: [the opt-in Char live test](CHAR_LIVE_TEST.md) now consumes all seven approved samples through the shared standing-reference/contact renderer. Production staging, general pose selection and chair masks remain pending. Existing measurements and approved artwork are unchanged.

Planning revision 1, 2026-10-23. The user approved Char's seven alignment_01
samples and requested next-phase planning. The initial planning pass changed no artwork or runtime behavior. A subsequent user request implements directional file organization and additional provisional furniture side contacts; approved image bytes remain unchanged. Appearance approval does not certify furniture fit.

## Inspected baseline and authority

Sources: [workflow](CHARACTER_POSE_PRODUCTION_WORKFLOW.md), [measurement standard](CHARACTER_MEASUREMENT_STANDARD.md),
[rendering](CHARACTER_RENDERING.md), [furniture contract](FURNITURE_IDS.md),
[Char plan](CHAR_POSE_PLAN.md), [full audit](CHARACTER_POSE_AUDIT.md),
[reaction matrix](CHARACTER_REACTION_MATRIX.md), and [brainstorm](GAME_DESIGN_BRAINSTORM.md)
§2–13. GAME_DESIGN.md supplies visual/history context; current manifests and code
take precedence over older proposed art or scale rules.

| Area | Implemented now | Future requirement / proposal |
| --- | --- | --- |
| Character rendering | `src/characters/character_render.gd` draws one texture region with a feet pivot and shared adult height of 64 logical pixels | Pose-local contact adapter, asset selection and optional expression layers |
| NPC loading | `prototype_npc.gd` loads `identity.sprite`; `foyer/guest.gd` loads Eleanor's single image | Directional catalog consumer; no folder discovery exists |
| Char art | Four standing and three seated approved samples; original master/padded paths retained | Runtime bindings, calibrated landmarks and masks; final export/display standard |
| Furniture | 84 orientation IDs / 21 types; 14 layouts cover all 18 rooms | Automated reservations, pose selection, group staging and foreground masks |
| Contacts | 247 room contacts: 201 enabled, 46 disabled; 133 enabled approaches locally clear, 68 blocked; zero staging-ready | Path reachability and actual sprite fit, even for locally clear approaches |
| Mystery | Evidence examination/collection, authored conversations, fixed prototype statements | Personality assignment, emotional selector, accusations, reveal and autonomous schedules |

The existing audit has 47 concrete pose requirements and 34 semantic families.
These are compatibility requirements, not a demand for 79 separate drawings per
person. Catalog-only orientations are expansion options. All room-specific mappings
remain authoritative in [the contact map](pose-audit/furniture-contact-map.json)
and [mapping report](pose-audit/FURNITURE_POSE_MAPPING.md).

## Asset organization — implemented directional export folders

The user requested and authorized human-readable directional folders after the
initial plan. Char's seven approved exports were relocated without changing bytes.
Their manifest, approval hashes, job records, gallery and directional index now
resolve the new paths. Pose IDs remain stable. The index is authoring-only; an
automatic runtime pose selector has not been implemented.

```text
assets/characters/poses/char/
  index.html
  production-manifest.json
  directional-index.json
  masters/                         # approved source designs and native pose masters
  exports/
    north/char_standing_idle_north_neutral.png
    east/char_standing_idle_east_neutral.png
    east/char_seated_idle_east_neutral.png
    south/char_standing_idle_south_neutral.png
    south/char_seated_idle_south_neutral.png
    west/char_standing_idle_west_neutral.png
    west/char_seated_idle_west_neutral.png
  prompts/                         # retained production instructions/landmarks
  batches/                         # scope, technical status and explicit approvals
  review/alignment_01/index.html   # comparison and chair fit contexts
```

Required filename convention for every directional PNG:
`<character_slug>_<posture>_<action>_<direction>_<variant_id>.png`.
Always include the character, canonical direction and variant, including `neutral`.
For example, `char_standing_listen_east_concerned.png`. Keep names lowercase
snake_case; use the roster's stable character slug. Personality and guilt are case
state, not asset names. Distinct actions may include compound snake_case activities
such as `look_up`; read explicit metadata rather than guessing fields from underscores.
Lying art needs `exports/lying/<character_slug>_<lying_pose_id>_<variant_id>.png`
with its existing axis/headboard pose ID, not a false standing-facing label.

The loader should resolve the explicit character/pose/variant entry to these paths.
A folder alone cannot certify approval or furniture compatibility. Preserve common
scale and source contacts, and never automatically mirror asymmetric art. Target,
gaze, prop and gesture remain separate metadata/variant capabilities, avoiding a
personality × emotion × activity × direction cross-product.

## Expressions, personalities and reuse

The renderer currently has no facial overlays, replaceable heads, sockets or
expression layers. Godot can draw additional textures, but this project's head
registration, face masks and selection code do not exist. Initial production
should use a small number of complete transparent sprite variants. Reuse an
approved base through a reviewed art revision; keep the original immutable.
Expression differences can share body artwork only when registration and pixels
actually match. Never assume independently generated bodies will align as layers.

| View | Practical expression treatment | When distinct body art is needed |
| --- | --- | --- |
| South | Most readable face; pilot neutral, concerned/confused, annoyed and shocked | Recoil, hand-to-mouth, crossed arms, strong speech gestures |
| East / west | Separate authored profiles; eyebrow/mouth/gaze variants only when used | Target-specific reach, lean, hand/prop changes; do not mirror asymmetry |
| North | Face usually hidden; preserve rear hair/ribbon | Head tilt, upward/downward gaze, shoulder tension or clear gesture conveys reaction |
| Seated / kneeling / lying | Retain the correct base posture and contact | A standing reaction cannot substitute while still attached to a seat or bed |

Friendly/happy/relaxed, nervous/fearful/suspicious, angry/irritated, curious/confused,
sad/distressed/embarrassed, confident/smug/defensive and shocked are expression
families, not mandatory separate full bodies in every direction. Deception/guilt
are case states, not a compulsory guilty-looking face. Use the existing reaction
matrix for innocent accusation, exposed culprit and witness distinctions.

Future selection: event/knowledge eligibility → available compatible posture and
facing → personality-weighted expression/gesture → approved asset. Assign the
personality once at new-case creation and persist it, alongside reaction/activity
continuity when those systems are built. Do not reroll on room entry. Char's
personality and signature gesture remain unassigned.

An optional later overlay pilot needs one registered body/head base, per-direction
head pivot, face bounds/clip mask, hair/ribbon front layers, expression offsets,
alpha/outline checks and head-tilt compatibility. Test at current gameplay zoom
before committing the cast. Expressions invisible at 64-pixel stature need readable
body language or a separately approved dialogue portrait/presentation change.
Overlay reuse never crosses characters, head angles or incompatible hairstyles by
default. This optimization is proposed, not required before small full-sprite batches.

## Environmental pose planning

Use existing posture/activity/facing IDs where the action is already represented.
Different target heights can be variants under the same compatible base ID; a new
activity/posture requires an explicit catalog/validator extension before staging.
Target height is relative to the actor's shoulder/eyes/reach, not just room Y.

| Interaction | Current data / exact examples | Art and metadata needed next |
| --- | --- | --- |
| Painting / clock above actor | `g_foyer::foyer_portrait_01::inspect`, `painting_south`; `g_foyer::foyer_clock_01::inspect`, `clock_south`; actor north, `standing_look_up_north` / `standing_inspect_north` | Visible upward head/gaze; inspect target bounds and actor eye landmark |
| Shelf read / reach | `g_library::library_bookshelf_01::inspect`, `bookshelf_south`, actor north; `standing_read_north`, `standing_reach_north`, `standing_inspect_north` | Distinguish held/open book from reaching high; hand target, shelf height and reachable range |
| Side shelf | `g_library::library_west_shelves_01::inspect`, `bookshelf_east`, actor west; read/reach/inspect west | Own west art and hand ownership; independent of object's east facing |
| Table book | `g_foyer::foyer_reading_stand_01::use`, `table_south`, actor north; `standing_read_north` / `standing_inspect_north` | Table-book variant with downward gaze, book/page position; not the high-shelf reach |
| Floor marks | Brainstorm §7 proposes a hint; no floor-target contact family exists | Proposed `standing_look_down_<facing>`; kneeling inspect for closer view; author target/approach first |
| Bare wall / lamp touch | User next-phase direction; catalog has no `wall` or `lamp` type | Add types/orientations/targets only when backgrounds support them; wall inspection, lamp touch and grip are distinct |
| Touch bed / chair / surface | Furniture present; `inspect` alone does not define hand contact | Proposed touch activity, hand/target landmarks and finger continuity; touch → inspect same finger is future brainstorm §8 |
| Pick up / inspect held object | Evidence examination/collection exists; body grip animation does not | Proposed pickup/held-inspect capability, object asset/instance ID, hand, grip, approach and carry state; no weapon in hand merely because inventory owns it |
| Seated reading | Approved idle E/S/W plus existing seated_read E/S/W requirements | New held-book art using corresponding approved seated reference; preserve seat and skirt geometry |
| Doorway listen / peek | `g_foyer::foyer_front_door_01::inside`, `doorway_south`, actor north; listen/peek/inspect north | Existing actions do not supply handle/open/lock poses. Keep front exit locked; doorway tags are not travel portals |
| Open door | Traversal uses room portal code, separate from furniture annotations | Proposed open activity, handle/hinge targets, hand and occluding door layer; do not imply every decorative door opens |
| Window / hearth | Existing look_out north; warm_hands north/east; kneeling inspect north/east | Gaze/contact/heat distance, knees and floor-feet separation; verify each enabled contact |
| Bed lie / sit | `u_guest::guest_bed_01::lie`: `bed_north_south_head_north`, `lying_idle_north_south_head_north` | Pelvis plus head/heel landmarks; actual axis/headboard match; no standing-facing substitution |
| Suspicious discovery / reveal | Reaction matrix and brainstorm future events | Contextually justified expression/body variant; preserve occupied posture, knowledge, props and witness roles |

`door` is a user-facing term; persist the existing `doorway` type. Do not add a
conflicting synonym. Crouching is documented future art intent but the current
furniture validator accepts only standing/seated/kneeling/lying. Extend it explicitly
before adding crouched contacts. All example contacts remain provisional, including
the locally clear ones. See the full mapping for every room, not only these examples.

## Proposed selection and alignment contract

Resolve a room-scoped `room_id::instance_id::anchor_id` against the room's current
background. Read exact orientation ID, enabled flag, posture, activity, actor
facing (or bed axis/head), contact kind, approach, clearance, target instance and
occupancy group. Match an approved asset by those requirements, then its variant
capabilities. Reject incompatible props, hand targets, reach, skirt clearance or
mask requirements. A missing facial variant may fall back to an approved neutral
variant **of the same compatible body**; missing body/facing/contact support must
hold the action or choose another valid unoccupied anchor. Never force a mirror,
wrong-facing seat or standing pose into a seated slot.

| Data responsibility | Existing fields | Proposed additions, not runtime fields yet |
| --- | --- | --- |
| Furniture/layout | orientation ID, instance ID, position/bounds/footprint, anchor contact/approach/clearance, posture, activities, actor_facing, contact_kind, bed_axis/head, enabled, ready_for_staging | Target landmark/band, hand-contact target, allowed reach envelope, mask references |
| Character asset | Manifest pose_id, source/export, approval, source landmarks, common standing reference and fit records | Variant expression/gaze/gesture/props/hand, reach envelope, explicit occlusion dependencies, compatibility exclusions |
| Live actor/case | Current prototype identity/location and fixed statements | Personality, activity/variant, target key, reservation, held prop, event role/knowledge, reaction continuation/save state |

Keep authoring positions background-local (normally 480×320). Use the existing
background-fit transform into world Rect(0,24,480,320); do not apply the 24-pixel
header offset twice. Resolve local instance/anchor offsets through that transform.
Draw using `world_contact + (source_region_origin - source_contact) * scale`, with
Char's common `64/1673` source scale and identity stature ratio. Never derive seated
scale from its own opaque height. Record source-canvas and padded-export landmarks
separately (+64,+64 for these seven exports).

Feet/floor, seat/pelvis/knees, shadow and depth-sort landmarks are separate. Baked
chair arms/desk fronts require front masks or actual layers before believing a
sprite fits; rectangles alone cannot supply masks. Reserve shared occupancy groups
and test ingress/egress, actor/prop footprints and exits. A clear endpoint footprint
is not pathfinding proof. Height differences need appropriate reach/art or another
target; do not stretch a short adult to meet a shelf.

## Production order and decisions

1. **Done here:** record scoped artwork approval; preserve all PNGs; create the
   authoring directional index and this plan. Directional export folders are now implemented; no new artwork.
2. **Recommended engineering next, requires implementation scope:** shared
   reference-height/contact renderer and explicit catalog consumer; retain current
   single-sprite fallback for existing NPCs. Calibrate Char's three chairs and masks,
   validate actual room placement and measure expression readability.
3. **Proposed next art review batch, not authorized by this planning request:**
   four south-facing standing variants: conversation/open-hand, concerned/confused
   listening, annoyed listening and shocked discovery. Use approved south base plus
   likeness-v2; one complete sprite per requested variant. No automatic four-way copies.
4. **Environment pilot:** north look-up at foyer clock/portrait; north table-book
   reading at foyer reading stand; north shelf reach at library shelf. These test
   target height differences with existing contacts. Add floor look-down after its
   contact/activity is specified. Then seated read E/S/W on the approved bodies.
5. Expand to side/rear reactions only where scenes demand them; later beds, kneeling,
   same-hand surface discoveries, accusation/culprit/witness batches and groups.
   Walking remains separate. New batch sizes/poses require user review before art.

Open decisions before production: presentation/readability target; whether to build
the shared adapter before more samples; exact next art batch; final personality list
and signature gestures; which door/prop interactions actually enter the first case.
No permanent Char personality is needed to pilot shared expressions. A complete
four-direction × every emotion × every furniture combination is not recommended.

## Resume and validation

Read `char/directional-index.json` and the production manifest. Approval is scoped
to the seven art samples; landmarks, staging and runtime remain pending. Historical
review images still say draft: preserve them as the original review evidence.
Do not run `tools/render_char_alignment_review.gd` over approved exports; it writes
those paths. Any later technical export revision needs a new path and source link.

Read-only artwork verification: `python tools/validate_char_alignment.py` and
`python tools/validate_character_pose_audit.py`. This planning pass additionally
compares all character PNG hashes before/after and checks index directions, contact
keys and approval parity. Native furniture metadata tests and refreshed review screenshots cover the side-contact update; no character fit approval is inferred.
