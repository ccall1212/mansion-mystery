# Sequential four-direction pose prompt

User-selected workflow, 2026-10-24: one request describes N/E/S/W, but the other
ChatGPT generates one individual image at a time and waits for explicit approval
before advancing. Preserve this process for future characters. Do not interpret
silence as approval or combine images into one sheet. Complete missing isolated
directions first without regenerating completed work.

Copy the template below and substitute character-specific fields. Preserve each
character's identity, costume, build, proportions and approved references; do not
copy Char's outfit or signature details onto the cast.

---

Create four separate transparent PNG images of **{CHARACTER_NAME}**, **{POSTURE
AND ACTION}**, one for each direction.

Generate each as an independent image. Do not combine them into a grid, contact
sheet, collage or sprite sheet. Produce them sequentially as follows:

1. `{slug}_{posture}_{action}_north_{variant}.png` — facing away/up.
2. **STOP and wait for my explicit approval before moving on.**
3. `{slug}_{posture}_{action}_east_{variant}.png` — facing screen right.
4. **STOP and wait for my explicit approval before moving on.**
5. `{slug}_{posture}_{action}_south_{variant}.png` — facing toward the viewer.
6. **STOP and wait for my explicit approval before moving on.**
7. `{slug}_{posture}_{action}_west_{variant}.png` — facing screen left.
8. **STOP for my final review.**

For every image, use **{APPROVED IDENTITY REFERENCE}** as the primary identity and
style reference and **{MATCHING DIRECTION/POSTURE REFERENCES}** for orientation.
Preserve **{CHARACTER-SPECIFIC FACE, HAIR, COSTUME, ACCESSORIES AND BUILD}**.
Match the approved richly shaded pixel art, outlines and stylized adult proportions.

Pose requirements:
- **{ACTION, HANDS, PROPS, TARGET HEIGHT, EXPRESSION AND GAZE REQUIREMENTS}.**
- Preserve anatomical grip, posture and contact landmarks.
- North shows the character's back; do not twist the body just to expose a prop.
- Preserve asymmetric details; create each direction independently, not by mirroring.
- Keep consistent proportions and a common character scale. Seated poses remain
  naturally shorter than standing poses; do not stretch or normalize their heights.

Each PNG contains one complete character, transparent margins and complete limbs
for later furniture occlusion. No furniture, scenery, floor shadow, readable text,
labels or borders unless **{EXPLICIT ACTION-SPECIFIC EXCEPTION}** requires one.

Stop after these four images. Do not start another action or expression family.

---

Import handoff: when the user supplies results, add original bytes to the matching
direction folders, record dimensions/transparency/hashes and manifest entries, then
give the next prompt. Runtime fit and measured landmarks remain separate.

## Directional scope refinement — north only when useful
User questioned producing every north-facing emotion and identified curious as a
secondary pose for paintings, windows and bookshelves. Keep existing north assets.
Prioritize neutral, confident, reading, sitting and environment-facing curiosity
for north; future emotions and conversation gestures default to south/east/west
unless a concrete target, partner or scene requires north. Personality assignment
does not by itself require a four-way duplicate. This supersedes blanket N/E/S/W
requirements in earlier prompt examples. Use the sequential approval template only
for selected directions, preserving an approval stop after every image.
Curious hand-to-chin may be reused for quiet observation, but it does not supply
look-up, reading, reaching or a specific gaze direction automatically. Keep actor
facing, target height and action distinct; runtime pose selection remains deferred.
