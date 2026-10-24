# Char — approved-design pose production prompt

Current status (2026-10-23): all seven alignment_01 artwork samples are user-approved. Original review images/labels and executed prompts are preserved; contact calibration, masks and runtime integration remain pending. See [next-phase plan](CHARACTER_DIRECTIONAL_PIPELINE_PLAN.md).

**Executed:** the seven-sample batch is now awaiting review; see [the review](CHAR_ALIGNMENT_01_REVIEW.md). Preserve existing outputs and do not regenerate them just by reopening this saved prompt.

The user approved likeness v2 on 2026-10-23: “I approve the new look.” This approves
her appearance, not ungenerated poses, furniture contacts or the whole cast.
Copy the prompt below when ready to authorize the first seven-pose batch.

```text
Create Char's first seven character poses for our mansion mystery game.

Read AGENTS.md, the current character measurement/rendering standard, full pose
audit, furniture metadata and CHARACTER_POSE_PRODUCTION_WORKFLOW.md. Resume the
existing Char manifest; preserve all previous masters, revisions and approvals.

APPROVED CHARACTER REFERENCE
Use assets/characters/poses/char/masters/likeness-review-02/char-likeness-v2.png
as the primary identity, style, costume and proportion reference for EVERY pose.
Her identity is likeness-photo01, cast #01, Char. Her new look is user-approved.
Do not use the rejected realistic v1 face or reinterpret the photos independently.

LOCKED APPEARANCE
Preserve her recognizable anime/cartoon face, large expressive brown eyes, small
simplified nose, friendly stylized smile, soft skin shading, brown wavy hair,
cream headband/ribbon, adult stylized proportions and build. Keep the cream lace
high-collar blouse/cuffs, cameo, puffed sleeves, burgundy sash/side bow, teal-green
long skirt, modest jewelry and brown shoes. Match the approved detailed pixel
clusters, warm-dark outlines, lighting and fabric folds. Do not drift toward
portrait realism, shrink the eyes, exaggerate the forehead, stretch her body or
make her a child. Preserve asymmetries; no automatic mirroring.

FIRST BATCH ONLY — SEPARATE TRANSPARENT PNGS
1. standing_idle_north — facing away/up, showing the back of her hair and outfit.
2. standing_idle_east — facing screen right.
3. standing_idle_south — facing toward the player, consistent with the approved
   front/three-quarter presentation.
4. standing_idle_west — facing screen left.
5. seated_idle_east — seated facing right; fit target:
   g_kitchen::kitchen_lower_chair_01::seat.
6. seated_idle_south — seated facing the player; fit target:
   g_library::library_armchair_01::seat.
7. seated_idle_west — seated facing left; fit target:
   g_foyer::foyer_armchair_01::seat.

Consult assets/characters/poses/char/batches/alignment_01.json and the actual
furniture rectangles/anchors. Character facing is separate from furniture
orientation. Keep seated hips, knees, feet and skirt naturally aligned to the seat.
Record seat and floor-foot landmarks even where fabric obscures the feet.

Generate the character alone, complete and uncropped, with comfortable transparent
margins. No chair, room, floor, shadow, text, labels or decorative panel in the PNG.
Keep limbs complete for later foreground occlusion. Use one coherent standing
reference scale and preserve aspect ratio. Seated poses must remain naturally
shorter; never resize their occupied height to equal a standing adult's height.
Use the shared rendering standard rather than custom per-chair/per-character scaling.

Read the available image-generation skill. Use the built-in image tool with the
approved image attached to each request; create one requested asset per call.
Save immutable masters, exact prompts, ordered input hashes, output records and
revisions in Char's existing production folder. Do not overwrite approved artwork.
If presentation/export dimensions remain undecided, retain full-resolution masters
and mark final exports pending; do not invent or silently change the game resolution.

Show a labeled equal-scale comparison sheet beside the approved design, plus
room-context previews for the three seated directions. Distinguish visual mockups
from real runtime fit tests. Record missing renderer/contact/mask support honestly;
do not claim integration or staging approval when it has not happened.

Update the manifest, batch records and workflow with everything actually produced.
Ask me to review these seven poses before finalizing them or creating the remaining
reading/writing/drinking, personality, shocked, accusation or murderer-reveal poses.
Do not create walking animation or expand to another character in this batch.
```
