# Char: resigned shrug (south) — single-image prompt

Drafted 2026-10-25 for the user's external image workflow. This is a prompt, not art.
Nothing has been generated. Approval of the result is a separate step.

## Decisions behind it

- Purpose: a culprit's matter-of-fact confession ("naturally I did it, all things considered").
  It fills the gap left by the four approved reveal poses (defiant point, remorseful sob,
  triumphant laugh, furious threat). It is **not** an ordinary guilt indicator.
- Expression: **flat, tired resignation** (user choice, 2026-10-25).
- Gesture: **both palms up at waist height** (user choice).
- Scope: **south-facing only**. The same body may later be reused with a neutral face for an
  innocent "I don't know" answer, but that is not part of this batch.
- Identity, costume and scale follow the approved Char references and the existing reveal poses.

## Prompt (paste for one image)

Create one transparent PNG image of **Char**, standing, doing a **resigned shrug**, facing
**south** (toward the viewer). Save it as `char_standing_shrug_south_resigned.png`.

Use `assets/characters/poses/char/masters/likeness-review-02/char-likeness-v2.png` as the
primary identity and style reference, and the approved south-facing reveal poses
(`char_standing_laugh_south_evil.png`, `char_standing_accuse_south_defiant.png`) for
orientation, canvas and scale. Preserve her face, long wavy brown hair, cream headband and bow,
gold earrings, cream high-collar blouse with the red brooch, burgundy sash and bow, teal layered
skirt and brown boots. Match the approved richly shaded pixel art, outlines and stylized adult
proportions.

Pose requirements:
- A resigned shrug: shoulders lifted slightly, elbows bent close to the body, forearms
  forward, **both palms turned upward at waist height**, fingers relaxed and slightly open.
- The head is tilted a little to one side. Her eyes look at the viewer with **lowered, tired
  eyelids**, brows relaxed with the inner ends slightly raised, and a **flat, neutral mouth** as if
  after a small sigh.
- The mood is "I've given up and it hardly matters": not smiling, not angry, not frightened,
  not surprised, not sad enough to cry.
- Keep the weight relaxed on one leg and the skirt hanging naturally.
- It must read differently from the existing startle (hands raised in fear), defensive denial
  (one palm out, one hand on chest) and friendly clasp (hands together) poses.
- Keep both hands, the brooch and the sash clearly visible.

Output: one complete character on a transparent background, about 944×1665 pixels like the other
reveal poses, with transparent margins and complete limbs for later occlusion. Keep the common
character scale. No furniture, scenery, floor shadow, readable text, labels or borders.

Stop after this one image and wait for my review.

## Review checklist (for the user)

1. Does the face read as resigned, not sad, bored or angry, at gameplay size?
2. Is the silhouette clearly different from startle, denial and clasp?
3. Are both palms, the brooch and the sash visible?
4. Do hair, costume, earrings and proportions match the approved Char art?
5. Is the PNG truly transparent with complete limbs and no stray shadow or border?

## Metadata to record on approval (skeleton; do not fill until a result is approved)

```json
{
  "pose_id": "standing_shrug_south",
  "variant_id": "resigned",
  "actor_facing": "south",
  "posture": "standing",
  "activity": "shrug",
  "expression": "resigned",
  "gesture": "both_palms_up_shoulders_raised",
  "props": [],
  "intended_use": "Culprit reveal: resigned, matter-of-fact confession; not an ordinary guilt indicator."
}
```

Expected files after approval, following the existing reveal-pose layout: a master in
`masters/murderer-reveal-01/` (or a new `shrug-01/` folder), the export in `exports/south/`,
metadata in `metadata/`, and an `image_approval` record checked with
`python tools/check_image_approval.py`.
