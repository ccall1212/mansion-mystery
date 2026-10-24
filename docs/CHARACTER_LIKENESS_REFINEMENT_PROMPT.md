# Preserve cartoon style while refining likeness

Char's first photo-informed draft was rejected as **too realistic**. The user
prefers the original anime/cartoonish character treatment. The second draft uses
photos only for subtle identity cues. No runtime reference has been replaced.

## Reusable prompt

Attach the original character as image 1, an approved cartoon style reference as
image 2, then up to three photos of the same person. The built-in tool accepts at
most five image paths. Identify the clearest unobstructed face reference.

```text
Revise {CHARACTER_NAME} using the attached original character and photographs.

Image 1 is the PRIMARY EDIT TARGET: preserve its anime/cartoon pixel-art face
language, large expressive eyes, stylized adult head/body proportions, full-body
pose, silhouette, historical clothing and palette.
Image 2 is the supporting cartoon ART STYLE reference. Match its soft illustrated
face and pixel rendering, not its identity, hairstyle or outfit.
Images 3–5 are LIKENESS references only; image {N} is the clearest face. Photos
must not determine rendering style or realistic facial anatomy.

Improve recognition through subtle cues in {BROWS_HAIR_SMILE_CHEEKS}, retaining
the appealing anime/cartoon face. Large bright expressive eyes, a tiny simplified
nose, clean stylized mouth, soft cheeks and smooth illustrative skin shading are
essential. Keep the original expressive head scale and adult body proportions.
If teeth show, use one simplified cartoon light shape.

Do not reconstruct a photographic face, shrink eyes for realism, elongate the
face, or add individual realistic teeth, pores, skin texture, detailed smile
creases or portrait-like anatomical shading. Likeness must remain stylized.

Preserve {EXACT_HISTORICAL_OUTFIT}, {POSE_AND_HANDS}, individual asymmetries,
light direction, detailed fabric folds and deliberate pixel clusters. No modern
photo clothing/accessories, filters or scenery unless explicitly requested.

Output one complete head-to-toe character with both shoes visible, genuine RGBA
transparency and comfortable margins. No floor shadow, room, furniture, labels,
panels or extra person. Save a separate review draft. Do not replace the current
reference or begin directional poses before review.
```

## Char's execution records

Keep cream lace blouse/cuffs, cameo, teal-green long skirt, burgundy sash/bow,
cream hair ribbon, modest jewelry, brown shoes and gently clasped hands.
Her brown waves, expressive brows and friendly smile inform the likeness while
large cartoon eyes and simplified soft facial features define the style.

- Exact approved prompt is embedded in the current JSON record below; its duplicate text copy was removed.
- [Current inputs, settings and output record](../assets/characters/poses/char/prompts/likeness-refinement-02.json).
- [Cartoon review draft v2](../assets/characters/poses/char/masters/likeness-review-02/char-likeness-v2.png).
- Rejected v1 image/prompt removed; keep the lesson: prioritize the approved anime/cartoon face over photographic realism.

Tool: built-in `image_gen.imagegen`, transparent background requested. Photo inputs
are preserved under ignored `reference/art-direction/char-likeness-20261023/`.
V2 appearance was approved by the user on 2026-10-23. It is not a validated directional/furniture-fit export.

Next: [Char pose-generation prompt](CHAR_POSE_GENERATION_PROMPT.md), using the approved v2 master.
