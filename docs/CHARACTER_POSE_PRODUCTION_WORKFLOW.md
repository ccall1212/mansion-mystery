# Repeatable character pose production workflow

Approval and retention: follow [IMAGE_ASSET_WORKFLOW.md](IMAGE_ASSET_WORKFLOW.md), which supersedes older retain-all-experiments instructions. Explicit user approval is a separate required step before finalization/integration or the next art batch.

**Current production update:** Char alignment_01 has seven generated samples, seven pixel-preserving padded draft exports, an equal-scale comparison and three native-rendered seated mockups. The user approved all seven artwork samples on 2026-10-23; runtime contact calibration remains pending. See [the review](CHAR_ALIGNMENT_01_REVIEW.md). An opt-in F7 live placement test now uses shared contact rendering; production staging and chair masks remain pending.

Version 1, 2026-10-23. Char is the first **planned** full pose set. A subsequent
request authorized likeness refinement. V1 was rejected for realism and removed during cleanup; v2 restores the anime/cartoon face and is now user-approved. The first seven directional alignment samples now have user artwork approval; runtime integration remains unimplemented.

Use [the reusable prompt](CHARACTER_POSE_PRODUCTION_PROMPT.md). Keep approved production records and necessary reproducibility metadata in `assets/characters/poses/<character_slug>/production-manifest.json`.
Char's initialized manifest is `assets/characters/poses/char/production-manifest.json`.
Never overwrite the older historical `assets/characters/production.json`.

## Inputs and authority

Read AGENTS/README, the gameplay brainstorm, game design, current character art
guide, measurement/rendering standards, furniture guide, full pose audit, reaction
matrix, current cast catalog and this character's manifest. Inspect runtime code
when documents disagree. Record the conflict instead of silently selecting old rules.

Char's identity is `likeness-photo01`, roster/review number **01**. The selected
source is Party I in `review-v6/sources/selected-party-hm.png`, grid `[3,2,1]`,
panel crop `[0.2,0,0.68,0.99]`. Existing extracted reference:
`prototype/cast-01.png`, 252×472 RGBA. The alternate pink cardigan is the same
identity, not the intended current outfit. Keep cream high-collar blouse, teal-green
long skirt, burgundy sash, cream ribbon, brown waves and the selected soft face.
Primary women style references are Char/Sarah Jo; men are Kwinn/Chris. Preserve
identities rather than copying their clothes. See the measurement standard.

The initial audit authorized **planning only**. The later request authorized the
likeness revisions, not the seven-pose batch. Actual pose generation requires its
own instruction; final art requires explicit review approval. The subsequent seven-sample request supplied that generation authorization; this batch is now complete for review.
Selection of an identity reference is not approval of all new poses or the cast.

## Tools and commands that exist

| Tool | Actual capability / restriction |
| --- | --- |
| `tools/audit_character_poses.py` | Rebuilds exact contact/pose/orientation reports and initializes Char's missing manifest; preserves existing production records. For another identity, create its own manifest using the same schema and its actual measurements/selection, not Char's values |
| `tools/open_furniture_mapper.py` | Opens the existing Godot furniture editor; edits background-local tags and contacts, not character art |
| `tools/capture_tagged_rooms.gd` | Native captures of all rooms and review tags; no Char pose-fit/occlusion proof |
| `tools/build_furniture_review.py` | Older furniture-only room index and 42-ID Char subset; does not own the full audit/production manifest |
| `tools/prepare_prototype_characters.gd` | Historical seven-character cutout extraction, **writes several existing files**; do not run as a new pose exporter |
| Godot / `character_render.gd` | Existing shared standing renderer, foot pivots and nearest filtering; nonstanding pose adapter still missing |
| Session image-generation capability | Use only in an authorized art batch; read the available imagegen skill then and record exact inputs/tool parameters |
| Python / current local environment | JSON/CSV/asset inspection and validation; resolve machine tool paths from local configuration, never hardcode personal paths |

From project root:

```powershell
python tools/audit_character_poses.py
python tools/audit_character_poses.py --check
python tools/validate_character_pose_audit.py
python tools/open_furniture_mapper.py --background=res://assets/rooms/room-library.png
# Use the configured graphical Godot executable for rendered room review:
godot --path . --script tools/capture_tagged_rooms.gd -- --npc-seed=20261023
python tools/build_furniture_review.py
```

`godot` above denotes the configured executable, not a promise it is on PATH.
Use the existing MCP/owned-process workflow for gameplay acceptance and stop owned
processes. A headless driver cannot supply rendered art approval screenshots.

There is **no implemented universal pose exporter, reaction selector or production staging system**. A shared contact renderer and opt-in Char live fit harness now exist; see CHAR_LIVE_TEST.md. Record exact scripts,
arguments and limitations as these are authorized and built. Do not invent successful
commands or run an old all-cast extractor over new approved assets.

The validator compares the authoring audit to `test-results/tagged-room-coverage.json`
from the native Godot capture tool, checks CSV/JSON coverage, source/artifact hashes,
the proposed first-batch contacts and local documentation links. Regenerate native
evidence after editing room tags; a parity failure is not a reason to force acceptance.

## Stage 0 — inventory, applicability and resume

1. Load the manifest and audit current source hashes. If a source changes, log it
   for review; do not silently replace an approved source fingerprint.
2. Rebuild the audit. Resolve every concrete pose ID and semantic family into:
   required now, later, excluded with reason, or pending a decision. A detective-only
   capture pose need not become Char art. Furniture compatibility remains conditional.
3. Resume incomplete records; preserve approved PNGs, prompts, revisions and approvals.
   Keep old IDs stable. New IDs are additive; mark replacements `superseded` with links.
4. Keep personality, role, guilt and relationship assignments unassigned unless the
   user/game design establishes them. They are not physical-identity properties.

## Stage 1 — approve presentation and seven alignment samples

The user asked whether the game will remain very small. Record the chosen display
direction before final export standards: current logical 480×360/960×720 window,
larger window/fullscreen, or coordinated higher internal detail. Source character
masters already have more detail than a 64-pixel display shows. Increasing the
window alone does not add detail. No resolution change was implemented by this audit.

First proposed Char batch: `standing_idle_north/east/south/west`, then
`seated_idle_east/south/west`. Exact proposal and contact keys are recorded in
`assets/characters/poses/char/batches/alignment_01.json`. Review a labeled sheet and gameplay-size context.
Existing Char's three-quarter front is a likeness/style reference, not automatic
approval of all directional geometry. No mandatory seated-north current-room tag.

Approve head/body proportions, facing interpretation, scale reference, source
canvas/padding and contact landmarks before filling out the library. Store the
actual chosen numeric values; they remain null in the initial manifest.

## Stage 2 — generation jobs and revisions

Use small authorized batches. Under [the image approval and retention workflow](IMAGE_ASSET_WORKFLOW.md), keep experiments temporary. For jobs selected for retention, record each job **before** generation with a stable
job ID, requested pose/variant, exact prompt string, ordered reference paths and
SHA-256 hashes, tool name/version if exposed, actual settings, desired transparency
and expected output role. After completion, append returned paths, actual dimensions,
hashes and job/result IDs that the tool exposes. Do not invent a seed/model/job ID
when unavailable. Actual likeness jobs are now recorded in
`prompts/likeness-refinement-02.json`, including the retained exact prompt, reference hashes, settings and approved output. The realism rejection survives as a concise lesson; its rejected image and one-off prompt were removed.
Alignment_01 directional jobs are now executed and recorded under `prompts/alignment_01/`. All seven received user artwork approval on 2026-10-23. See the
[likeness prompt](CHARACTER_LIKENESS_REFINEMENT_PROMPT.md) for this preparatory step.

Planning template, **not an executed prompt**:

```text
Create {character_name}, identity {identity_id}, in pose {pose_id}, variant {variant_id}.
Use attached identity reference {identity_reference}; use {canonical_references} for
rendering quality only. Preserve {identity_and_costume_constraints}. Match the fixed
elevated three-quarter mansion view, expressive adult proportions, richly shaded
pixel clusters, soft appropriate facial shading and consistent light/outline treatment.
Actor faces {actor_facing}, independently of furniture orientation {furniture_id}.
Action: {action_description}. Body/hand/gaze targets: {targets}. Held props: {props}.
Contact landmark is {contact_kind}; preserve standing reference scale {reference_scale}.
Output a complete character only with genuine transparent background; no chair,
room, floor shadow, labels or decorative border. Keep occluded limbs complete.
Do not mirror asymmetric hair/ribbon/sash/props without approval. {batch_constraints}
```

Revision template, also **not executed**:

```text
Edit source artifact {source_artifact_id} for {character_name}/{pose_id}/{variant_id}.
Correct only these reviewed defects: {defects}. Preserve these approved features:
{locked_features}. Keep pose, identity, costume, hand ownership and contact scale
unchanged except for the requested corrections. Output to a new revision; preserve
the prior source. Reference the original identity and the reviewed previous version.
```

For prompts selected for retention, save the fully substituted text, not just a template pointer. Do not retain every unsuccessful correction. Separate
planned prompts from executed requests/results. For a reaction, specify accused/
culprit/witness role and knowledge, posture and expression. Do not let a generic
"shocked" request accidentally change identity or make standing art for a seated slot.

## Stage 3 — technical extraction, scale and contact records

Keep approved and necessary source masters immutable; discard classified rejected experiments under the shared retention policy. Record source sheet cells/crop rectangles,
trim offsets, alpha threshold, original/used bounds and every cleanup operation.
Preserve natural art and asymmetry. Do not redraw, recolor or synthesize a pose with
an undocumented extraction step. Genuine transparency must retain dark clothes and
small limb/ribbon gaps. There must be no unwanted outline fringe or baked floor shadow.

Folder proposal (create actual artwork folders when producing artifacts):

```text
assets/characters/poses/<slug>/
  production-manifest.json
  masters/<batch_id>/<job_id>.<revision>.png
  exports/<facing>/<character_slug>_<pose_id>_<variant_id>.png
  review/<batch_id>/comparison.png
  review/<batch_id>/<room_id>--<furniture_instance>--<anchor>.png
  prompts/<job_id>.json
```

`pose_id` retains `posture_action_facing` or the existing lying-axis/headboard form.
Keep expression/gesture/prop differences in `variant_id` and metadata, rather than
renaming canonical furniture IDs or creating aliases such as left/right/up/down.

PNG canvas size and transparent padding are not stature. Record one approved
source standing reference height per coherent source scale, a common scale factor
and per-pose landmarks. With existing Char's reference, 472 source pixels correspond
to 64 logical standing pixels (7.375 source pixels/logical pixel); a future different
master scale must be measured, not independently normalized by pose bounds.
Seated/kneeling/crouched/lying occupied height remains naturally shorter.

Future drawing contract:
`draw_rect_origin = world_contact + (source_region_origin - source_contact) * scale`.
Record contact in source-canvas coordinates, plus crop/trim transforms. Standing
uses feet; seated seat; kneeling knees; lying pelvis with head/heel alignment.
Also record floor-feet, shadow and depth-sort landmarks separately. A seat/pelvis
anchor is not automatically the collision, shadow or y-sort origin.

This adapter is a future shared rendering change. Do not compensate by resizing
Char differently for each chair, stretching anatomy, or enlarging a crouch to 64.

## Stage 4 — review and fit

For every batch supply identity/canonical comparison, equal-scale pose sheet,
transparent-edge/hand detail and actual gameplay-scale room contexts. The first
fit cases are foyer armchair west, library armchair south, kitchen **lower** chair east,
then desk/vanity, bed, shelves/window and hearth for subsequent relevant actions.
Some contacts are blocked: fix/approve approach and geometry before calling a fit ready.

Check identity, age, head proportions, soft face treatment, costume/ribbon/sash,
joint anatomy, handedness, grip, gaze, facing, pixel density, lighting, contact,
foot placement, long-skirt volume, scale, occupancy and foreground overlap. Lying
must match axis/headboard. Test asymmetry before any mirroring. Review expressions
at the chosen presentation size, including their readability from rear-facing views.

Record each screenshot artifact's exact character/pose/variant, room, furniture
orientation/instance/anchor, camera/scale, source hashes and findings. A room-tag
screenshot without Char is not a pose-fit screenshot. A headless pass cannot approve art.

Ask for artwork approval only with visible, labeled output. Record which exact
revision the user approved and any conditions. Approval states: `not_requested`,
`pending`, `approved`, `changes_requested`, `rejected`, `superseded`. Keep `planned`,
`generated_draft`, `exported_draft`, `validated`, `integrated` as distinct work states.
Passing technical checks does not imply user approval or completed integration.

## Stage 5 — integrate only approved supported combinations

Bind assets to canonical pose IDs and approved variant metadata. Verify source
landmarks and shared scale, props/grips, runtime contact transforms, collision/shadow/
depth landmarks, masks, partner facing, group capacity and disabled anchors.
Missing compatible art must cause a documented supported fallback or held event,
not wrong orientation, fake seating or an unapproved mirror. Debug/history records
must identify source asset and case context for a reported mismatch.

Use focused engine checks for changed behavior, native fit screenshots and the
owned-window gameplay smoke when integration occurs. Record actual command/results,
not historical counts. Walking remains an external dependency. Persist reservations,
activities and reactions only after the relevant future systems/save schema exist.

## Completion and future-session handoff

Char is complete only when all in-scope requirements have an approved artifact or
an explicit reviewed exclusion; outputs link to exact sources/prompts/revisions,
landmarks, furniture fit evidence and runtime bindings; required checks pass; and
the deliverable inventory accounts for every created file. Full future branches
still undecided must remain pending, not silently count as implemented.

After every batch update manifest, actual prompts, revision history, approval log,
source fingerprints, fit screenshots, this workflow's new commands/lessons and
the reusable prompt. Add lessons from real corrections; do not fabricate failures
or claim unperformed steps. Current known lessons: never normalize a seated body
to standing height; verify limb/hand ownership and asymmetry visually; keep selected
looks distinct from historical drafts; show local review sheets visibly before
asking for approval. The rejected detective walking process is not Char production.

Initial unresolved/manual steps: display-resolution decision, numeric pose canvas/
padding and head landmarks, batch authorization, image-generation requests, export
tooling, nonstanding renderer, contact/navigation calibration, masks, pose/event
selection, personality assignments, group transitions and runtime fit validation.

## Recorded likeness correction and tool lesson

The first photographic likeness pass produced a face the user rejected as too
realistic. The corrected prompt prioritizes original Char and Sarah Jo as strong
anime/cartoon references, with photos used only for subtle brow/hair/smile cues.
Preserve large expressive eyes, simplified nose/mouth and soft illustrated skin.
V1 is rejected; the user approved v2 appearance on 2026-10-23. The approved v2 output preserves native alpha; no post-generation image modification occurred. The rejected v1 image and prompt were removed during cleanup. Tool preflight disclosed a five-input limit; v2 uses
two illustrated references and three photos. All four photos remain preserved.

## Char design approval

The user approved likeness v2 ("I approve the new look") on 2026-10-23. Use the exact v2 master as the future pose reference; do not repeat photographic likeness refinement. The [seven-pose prompt](CHAR_POSE_GENERATION_PROMPT.md) is ready. No directional poses were generated by the prompt-writing task.

## Executed alignment_01 process and reproducible deliverables

The user authorized exactly seven separate transparent static samples, each using
the approved likeness-v2 master. Four standing calls and three seated calls used
the built-in image tool, one asset per request. Seated calls also used the room
image only for the specified chair geometry. No photos or realistic v1 face were
used. Exact per-pose prompts, ordered input hashes, output names/hashes, native
canvas/alpha measurements and provisional seat/foot/head/skirt metadata are in
`assets/characters/poses/char/prompts/alignment_01/`. Masters are immutable.

`tools/render_char_alignment_review.gd` is the implemented **batch-specific** review
exporter. It adds blank 64-pixel padding without altering source pixels; the common
review canvas is 1045x1844. It does not trim, resample, recolor, redraw or mirror
masters. Two native standing outputs are one pixel wider than the others; the
common canvas accommodates them unchanged. This is not yet a universal exporter.

Every pose uses 64/1673 source-to-logical scale, using the approved design's opaque
standing height. Standing samples occupy about 63.3-64.1 logical pixels; seated
samples about 51.6-53.4. The comparison uses one common scale too. No individual
normalization or chair-specific enlargement is used. Landmarks remain manual visual
estimates; source + [64,64] gives the padded export contact.

The native Compatibility renderer creates five review PNGs: comparison, three
full-room/contact mockups, and a three-chair closeup sheet. Contexts instantiate
the actual room renderer, retain room props, hide existing actors/HUD and add a
review-only pose overlay at the exact seat contact. Baked chair arms have no masks;
fit, navigation, collision, occupancy and pose selection are not approved or
integrated. Do not present these images as gameplay validation.

Run the configured graphical Godot executable with:
`--path . --script tools/render_char_alignment_review.gd -- --npc-seed=20261023`,
then `python tools/validate_char_alignment.py`. The validator checks native log,
seven input/source hashes, source-pixel recovery, alpha margins, landmark offsets,
common scale, shorter seated extents, exact chair IDs and output dimensions. It
cannot approve likeness, inferred side placement or actual furniture fit.

Lessons from this batch: generated standing padding can be too tight despite the
prompt, so preserve the master and add canvas-only draft padding; generated width
may differ by one pixel; anatomical right-side bow/ribbon interpretation must be
reviewed across independent views; common-scale game previews lose fine face detail
at the current 480x360 viewport. Final display/export standards are still undecided.
All prompts, masters, draft exports, review images and validation tools are tracked
in the manifest. The user subsequently approved all seven artwork samples; no additional character/actions were produced.

## Next-phase directional planning and approval lock

The user approved all seven alignment_01 artwork samples on 2026-10-23 and explicitly
required that they remain untouched. The manifest, batch and per-job records now
record that approval; PNG filenames, hashes and pixels remain unchanged. Final
runtime bindings and contact calibration remain pending.

Follow [the directional pipeline plan](CHARACTER_DIRECTIONAL_PIPELINE_PLAN.md) and
`assets/characters/poses/char/directional-index.json`. The user subsequently requested directional folders: exports now live under `exports/<facing>/<character_slug>_<pose_id>_<variant_id>.png`, with approvals/hashes preserved and all references updated. Do not run the alignment review exporter again: it writes approved export
paths. A later technical export needs a new revision path. Current review sheets
retain their original draft labels as historical evidence; approval lives in metadata.
Next-phase planning generated no art, expressions, masks or runtime changes.

Every directional image filename must include character slug, pose ID (including direction), and variant ID, even neutral. See CHARACTER_DIRECTIONAL_PIPELINE_PLAN.md for the actual tree. Show and link every index.html associated with changed work, project-wide.

## Opt-in Char live placement test — 2026-10-23

F7 starts/finds Char, F8 randomizes her room and approved pose, F10 restores normal
mode. One identity-keyed roster replacement removes the old Char assignment; room
loads remove old actor nodes before spawning current occupants. Shared contact
rendering uses common 64/1673 scale and floor feet independently of chair seat.
All seven approved images remain unchanged. Seated masks/clearance/contact fit are
provisional and require visual review; this is not general NPC scheduling/staging.
Native checks cover 126 room visits, 100 rerolls, all seven poses, contact alignment,
save/load protection and roster restoration. The real owned-window smoke also
captured all seven poses and verified unique live assignments. See CHAR_LIVE_TEST.md
and test-results/char-live-test/index.html. No art approval or image hashes changed.

## HD/readability presentation preview — 2026-10-23

User reported Char and the overall game were too small. The internal viewport is
now 960×720, with up to a 1280×960 window, monitor-fit sizing and F11 fullscreen.
Shared adult stature is 80 instead of 64; identity ratios/proportions are preserved.
World/physics/furniture coordinates stay 480×360. The presentation adapter scales
camera/HUD/inspection UI into HD; detail zoom is 1.5× and Z provides full overview.
F7/F8 now focus Char in detail mode instead of forcing overview. Her source masters,
exports, approval hashes and original alignment metadata remain unchanged; 64 in
those source-review records is historical. Runtime source scale is 80/1673.

The live owned-window smoke captured all seven poses at 1280×960 and verified both
Z modes, F11 fullscreen on/off, and one Char assignment. Native checks verify HD
HUD/inspection scaling and preserve contact transforms/unique identity across room
visits/rerolls. Character/foyer/evidence, fixed-mansion, furniture and environment
checks pass. [Presentation comparison](../test-results/presentation-review/index.html)
uses two retained previous-runtime captures and current actual captures; source art
is never resampled. Presentation and chair fit still await user visual review.
Current room backgrounds retain their existing authored pixel detail; the change
increases display/readability, not the detail contained in those background files.
