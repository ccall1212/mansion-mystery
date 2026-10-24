# Image approval and retention workflow

This is the shared policy for character, animation, room, furniture and object art.
It supersedes older instructions to save every prompt, rendition or correction.
Specialist art/measurement documents still define appearance and technical fit.

## Required approval checkpoint

1. **Authorize and prepare.** Inspect the current assets, manifest and relevant
   standards. Generation authorization is separate from approval of its result.
   Agree on the requested batch; use scratch space for experiments, not permanent
   production folders. Do not touch an already approved image.
2. **Generate and check a draft.** Validate transparency, dimensions, identity,
   anatomy, direction, shared scale and applicable contact/occlusion. Distinguish
   technical checks from visual approval. Document untested furniture fit explicitly.
3. **Present and stop for review.** Show actual labeled images or a comparison plus
   context where relevant. Identify the exact candidate filenames/revisions and
   any limitations. Ask the user to approve, request changes or reject the batch.
   A missing answer, successful test, generation request or approved reference is
   not approval. Do not finalize, integrate or expand into the next art batch while
   this decision is pending. Independent planning/technical work can continue.
   Whenever changed work has an index.html, open it and give the user a direct
   clickable link. Apply this to all project areas, including test/review tools,
   not only image generation. Check the rendered page and its local asset links.
4. **Record the decision.** In the existing batch/asset manifest record status,
   reviewed file paths and SHA-256 hashes, decision date, explicit user evidence,
   scope and conditions. Support partial approval per file; keep the batch pending
   until every requested candidate is decided or explicitly excluded. Record art
   approval separately from technical fit, runtime integration and cast completion.
   Existing documented explicit approvals remain valid; do not ask again.
5. **Choose retention deliberately.** Keep the approved result, required masters,
   application metadata, alignment/masks and important reusable instructions.
   Record whether an exact prompt is explicitly designated for retention or is
   necessary to reproduce the production asset. Approval of art alone does not
   retain all its prompts, corrections or previews. Keep review/context evidence
   only while it supports approval, unresolved fit or another stated development
   need. Retention is metadata, not a requirement for another user confirmation.
6. **Promote and clean.** Only approved supported files may be finalized/integrated
   within authorized implementation scope. Verify hashes again. Use a new revision
   path for changes; approval of a previous hash never transfers automatically.
   Remove rejected/superseded experiments and their redundant prompts after checking
   dependencies. Preserve a concise decision/lesson, not a permanent history archive.
   Leave genuinely ambiguous items in place and list them for review.

An approval record should use the existing owning manifest, not a competing catalog.
New batches can add an `image_approval` object containing `status`, `evidence`
(`date`, `source`, `quote`), `scope`, `files` (`path`, `sha256`) and a `retention`
decision. A batch can be approved only if its listed candidates are all approved;
split the approved subset into a scoped record for partial decisions.

`python tools/check_image_approval.py <batch-or-manifest.json>` checks an explicit
`image_approval` record and its current file hashes. This is a preflight tool, not
an automatic interpretation of user intent or a runtime feature. A missing record,
pending decision or changed file fails. Future exporters/integration tasks must run
the preflight before promotion; runtime furniture validation is still separate.

## Existing assets and cleanup decisions

Char's likeness-v2 and seven alignment_01 samples have explicit artwork approval.
Keep their source masters, unchanged padded exports and per-pose production records:
the user specifically requested reproducible prompts/metadata for this workflow.
Keep the current chair context reviews until contact calibration/masks are resolved.
The rejected realistic v1 is unnecessary; retain its rejection lesson in the manifest.

The finalized detective L1–L4 remain four separate untouched source images, with
the current playback order and preview. The older `detective-walk-v1` folder still
backs the running animation: retain its runtime sheet, manifest and necessary
extraction/cleanup inputs until that dependency is retired. Rejected generation
attempts and unused duplicate/older previews can be removed independently.

Room/background masters, alternate layouts, evidence art and original references
remain useful to the current game or documented plans. Similarity is not proof of
duplication. Older cast selections mix approved looks, alternate identity views
and pending drafts; retain uncertain items until they are specifically classified.
Do not delete a source referenced by a current cast entry simply because its folder
has an older version number. Preserve GAME_DESIGN_BRAINSTORM and specialist future
requirements; recording an idea does not make it implemented.

## Cleanup result and review items — 2026-10-23

Removed 28 files (19,917,688 bytes): rejected gait attempts and their import sidecars,
an obsolete one-off extraction helper, redundant detective source/renamed-frame
copies, superseded L4/preview revisions, rejected realistic Char v1 and its prompts,
redundant combined/duplicate Char prompt text, and two rejected environment masters.
Necessary records now reference retained canonical files; no experiment archive was made.
Retained 315 image files across assets/reference with identical pre-cleanup hashes.
All approved Char PNGs and separate finalized L1–L4 are unchanged.

Existing folder structure remains: `assets/characters/poses/char` for approved Char
sources/exports and alignment metadata; `detective-walk-final/left/sources` for L1–L4;
`prototype` and the required `detective-walk-v1` sheet for current runtime art;
`assets/rooms`, `assets/objects`, `assets/furniture` and `reference` keep their roles.
Reusable prompts stay with their asset family and specialist documentation. No
asset folder migration or game appearance change was needed.

Retained items needing review before further deletion:

- `assets/characters/review-v8/masters/jessica-cartoon-v8.png` and
  `john-cartoon-v8.png`: the catalog still says awaiting review; no approval inferred.
- Older `review-v2`–`review-v7` cast variants and their associated instructions:
  current entries retain alternate looks/source crops. Selection, supersession and
  retention are mixed, so version age alone cannot justify deleting the group.
- The identical v7/v8 same-person review boards are still referenced by their
  separate galleries/build checks. Consolidate those galleries together before
  dropping either required path.

Original references, selected room/source masters, object/evidence variants,
measurement and furniture standards, reusable pose instructions and all documented
future gameplay requirements were retained. Artifact/dependency records were
updated instead of leaving links to removed files.
