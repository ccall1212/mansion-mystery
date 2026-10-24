# Current character measurement and canonical art standard

Current implementation update: [the opt-in Char live test](CHAR_LIVE_TEST.md) now consumes all seven approved samples through the shared standing-reference/contact renderer. Production staging, general pose selection and chair masks remain pending. Existing measurements and approved artwork are unchanged.

Recorded during the 2026-10-23 pose audit. This file did not exist at audit start.
It consolidates the inspected renderer and user-selected references; it does not
approve new artwork or prescribe unmeasured head landmarks.

## Current versus target authority

Current runtime preview uses **80 reference-world units** for adult standing
height from `assets/characters/rendering.json`; the previous value was 64. The
shared renderer applies each identity's intended height ratio (Char 1.0, Jessica
0.85) and preserves aspect ratio. No source PNGs were resized or stretched.

Presentation now uses a 960×720 internal viewport and up to a 1280×960 window,
fitted to the usable monitor. Room, physics, portal and furniture coordinates stay
in the 480×360 reference space. Camera/UI transforms map that space into HD.
Detail zoom is 1.5×; Z toggles the 1× whole-room overview, F11 toggles fullscreen.
Char's F7 test now starts in detail view, focused on her until movement resumes.
These settings are an implemented preview awaiting user presentation review.

The original alignment_01 source/padding/landmark records and approval hashes are
unchanged. Their `logical_standing_height: 64` is historical review context, not a
per-pose runtime sizing instruction. Char's source standing reference remains 1673;
the live renderer now uses **80/1673** for every pose. Seated poses stay shorter.
The measurement snapshots below retain their original 64-unit context.

User canonical art direction: **Char (#01) and Sarah Jo (#13) for women; Kwinn
(#07) and Chris (#06) for men**, with Sarah Jo/Kwinn primary proportion/detail
references and Char/Chris additional authoritative identity/rendering examples.
Do not average every draft on the cast sheet. Preserve distinct ages, builds,
facial features, hair/facial hair, clothes and accessories within that rendering language.

| Reference | Actual source / selection | Comparison and approval limits |
| --- | --- | --- |
| Char | `review-v6/sources/selected-party-hm.png`, grid `[3,2,1]`; extracted `prototype/cast-01.png` | Selected cream blouse/teal skirt/ribbon look; taller adult anatomy with expressive head and soft face. Seven alignment_01 artwork samples approved; runtime contact calibration pending |
| Sarah Jo | `review-v7/masters/sarah-jo-short-hair-proportions-v7.png` | Very short cropped hair, visible ears/nape, detailed navy historical dress; short-hair look explicitly approved |
| Kwinn | Same Party H–M source, grid `[3,2,3]` | White shirt/red waistcoat, scruffy goatee and cheek/jaw scruff; preserve adult legs/torso, clear expressive face and fabric detail |
| Chris | `review-v6/sources/selected-hat-pair.png`, grid `[2,1,0]` / `[2,1,1]` | Selected hat-on and fuller-beard bald/head-scratch looks; same identity, period vest/clothes and natural anatomy |

All paths above are relative to `assets/characters/`. The v8 catalog holds exact
panel crops and identity merges. The Char manifest records source hashes. Selection
of a look is not final approval of every new pose or of the whole roster.

## Measurements that are actually available

Char's current runtime cutout is **252×472 source pixels**, with alpha≥128 bounds
`[0,0,252,472]`. Under the current standing renderer, 472 source pixels correspond
to 64 logical pixels: scale `64/472`, or **7.375 source pixels per logical pixel**.
This measures standing occupied artwork; it is not a specification for every export
canvas. New pose canvas dimensions, transparent padding and crown/chin/head-width
landmarks are unapproved and must be recorded at the first alignment review.

The historical art guide measured the detective's original front cell at source
rect `(398,41)-(528,292)`: **130×251**, with an approximately 90-pixel crown-to-chin
interval by visual inspection (~36%, 2.8 heads tall). Those are recorded historical
landmarks, not newly segmented ground truth. His current shared stature is 64;
the earlier 48-pixel display and three-head prescription are superseded as a common
cast rule. His original sheet remains his identity/animation reference.

The canonical likeness references visibly have longer adult torso/leg proportions
than the compact detective. The earlier guide describes roughly 4–4.3 heads for
taller likeness revisions, but this is not an individually measured approval for
Char, Sarah Jo, Kwinn or Chris. Their exact crown/chin/head-width ratios remain to
be measured and reviewed; do not turn an estimate into a numerical generation rule.
Record measurements for all four before a future full-cast anatomy remake.

Future detective corrections: align adult head/body ratio, facial detail and pixel
cluster density with the canonical references while preserving chestnut hair,
charcoal-teal coat, burgundy waistcoat, cream collar and boots. Do not stretch his
head/limbs or revise the outsourced walking animation during this audit.

## Shared rendering and pose scale contract

Use richly shaded deliberate pixel clusters, consistent outlines and light,
natural hair/facial hair, readable faces/hands and detailed period clothing.
Women retain the requested soft skin shading and individual ages/features.
Source resolution alone does not establish matching pixel density. Compare
head/shoulder, body, clothing detail and expression both in masters and at gameplay size.

The current `single()` path uses each image's maximum opaque height as its reference.
That is suitable for current standing cutouts, but **would enlarge a seated or
crouched pose to standing height**. Before integrating new poses, implement an
authorized shared reference-height/contact path, retaining aspect ratio. It must:

- Use an approved standing reference in common source units, not pose-specific
  occupied bounds, to derive scale for seated/kneeling/crouched/lying variants.
- Store feet, seat, knees or pelvis landmark plus source trim/crop offsets.
- Keep foot-ground/shadow and depth-sort landmarks separate from seat/pelvis contact.
- Respect bed axis/headboard and furniture actor facing; do not infer them from canvas shape.
- Preserve a common identity height ratio across activities; do not resize Char
  separately for each room or chair.

This adapter and pose metadata consumer are **not implemented** by documentation.
The first seven Char samples must demonstrate the contract before runtime use.
Contact/mask/navigation approval is separate from sprite appearance approval.

## Display size decision remains open

The user asked for a larger presentation during this audit. A larger window or
fullscreen preserves current internal pixel detail. More internal detail requires
coordinated viewport, art, camera, UI and coordinate handling. Do not simply enlarge
the logical viewport and leave actors/backgrounds at their old world sizes, which
could make them appear smaller. Preserve background-local furniture coordinates
through a consistent transform. Review readability before locking export dimensions.
No resolution or asset size change has been made here.

## Char approved v2 and first alignment samples

The user-approved pose reference is now
`assets/characters/poses/char/masters/likeness-review-02/char-likeness-v2.png`:
916x1716 canvas, alpha>=128 bounds [15,0,901,1673]. Appearance approval does not
approve generated poses. The old 252x472 runtime cutout remains in the running game.
Alignment_01 review uses a shared 1673-pixel standing reference at 64 logical pixels
for all seven native masters. Seated occupied height remains 51.6-53.4 logical
pixels; standing samples 63.3-64.1. Padded draft exports add blank canvas only.
Head/contact estimates, inferred ribbon/bow side consistency and final export
standards remain pending review. See [alignment_01](CHAR_ALIGNMENT_01_REVIEW.md).
