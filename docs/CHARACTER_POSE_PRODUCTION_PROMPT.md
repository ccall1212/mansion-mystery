# Reusable character pose production prompt

Copy the prompt below, fill the parameters and explicitly choose a task mode.
The original Char audit mode was **audit_and_plan**. A subsequent single-design likeness revision has been generated; v1 was rejected as too realistic and v2 is now user-approved for appearance. See [likeness refinement](CHARACTER_LIKENESS_REFINEMENT_PROMPT.md). Alignment_01 now has seven user-approved artwork samples; see [the review](CHAR_ALIGNMENT_01_REVIEW.md). No character generation or integration
was authorized by the initial documentation request. Read the persisted manifest
to resume; this prompt does not depend on chat history.

```text
Act as our character art director, pixel-art production artist and game integration
designer. Follow the established character pose production workflow in this project.

PARAMETERS
Character name: {CHARACTER_NAME}
Identity ID: {IDENTITY_ID}
Roster/review number: {REVIEW_NUMBER}
Character folder slug: {CHARACTER_SLUG}
Task mode: {audit_and_plan | generate_review_batch | export_and_validate | integrate_approved}
Requested batch and exact pose/variant IDs: {BATCH_AND_IDS}
Approved/selected identity references: {REFERENCE_PATHS_AND_SELECTION_STATUS}
Personality and signature gestures: {USER_ASSIGNMENTS_OR_UNASSIGNED}
Required furniture interactions: {CURRENT_ENABLED_CONTACTS_OR_EXPLICIT_SUBSET}
Emotional/mystery-event scope: {APPROVED_CASE_SCOPE_OR_PENDING}
Presentation target: {CURRENT_SETTINGS_OR_RECORDED_APPROVED_CHANGE}
Output folder: assets/characters/poses/{CHARACTER_SLUG}/
Manifest: assets/characters/poses/{CHARACTER_SLUG}/production-manifest.json

Read AGENTS.md, README.md, docs/GAME_DESIGN_BRAINSTORM.md, docs/GAME_DESIGN.md,
docs/CHARACTER_ART_GUIDE.md, docs/CHARACTER_MEASUREMENT_STANDARD.md,
docs/CHARACTER_RENDERING.md, docs/FURNITURE_IDS.md, docs/CHARACTER_POSE_AUDIT.md,
docs/CHARACTER_REACTION_MATRIX.md, docs/CHARACTER_POSE_PRODUCTION_WORKFLOW.md, docs/IMAGE_ASSET_WORKFLOW.md,
docs/CHARACTER_DIRECTIONAL_PIPELINE_PLAN.md, the current cast catalog, directional index
and this character's existing manifest before doing work.
Inspect the actual engine and furniture/room data; distinguish implemented behavior,
confirmed future intent, optional ideas, selected looks and user-approved artifacts.

Run the existing pose audit and inspect every relevant enabled room/furniture/anchor,
including shared backgrounds. Preserve canonical IDs and actor facing separately
from object orientation. Include props/handedness, contact landmarks, clearance,
occupancy, masks and bed axis/headboard alignment. Disabled contacts require no art.
Record catalog-only orientations as expansion needs, not mandatory current poses.

Inventory existing outputs and source hashes. Resume missing work; preserve approved
assets, necessary original masters, stable IDs, selected reusable prompts, exclusions and approvals. Do not retain every experiment. Do not
overwrite a manifest or regenerate a completed pose. Stop dependent work if a source
or requirement conflict needs a user decision, while progressing independent audit work.

Use Char's workflow and deliverable types as the process template. Preserve this
character's own face, age, anatomy, clothing, height intent and personality. Women
use Char/Sarah Jo and men Kwinn/Chris as canonical rendering references, not copied
identities or clothes. Do not assign fictional guilt, relationships or traits from
appearance. Do not inherit every Char-specific pose. Walking is handled separately.

In audit_and_plan mode, generate no art and make no runtime/design changes. Produce
the character-specific required-pose/applicability matrix, source-linked manifest,
batch proposal and unresolved decisions. Keep actual generation_runs and approval
logs empty unless previous real production records exist.

In generate_review_batch mode, produce only the explicitly requested batch. Inspect
the available image-generation skill and use its supported tools. Record exact
substituted prompts, reference order/hashes, tool/settings, returned outputs and
revisions. Preserve approved/necessary sources; keep experiments temporary under docs/IMAGE_ASSET_WORKFLOW.md. Label generated artwork as draft. Supply visible
comparison sheets and gameplay-size context for user review before finalization.

In export_and_validate mode, use only reviewed sources and documented technical
operations. Record dimensions, alpha bounds, crop/trim offsets, padding, common
standing reference scale and pose-specific feet/seat/knees/pelvis landmarks. Do not
normalize a seated/crouched/lying pose to standing height. Do not stretch or mirror
asymmetric artwork. Validate furniture fit and mask/prop requirements; report any
missing exporter, pose adapter or harness honestly rather than pretending it exists.

In integrate_approved mode, integrate only approved compatible artifacts within the
authorized scope. Use the shared renderer and explicit contacts; test the relevant
runtime behavior and native visual fit. No forced wrong-facing fallback. Do not
expand to unapproved personalities, case systems, animations or the whole cast.

Present actual review images and STOP for explicit user approval before finalization, integration or the next art batch. Record exact hashes, scope, evidence and retention decisions. Never infer approval from silence. Run tools/check_image_approval.py on the owning batch before promotion.

After each step update the manifest, retained prompt/revision records, artifacts,
fit evidence, approval status and production workflow. Keep existing/planned/draft/
approved/rejected/superseded/integrated states separate. Before claiming completion,
account for every produced deliverable and each required pose or reviewed exclusion.

Finish with completed/missing deliverables, visible review artifacts when produced,
actual validation results, unresolved decisions and the exact next batch. Ask for
approval only when concrete artwork is available to review. Never infer approval
from successful technical checks or an older conversation summary.
```

## Char parameters currently recorded

| Parameter | Value |
| --- | --- |
| Name / ID / number / slug | Char / `likeness-photo01` / `01` / `char` |
| Mode | `generate_review_batch`: alignment_01 artwork approved; next phase is audit_and_plan |
| First proposed batch | `alignment_01`: standing idle north/east/south/west; seated idle east/south/west |
| Batch specification | `assets/characters/poses/char/batches/alignment_01.json`, executed; artwork approved, integration pending |
| Identity | Approved `assets/characters/poses/char/masters/likeness-review-02/char-likeness-v2.png`; older runtime cutout preserved |
| Appearance status | Char v2 and seven alignment_01 artwork samples approved; runtime fit and final cast remain unapproved |
| Personality / guilt | Unassigned / case-dependent unassigned |
| Presentation | Current 480×360 logical canvas, 64-pixel adult stature; user requested a larger-presentation discussion before exports are locked |
| Manifest | `assets/characters/poses/char/production-manifest.json` |
| Art produced by this workflow | Two likeness-review drafts: v1 rejected; v2 approved for appearance. Seven directional alignment artwork samples approved |

Future-character parameter values must come from that character's catalog and user
decisions. Do not just change the displayed name while retaining Char's identity,
reference hashes, silhouette, dimensions, ratio or signature gestures.

Char-specific execution prompt: [first seven poses](CHAR_POSE_GENERATION_PROMPT.md). Providing the prompt did not execute generation.

Current Char alignment records must be resumed rather than regenerated. Review/export reproduction uses `tools/render_char_alignment_review.gd` and `tools/validate_char_alignment.py`; preserve the existing masters and use approved v2 for any authorized revisions.

Directional continuation: preserve approved image bytes; move only within explicitly authorized organization scope and update references/hashes.
Use the directional index as an authoring reference, not an implemented loader.
Exports use `exports/<facing>/<character_slug>_<pose_id>_<variant_id>.png`; lying assets
retain axis/head alignment separately. Avoid personality folders and automatic
four-way expression duplication. Full-sprite expression variants are the initial
proposal; overlays need a separately implemented registered-head rendering path.
Char's seven samples must not be regenerated or re-exported by a resume task.

Open and directly link each relevant new/updated index.html for user review; do not silently leave a gallery on disk. All directional PNG names include character, posture/action, canonical direction and variant.
