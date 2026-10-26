# Char: rest and sleep poses — five single-image prompts

Drafted 2026-10-25 for the user's external image workflow. These are prompts, not art.
Nothing has been generated. Generate **one image at a time**, then stop for review.

## Why these poses

The original game's guests constantly lie on beds and divans, nap in chairs, lounge on sofas
and rest in corners. Char currently has none of these. Docs note that sleeping must not be
inferred from `lying_idle`, so sleeping is its own pose.

## Shared rules for every prompt

- Identity and style reference: `assets/characters/poses/char/masters/likeness-review-02/char-likeness-v2.png`.
  Proportions, scale and canvas: approved poses such as `exports/south/char_standing_shrug_south_resigned.png`.
- Preserve her face, long wavy brown hair, cream headband and bow, gold earrings, cream high-collar
  blouse with red brooch, burgundy sash and bow, teal layered skirt, brown laced boots. Match the
  approved richly shaded pixel art, outlines and stylized adult proportions.
- Same elevated three-quarter camera as the game. One complete character per PNG, transparent
  background, complete limbs for later occlusion. **No furniture, bed, pillow, blanket, scenery, floor
  shadow, readable text, labels or borders.** Do not mirror; draw each pose independently.
- Stop after the image and wait for explicit review.

## 1. Lying awake on a bed (deep in thought)

File: `char_lying_idle_north_south_head_north_awake.png` (folder `exports/lying/`).
Planned ID: `lying_idle_north_south_head_north`.

> Create one transparent PNG of **Char lying awake on her back, deep in thought**, with her body
> axis running **north to south** and her **head toward the top (north) of the image**, feet toward
> the viewer, seen from the game's elevated three-quarter camera (foreshortened body, as if lying on
> a bed that is not drawn). Head resting level as if on a pillow that is not drawn, eyes open and
> gazing up, a faint thoughtful frown. One hand rests on her stomach, the other arm lies relaxed at
> her side. Legs together, skirt draped naturally over them, boots visible. Long hair spread out
> around the head. Use the references and rules in this file. Save as
> `char_lying_idle_north_south_head_north_awake.png`. Stop after this one image.

## 2. Sleeping on a bed

File: `char_lying_sleep_north_south_head_north_peaceful.png` (folder `exports/lying/`).

> Create one transparent PNG of **Char asleep on her back or slightly on her side**, body axis
> **north to south**, **head toward the top (north)**, feet toward the viewer, in the same elevated
> three-quarter view and bed-less composition as the awake pose. **Eyes closed, face relaxed, lips
> slightly parted.** Both hands loosely together on her stomach or one arm curled by her head.
> Legs relaxed and slightly bent to one side, skirt draped naturally, boots visible. Use the
> references and rules in this file. Save as
> `char_lying_sleep_north_south_head_north_peaceful.png`. Stop after this one image.

## 3. Napping seated in a chair (east, south, west)

Files: `char_seated_sleep_east_napping.png`, `char_seated_sleep_south_napping.png`,
`char_seated_sleep_west_napping.png` (folder `exports/<facing>/`).

Use the approved `seated_idle` image for the same facing as the body, seat height and leg position
reference, so the existing chair fits still apply. Change only head, arms and expression.

> Create three separate transparent PNG images of **Char napping while seated in a chair**, one per
> facing. Do not combine them. Generate them sequentially:
> 1. `char_seated_sleep_east_napping.png` — facing screen right. **STOP and wait for my approval.**
> 2. `char_seated_sleep_south_napping.png` — facing toward the viewer. **STOP and wait for my approval.**
> 3. `char_seated_sleep_west_napping.png` — facing screen left. **STOP for my final review.**
>
> For each, keep the body, hips, legs and seat height of the matching approved `seated_idle` pose.
> **Head tilted to one shoulder, chin slightly down, eyes closed, face relaxed**, shoulders slightly
> slumped, hands loosely folded in her lap. No chair is drawn. Preserve asymmetric details and do not
> mirror. Use the references and rules in this file. Stop after the third image.

## 4. Lounging and napping on a sofa or divan

File: `char_lying_lounge_north_south_head_north_napping.png` (folder `exports/lying/`).
Contacts for lying on a sofa do not exist yet; this image only supplies the art.

> Create one transparent PNG of **Char reclining and napping on a sofa**, body axis **north to south**,
> **head toward the top (north)**, seen from the game's elevated three-quarter camera. She is
> **half-reclined**, upper back and head propped up as if against an armrest that is not drawn, **knees
> bent and drawn up slightly**, one arm draped along her side and the other resting on her stomach.
> **Eyes closed, a content, relaxed expression.** Skirt draped naturally, boots visible. Use the
> references and rules in this file. Save as `char_lying_lounge_north_south_head_north_napping.png`.
> Stop after this one image.

## 5. Resting against a wall or in a corner (standing)

File: `char_standing_lean_south_resting.png` (folder `exports/south/`).

> Create one transparent PNG of **Char standing and resting against a wall that is not drawn**,
> facing **south** toward the viewer. Her back and one shoulder lean on the wall, weight on one leg
> with the other foot crossed or resting lightly, **arms loosely crossed or hands clasped in front**,
> head slightly tilted back. **Tired, patient expression**, eyelids a little lowered, mouth relaxed.
> Standing height and scale match the other standing poses. Use the references and rules in this
> file. Save as `char_standing_lean_south_resting.png`. Stop after this one image.

## Notes for review

- Lying poses are recorded by **body axis and head direction**, not by actor facing. Beds in the
  rooms use four axis and headboard combinations. These images cover north-south, head north only.
  East-west beds need their own images later.
- The canopy bed's contacts are disabled pending calibration, and sofa lying has no contacts yet.
  Art can be approved now; fit and contacts are a separate step.
- Check each image for: transparency, complete limbs, a face that reads at small size, no drawn
  furniture, and correct scale against the standing poses.
- Record approvals the way the shrug was recorded (`metadata/`, manifest, directional index).

---

## Revision after review (2026-10-25): east-west, head-east lying poses

The first drafts of poses 1 and 2 lie north to south. Measured at the standing scale
(1 source pixel = 0.048 world pixels) they are about 47 x 70 world pixels. That fits the
north-south bed footprint (78 x 120) but would lie across the short side of the only bed in
the current build, the canopy bed `bed_east_west_head_east` (120 x 72). Hair and skirt spread
are the main bulk. Generate east-west, head-east versions for that bed. Keep the north-south
drafts for north-south beds. Head-west versions can wait for a bed that needs them.

### 1b. Lying awake, east to west, head east

> Create one transparent PNG of **Char lying awake on her back, deep in thought**, body axis
> **east to west**, **head toward the right (east)**, feet toward the left, seen from the game's
> elevated three-quarter camera from the south. **Compact silhouette:** hair gathered and lying close
> along the head and shoulders, only a hand's width beyond them; skirt draped straight over the
> legs with modest flare, not fanned out. About 1450 px long and 800 px wide on a 1536x1024
> transparent landscape canvas with a margin on every side, the same head size as the approved
> shrug image. Eyes open, a faint thoughtful frown, one hand on her stomach, the other arm at her
> side. Use the references and rules at the top of this file. Save as
> `char_lying_idle_east_west_head_east_awake.png`. Stop after this one image.

### 2b. Sleeping, east to west, head east

> Same view, size, compact hair and skirt as 1b, but **asleep**: eyes closed, face relaxed, lips
> slightly parted, hands loosely together on her stomach. Save as
> `char_lying_sleep_east_west_head_east_peaceful.png`. Stop after this one image.

### Sofa note

Sofas in the older layouts face different ways. A sofa facing north or south has an east-west
long axis, and one facing east or west has a north-south long axis. The sofa nap draft is
north-south; an east-west version may be needed depending on which sofa a room uses.

---

## Head-west versions (2026-10-25)

For beds with `east_west` axis and head west (`bed_east_west_head_west`). Match the approved
head-east images. Do not mirror: redraw so her own left and right details stay correct.

### 1c. Lying awake, east to west, head west

> Create one transparent PNG of **Char lying awake on her back, deep in thought**, body axis
> **east to west**, **head toward the left (west)**, feet toward the right, seen from the game's
> elevated three-quarter camera from the south. Same body pose, mood, size, compact silhouette and
> 1536x1024 transparent landscape canvas as the approved head-east image
> `char_lying_idle_east_west_head_east_awake.png`. Hair gathered close along the head and
> shoulders, skirt draped straight over the legs with modest flare, one hand on her stomach, eyes
> open with a faint thoughtful frown. **This must not be a mirrored copy.** Redraw it independently
> so her own left and right details stay correct: headband bow, earrings, brooch and sash bow.
> Keep a margin on every side. Save as `char_lying_idle_east_west_head_west_awake.png`. Stop after
> this one image.

### 2c. Sleeping, east to west, head west

> Same view, size, compact hair and skirt, and approach as 1c, matching the approved
> `char_lying_sleep_east_west_head_east_peaceful.png`, but asleep: eyes closed, face relaxed, lips
> slightly parted, hands loosely together on her stomach. Redraw rather than mirror. Save as
> `char_lying_sleep_east_west_head_west_peaceful.png`. Stop after this one image.

Check on review: the head end should again be the higher end of the slight diagonal, and the bow,
earrings and sash should sit on the correct sides of her body.
