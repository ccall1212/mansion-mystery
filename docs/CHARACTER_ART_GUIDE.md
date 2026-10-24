# Character art guide

Approval and retention: follow [IMAGE_ASSET_WORKFLOW.md](IMAGE_ASSET_WORKFLOW.md), which supersedes older retain-all-experiments instructions. Explicit user approval is a separate required step before finalization/integration or the next art batch.

Current pose-production authority: read [the measurement standard](CHARACTER_MEASUREMENT_STANDARD.md),
[full pose audit](CHARACTER_POSE_AUDIT.md) and
[repeatable workflow](CHARACTER_POSE_PRODUCTION_WORKFLOW.md). Canonical women are
Char/Sarah Jo; men Kwinn/Chris. Current shared standing stature is 64 logical pixels.
The original investigator-first/48-pixel benchmark and numbered experimental poses
below are historical, not instructions to remake the active roster. Nonstanding
poses require a common standing reference and explicit contact landmarks, not
normalization of each occupied pose to 64 pixels. No new art is authorized by this audit.

Current review: assets/characters/review-v8/. The active roster is 01-15, 20-21;
16-19 are removed from the cast and preserved only as historical art. Jessica (20)
and John (21) use cartoon face revisions matching the established party designs.
Sarah Jo's short-hair look is approved and unchanged. Eleanor is the proposed
opening maid; costume and runtime role changes remain pending. The production
steps and test characters below record the earlier workflow, not the active roster.

Production brief: 2026-10-23. Primary reference is the existing investigator's front
idle frame, column 1 / row 0 (zero based) in assets/foyer/investigator-sheet.png.
Left-facing row 1 supplies the profile reference. Eleanor's original sheet is a
secondary costume reference, not the proportion standard. Originals are preserved.

## Measured baseline and discrepancy

At alpha >= 128, the investigator canonical frame occupies source rectangle
(398,41)-(528,292): 130 x 251 pixels. His hair-crown-to-chin interval is approximately
90 pixels by visual landmark inspection, or 36% of height (about 2.8 heads tall).
Eleanor's original front occupies (1110,131)-(1423,851): 313 x 720. Her crown-to-chin
interval is approximately 155 pixels, or 22% (about 4.6 heads tall). Hair and collar
boundaries make these artistic measurements approximate, not segmentation ground truth.

The originals are detailed enlarged RGBA artwork, not native 48-pixel sprite drawings:
the investigator sheet is 1254 x 1254 with over 15,000 opaque-color variants in the
canonical frame; Eleanor is 1774 x 887 with over 35,000 in her front pose. Existing
nearest-sampled gameplay renders them about 48 logical pixels tall. Repeating their
source resolution alone would not guarantee matching pixel density or proportions.

## Shared proportions

Review update: the user rejected the first likeness group's very compressed bodies
while liking its faces and clothing, and accepted the taller party-group treatment.
The earlier three-head prescription below describes the initial benchmark; it is
not a requirement to keep the rejected anatomy. Current first-group revisions use
roughly 4–4.3 heads standing, longer adult torsos and legs, and expressive heads.
Keep the approved party silhouettes as reference. Final common game scale and the
full cast's proportions remain pending review; do not stretch images to fake anatomy.

- Initial benchmark adult standing equivalent: 48 logical pixels, roughly 3 head lengths (acceptable
  artistic range 2.8–3.3). Crown-to-chin target 15–17 logical pixels. This deliberately
  preserved the investigator's large head. The latest likeness review supersedes
  enforcing this body ratio for all new adults; preserve Eleanor's face and costume.
- Shoulders about 1.1–1.4 head widths; compact neck 1–2 pixels; readable hands about
  3 pixels; boots substantial and clearly separate. Body build varies, anatomy language does not.
- Elderly people may stoop, have fuller hair or narrower shoulders but retain the same
  underlying head scale. Children use shorter bodies and slightly smaller heads, not
  an adult body squeezed onto a smaller canvas.
- Kneeling, crouching and sitting shorten the occupied pose height. They must not be
  enlarged to equal a standing adult's full height. Export scale is derived from the
  recorded crown-to-chin landmark using the same logical head-size rule.
- Do not independently stretch a head or body. Reject/regenerate wrong anatomy. All
  final sprites preserve their aspect ratio; pose scale and pivot are recorded in manifest.json.

## Rendering

Use the protagonist's softly shaded but visibly clustered vintage adventure/RPG
style: crisp deliberate edges, dark warm colored outlines, small grouped highlights,
upper-left neutral key light, no glossy 3D finish or photorealistic skin. Facial eyes
and brow carry expression at gameplay scale. Hair uses a few readable clumps, not
individual photorealistic strands. Folds follow joints and cloth tension. Hands and
feet remain readable against clothing; accessories must have natural grips.

User review refinement: retain Eleanor's original face and whole costume design,
but rebuild her body proportions around the larger head standard. Preserve gentle,
flattering soft skin shading for women rather than hardening their faces to match
male characters. Preserve individual ages and features. Personal photographs now
guide additional adult likeness drafts; see CHARACTER_LIKENESS_REVIEW.md for the
source-position mapping, excluded blurred faces and explicit duplicate identity.

Face refinement feedback: keep expressive head scale without exaggerating a tall
forehead or receding scalp. First-group C in blue and first-group E require a more
flattering, balanced face treatment. E is the user: use his newer photograph for a
fuller brown beard and connected moustache across all poses, retaining his recognizable
face and natural bald/receding head. Do not confuse this C with party C, who matches
first-group D. Canonical alias mappings live in assets/characters/likeness-identities.json.

First-group F / party K needs a scruffy goatee with short facial scruff around the
cheeks and jaw in both existing outfit looks. The naming checkpoint and combined
cast sheets are in CAST_NAME_REVIEW.md / review-v5. The user will give names first;
defer additional pose generation until that step is complete.

Latest appearance notes: Sarah Jo (13) needs very short cropped dark brown hair,
visible ears and short nape, preserving her soft face and navy dress. Avoid a bob,
long locks or accidentally elongating her body during the hairstyle edit. The new
left woman (20) is about five feet tall: short adult anatomy, not child/chibi anatomy.
Review renders show her at 0.85 of the comparison standing height, beside 21; final
world-space calibration is still pending. The right man (21) retains rectangular
glasses and a long dark goatee. Correct the new reference photo's blue event lighting
to natural skin tones. Names 01-13 are saved; 14-21 remain unassigned for now.

Maintain one enlarged-pixel treatment in generated masters and consistent nearest
sampling in exports. No fuzzy external glow, noisy dithering, vector outlines or
black background. Source translucency is trimmed against alpha >= 128. Final logical
pixel exports use clean alpha, so transparent fringes do not create floating feet.

## Perspective, costume and layers

Fixed elevated three-quarter 2D view, matching the foyer. Show a little crown and
shoulder tops; soles contact a consistent ground plane. No isometric diamond or
dramatic camera perspective. Shadows belong to scene rendering, not the character PNG.

Fictional late-Victorian/Edwardian-inspired manor: waistcoats, high collars, practical
servant uniforms, long skirts, wool coats, leather boots, brass details, modest jewelry.
Vary silhouette, occupation, personality, age and stance as well as complexion.
Kneeling, reading, hiding and reaching require bent joints and a clear gaze target.

Beds, chairs, cabinets and doorframes are separate scene props. Hiders/peekers are
complete posed characters, occluded by a foreground layer in the context scene.
Books, spectacles, magnifiers and carried lanterns can be integral hand-held props.
Do not generate a room background for any character.

## Production and approval gate

1. Extract primary/secondary frames without changing the original sheets.
2. Generate and inspect Jonas, the kneeling investigator, as the first difficult test.
3. Compare his head scale, rendering and floor contact with the references; record the
   comparison in CHARACTER_ASSET_QA.md. The user subsequently requested a review
   before the cast's look is finalized. The first four remain drafts. The user has
   now requested a larger-head Eleanor revision preserving her face and introduced
   personal likeness references. Generate review candidates for that refinement;
   final cast approval is still pending. See CHARACTER_LIKENESS_REVIEW.md.
4. Generate remaining assets with the same primary reference and approved test image.
5. Generate a new style-matched Eleanor sheet; keep her original sheet and provenance.
6. Preserve generated masters, prompts and landmark metadata. Export each PNG with
   a fixed logical pixel grid and documented ground pivot, not full-bounds normalization.
7. Review a contact sheet and actual game-scale/context render; regenerate outliers.

These 15 are individual pose assets, not 15 full four-direction animation sets.
Walking entries must show an unmistakable stride; they do not by themselves constitute
a complete walk cycle. The existing protagonist's animation polish is a separate task.
