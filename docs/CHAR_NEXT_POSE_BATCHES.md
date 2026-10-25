# Char: seating review, then complete directional pose production

Current user direction, 2026-10-24: foyer fits approved; review dining, kitchen
and upstairs seats next. Work through Char's complete pose set, including
personalities, directional personality gestures, holding books and directional
emotions. Complete other character pose sets before randomized NPC staging.
This supersedes the earlier recommendation to implement random staging next.

## Current seating coverage

Two foyer fits are visually approved by “1 is approved”. Exact capture hashes,
seat contacts and background hash are in `foyer-fit-review.json`. Runtime remains
disabled. The remaining-seat review has 15 existing-pose comparisons, four enabled
contacts requiring seated north, and four deliberately disabled contacts. Beds
retain their existing axis/headboard metadata and are not treated as ordinary seats.
Kitchen stool anatomy and the bedroom's back-oblique reading chair need particular
review. A profile sprite in front of that chair is a mismatch demonstration, not
a completed fit. Table masks are candidates, not approval evidence by themselves.

Review: `test-results/char-remaining-seat-fit/index.html`. Config and per-contact
source links: `assets/characters/poses/char/remaining-seat-fit-review.json`.
Each furniture anchor owns its reusable fit record. Char owns only her approved
art and contact landmarks; future characters reuse geometry with compatible poses.

## Directional production checklist

All directions below mean actor facing north/east/south/west, independently of
the furniture orientation. Track each direction explicitly. Never auto-mirror
asymmetric clothes, ribbon, book, jewelry or hand use. These are planned families,
not claims that artwork exists or that every combination needs a unique body.

| Batch | Coverage | Existing / missing |
| --- | --- | --- |
| Seating foundation | Idle seated N/E/S/W; stool-specific leg/foot alignment; rear-oblique chair compatibility | E/S/W artwork approved; N missing; special seats pending review |
| Books | Standing holding a closed book N/E/S/W; standing reading an open book N/E/S/W; seated reading N/E/S/W | All action variants missing. Preserve book hand, spine/page orientation and gaze |
| Conversation | Talk and listen N/E/S/W | Standing idle may provide shared body; expressions/gestures need review |
| Object interaction | Inspect at eye/table height, look up, look down at floor, reach high/low, pick up, doorway peek/open, warming hands, writing, drinking | Use exact active contacts and full audit; distinguish target height from facing |
| Postures | Kneeling/crouching inspection; bed sitting/lying with recorded axis/head alignment | Missing; bed calibration remains disabled |
| Personality vocabulary | Friendly/open, nervous/fidgeting, reserved/guarded, confident, irritated, curious/thoughtful, sad/withdrawn, smug/defensive | Plan N/E/S/W for each selected gesture; these are reusable variants, not Char's permanent traits |
| Emotions | Happy/relaxed, nervous, fear, suspicion, anger/annoyance, confusion/curiosity, surprise/shock, sadness/distress, embarrassment, relief, confidence, smugness/defensiveness | Explicit N/E/S/W review coverage. Reuse suitable bodies; use a distinct body only when silhouette/action changes |
| Accusation/reveal | Questioned, innocent denial, accused distress/anger, culprit recognition of exposure, denial/defiance, panic, remorse/confession; witness shock/fear/disbelief | Keep role/event variants separate. Guilt is never inferred from an ordinary expression |
| Group interactions | Listening to another speaker, gaze to evidence, witness reactions, context-specific partner gestures | Direction and gaze depend on partner/target placement; no automatic duplicated actors |

For north-facing emotions, a hidden face cannot communicate a facial expression.
Review shoulders, hands, posture, head tilt or an intentional head-turn variant.
Keep body facing and head/gaze direction separate. Do not draw a front face onto
the back of the head. Book poses also need distinct readable silhouette and gaze
for each direction; holding and reading are different actions.

Source-linked details remain in [the master matrix](pose-audit/MASTER_POSE_MATRIX.md),
[furniture mapping](pose-audit/FURNITURE_POSE_MAPPING.md),
[reaction matrix](CHARACTER_REACTION_MATRIX.md) and
[brainstorm](GAME_DESIGN_BRAINSTORM.md). Older counts are historical inventories,
not a substitute for the current four-room seat review. Optional brainstorm
gestures remain optional unless selected for a production batch. Char's personality
and signature gesture remain unassigned; expression production does not assign guilt.

## Execution and approval

After seat review, the smallest next artwork batch is seated north, followed by
four-direction book poses. Review full-scale art plus applicable furniture context
before proceeding to personality/emotion batches. Preserve approved likeness-v2,
the seven existing samples, common scale and directional filenames:
`exports/<direction>/char_<posture>_<action>_<direction>_<variant>.png`.

Record exact prompts, references, hashes, contact landmarks, masks and status in
Char's production manifest as work happens. Use the existing workflow and reusable
prompt. No new images were generated in this seating-review task. New art still
requires its separate result approval. Do not implement random room/action staging
as the next step; the user deferred it until the character pose sets are complete.

Reproduce comparisons with the configured Godot executable:
`--path . --script tools/char_remaining_seat_fit_preview.gd`, then
`python tools/build_char_remaining_seat_fit_review.py`. The renderer checks source
hashes and resolves contacts from furniture layouts. It does not validate navigation,
seated collision exceptions, arbitrary body shapes, or packaged exports.

## Upstairs review correction
User requested six seat/contact and mask adjustments. The west-facing vanity bench seat is disabled because of the adjacent dresser; the bedroom east reading armchair is excluded from seating for everyone. Current gallery: 13 comparisons, four missing north-facing seats, six disabled contacts. Corrected upstairs previews remain pending approval; earlier counts above describe the initial pass. Character PNGs and shared scale are unchanged.

## Listening reuse decision
User skipped the separate attentive-listening batch because it duplicates regular neutral. Reuse the matching standing idle neutral directions; no new listen artwork is required. This is an art reuse decision; a runtime action alias has not been implemented. Nervous fidget N/E/S/W was supplied and imported unchanged; scale/landmark calibration remains pending.

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
