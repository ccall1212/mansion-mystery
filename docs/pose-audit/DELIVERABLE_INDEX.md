# Pose planning deliverables and reproducibility

This index records the planning outputs actually created or updated for Char.
At the initial audit no artwork existed. A later likeness revision produced two design drafts: v1 rejected for realism, v2 awaiting review. No directional pose sheet, furniture-fit screenshot or runtime pose binding exists. Char's production manifest records file hashes for these planning
artifacts; it excludes its own hash to avoid a self-reference.

| Deliverable | Purpose | Recreate / maintain |
| --- | --- | --- |
| [Full audit](../CHARACTER_POSE_AUDIT.md) | Scope, implementation facts, gaps, production order and decisions | Authored; reconcile with source documents and actual code |
| [Reaction matrix](../CHARACTER_REACTION_MATRIX.md) | Personality candidates, emotions, accusation/reveal situations and transitions | Authored; preserve role/knowledge distinctions |
| [Measurement standard](../CHARACTER_MEASUREMENT_STANDARD.md) | Canonical references, current 64-pixel scale and missing pose measurements | Authored; update after actual reviewed measurements |
| [Production workflow](../CHARACTER_POSE_PRODUCTION_WORKFLOW.md) | Inputs, real tools, prompt templates, exports, landmarks, review and completion | Update continuously with actual production records |
| [Reusable prompt](../CHARACTER_POSE_PRODUCTION_PROMPT.md) | Parameterized future-character handoff | Use selected task mode and that character's real references |
| [Concrete pose matrix](MASTER_POSE_MATRIX.md) | All 45 currently identified concrete requirements | `python tools/audit_character_poses.py` |
| [Exact room mapping](FURNITURE_POSE_MAPPING.md) | Enabled and disabled contacts in every room | Same generator |
| [Mapping CSV](furniture-contact-map.csv) / [JSON](furniture-contact-map.json) | Full contact geometry, pose IDs, props, clearance and mask constraints | Same generator |
| [Orientation coverage](orientation-coverage.csv) | All 84 IDs; current use versus future expansion | Same generator |
| [Semantic brief](../../assets/characters/poses/requirements-brief.json) | Source-linked action/reaction family definitions | Authored source for the audit |
| [Machine-readable inventory](../../assets/characters/poses/pose-requirements.json) | Concrete requirements, families, source hashes and coverage | Audit generator |
| [Char manifest](../../assets/characters/poses/char/production-manifest.json) | Identity, requirements, outputs/prompts/approvals and planning artifact hashes | Initialized once; append real production history; never regenerate over approvals |
| [Char first batch](../../assets/characters/poses/char/batches/alignment_01.json) | Seven proposed jobs, exact fit contacts and unexecuted job fields | Update only with actual authorization and execution records |
| [Earlier Char furniture subset](../CHAR_POSE_PLAN.md) | Original 42-ID subset with links to full audit | `tools/build_furniture_review.py`; not the full production authority |
| [Audit tool](../../tools/audit_character_poses.py) | Read-only game inspection and derived planning reports | `--check` verifies reproducibility without writing |
| [Validator](../../tools/validate_character_pose_audit.py) | Parity with native capture evidence, cross-file and artifact checks | Run after generating audit; refresh native room report if tags change |

Expected future artwork/export/review/fit deliverables are described in the workflow
and manifest, but are not listed as produced artifacts. A future production run
must append exact prompts, reference hashes, master/export PNGs, revision records,
landmark metadata, review sheets, fit contexts, approvals and integration evidence.
If a step has not happened, its status stays planned or pending.

## Subsequent likeness review artifacts

[Reusable likeness prompt](../CHARACTER_LIKENESS_REFINEMENT_PROMPT.md), exact job
prompts/records under `assets/characters/poses/char/prompts/`, and the two immutable
masters under `masters/likeness-review-01/` and `likeness-review-02/` are now recorded
in Char's manifest. V1 is rejected for realism; v2 awaits review. Current runtime
art and all directional pose jobs remain unchanged.

## Executed Char alignment_01

[Review seven poses](../CHAR_ALIGNMENT_01_REVIEW.md). Seven immutable native PNGs,
seven padded draft exports, exact per-pose request records/landmarks, the comparison,
three native room mockups and a closeup sheet now exist. The renderer tool is
`tools/render_char_alignment_review.gd`; the validator is `tools/validate_char_alignment.py`.
All are in Char's artifact inventory. These poses await review; no runtime pose
integration, masks or additional action batches were produced.

## Directional continuation

The seven alignment_01 samples now have user artwork approval. See
[directional pipeline planning](../CHARACTER_DIRECTIONAL_PIPELINE_PLAN.md) and
`assets/characters/poses/char/directional-index.json` for the authoring-only index.
Approved export bytes are now in user-requested directional folders; the Char root index exposes them. No new expression art or runtime selector has been implemented.
