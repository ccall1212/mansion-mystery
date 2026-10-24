# Character asset QA

Status: in production. Do not interpret planned checks as completed validation.

The original investigator front frame is the primary reference. Original Eleanor
is preserved and deliberately not used as the proportion benchmark. Measurements
and tolerances are in CHARACTER_ART_GUIDE.md.

## Initial difficult-pose gate

Jonas was generated first and visually inspected against the investigator front and
profile, plus the original Eleanor costume reference. The large expressive head,
compact shoulders/neck, substantial boots, warm outline and clustered shading match
the primary language. His bent knee, planted opposite boot and floor-directed gaze
communicate kneeling; the lens is held naturally. His occupied kneeling height is
shorter than a standing adult, which the export must preserve. This comparison
is a preliminary technical style check, not final user approval. Eleanor's original small
head remains a documented outlier to replace non-destructively.

The user requested a review before finalizing the look. Four initial draft masters
exist (Jonas, Ada, Pip and Martha). Subsequent feedback favors larger heads, preserves
Eleanor's face/design and soft feminine skin shading, and adds personal adult likenesses.
New review candidates are authorized for that refinement; final cast approval and
replacement of existing gameplay characters remain pending. See
CHARACTER_LIKENESS_REVIEW.md for mappings and the review boundary.

## Likeness draft review evidence

The newer review is saved in `assets/characters/review-v2/`. Built-in imagegen produced
six selected review files: Eleanor's larger-head candidate, the first-photo woman's
compact revision, a two-pose cap/head-scratch character, and three group concept boards.
The first woman's overly long initial version is preserved but excluded from the
comparison. Exact prompts and a review manifest are saved beside the masters.

`draft-file-checks.json`: six files present, readable, nonempty and uniquely hashed.
The three individual/pair masters are RGBA with transparent pixels; the group boards
are intentionally opaque concept layouts. These checks do not prove likeness or
production readiness. The 19 group-photo source slots comprise photo 03 A–F and photo
04 A–M. Photo 03 E explicitly repeats the cap portrait. Other repeats are unconfirmed.
All designated blurred people are excluded from the requested concepts.

`likeness-style-review.png` was rendered in Godot, exit 0, with no final render-log
errors, then visually inspected. It compares the original investigator, original
Eleanor, revised Eleanor, photo 01 revision and both cap poses at equal standing height.
It uses technical alpha cleanup in memory only; generated masters are unchanged.
This is a proportion comparison, not a gameplay-scale integration test.

Initial visual review: Eleanor retains her silver hairstyle, emerald dress, lace/cameo and
clasped hands with an enlarged face. Photo 01's second pass has a much shorter body
and larger head. The cap is removed and held during the head-scratch, with bare crown
visible. The group boards are useful for face/wardrobe review, but several figures
retain longer silhouettes than the target; individual proportion passes, likeness
corrections, common-scale exports, and in-room review are still required.

Subsequent user feedback rejects the first group's squat bodies while retaining its
faces and costumes. The taller party-group treatment is the new reference, so the
earlier plan to shorten group bodies is superseded. Party F/G are removed as separate
identities: retain C for F, and H for G. Current revised boards and mappings live under
`assets/characters/review-v3/`; the earlier masters remain preserved.

Final cast approval remains pending. Existing runtime art is unchanged. This batch
does not complete the original 15 transparent pose assets or any walking animation.

## Taller-adult revision and duplicate cleanup

Built-in imagegen produced two non-destructive revised review boards under
`assets/characters/review-v3/masters/`, with exact prompts alongside. The first-group
board contains six fully visible adults A–F with visibly longer legs and torsos,
preserving the liked faces/outfit identities and different builds. E retains his
bare crown, ginger beard, navy shirt, tweed waistcoat and gray cap held at his side.
The revised party upper board contains exactly five people A–E, with F/G removed.
The retained party faces/clothes remain visually consistent with the approved designs.
H–M remains unchanged. This is a visual comparison, not automatic facial validation.

`review-v3/draft-file-checks.json`: both revised PNGs decode, are nonempty, and have
unique hashes. All three prior group boards match their saved original hashes.
The new boards are opaque concept layouts, not individual transparent sprites.
The revised first-group proportions still await the user's review. No runtime scene
was changed or gameplay integration test claimed for these concept-only edits.

## Face, beard and identity revision

The user confirmed party C = first-group D, and party D = first-group B. Those
appearances are tracked as variants of shared identities in
`assets/characters/likeness-identities.json`, not separate people. First-group E is
the user. An explicit clarification selects first-group C in blue for the forehead
refinement, not party C. A new fuller-beard photograph supersedes older E references.

Current selected review art is under `assets/characters/review-v4/masters/`:
`photo-03-handsome-c-e-current-beard-v4.png` and `photo-02-hat-full-beard-v4.png`.
Built-in imagegen was used; exact prompts are saved. Earlier passes already running
when the newer photograph arrived are preserved as intermediate versions and excluded
from the active manifest. The party boards, Eleanor and photo 01 candidates are retained.

Visual review: C has a less exaggerated forehead with a modestly fuller sandy front;
E has a fuller brown beard and connected moustache, with a more balanced scalp/face.
The updated beard is present in neutral, cap-worn and cap-held/head-scratch appearances.
The other first-group faces/clothing and taller body language remain visually consistent.
The pair retains a naturally contacting raised hand and held cap. These observations
are not an automatic likeness score or final user approval.

`review-v4/draft-file-checks.json`: selected images decode and are nonempty; the cap
pair is RGBA with transparent pixels. Prior revised boards still match their saved
hashes. Identity checks verify the user/E/cap mapping, C/D and D/B cross-photo merges,
earlier F/C and G/H aliases, and no alias assigned to two entries. Source alpha still
has translucent fringes; production cleanup, individual exports and game-scale review
remain pending. No runtime art was replaced. Final cast approval is pending.

## Consolidated cast and naming checkpoint

Latest explicit merges: party I = pink-cardigan woman, party M = first-group A,
party K = first-group F. The identity catalog now has 13 photo-based people.
The two existing F/K looks were edited with built-in imagegen to add a scruffy
goatee, moustache and short lower-cheek/jaw scruff. Both old boards are preserved.
The newly edited boards retain the other characters' recognizable designs and
existing body lengths. No new poses were generated for this step.

`review-v5/current-cast-overview.png` shows all 13 photo-based people plus the
earlier protagonist, Eleanor and four fictional pose drafts: 19 numbered designs.
`same-person-variants.png` groups seven multi-image identities under their shared
numbers, covering the existing alternate looks and original/revised Eleanor.
Together the catalog selects 27 existing character views. The local
`all-character-art.html` adds an expandable archive of all 21 generated character
masters/source sheets, including earlier versions. It loads local artwork only;
the personal reference photographs are not embedded in the gallery.

Both PNG sheets were rendered through Godot SubViewports, exit 0 without render-log
errors, and visually inspected. All 19 numbered cards and seven variant cards have
readable labels and complete figures. Technical panel cropping, aspect-preserving
layout and in-memory alpha cleanup do not redraw faces or change master files.
This is a comparison layout, not final in-game scale calibration. Earlier kneeling
and crouching drafts are shown shorter than standing figures.

`review-v5/draft-file-checks.json` reports successful checks of 19 stable numbers,
13 photo identities, 27 view references, all source image reads/crop bounds, both
sheet dimensions, transparent-source alpha, nine identity relationships and unique
alias ownership. PNG hashes and selected source dimensions are recorded. The Godot
script also passed its check-only parse before the actual render. Gallery generation
completed successfully. Names and final cast approval remain pending; the user
requested names before additional pose production. See CAST_NAME_REVIEW.md.

## Exact primary-look selections

Review-v6 replaces five primary overview looks with the user's supplied existing
art: image 3 I → 01, image 3 M → 02, image 4 C → 05, image 2 hat pair → 06,
and image 3 K → 07. Number 06 shows both selected poses in its one overview card.
The supplied PNG sources are copied unchanged into review-v6/sources. This is a
catalog/layout revision, without a character redraw or new pose generation.

Godot check-only parsing and the actual SubViewport render both returned exit 0;
the render log contains no errors. Both new PNG sheets were visually inspected:
the requested looks are in the specified slots, figures are complete, and both
06 poses fit within its card. The companion sheet orders selected looks first.
The gallery/check builder succeeded for 19 stable review numbers, 13 photo-based
identities and 26 active views. The former neutral 06 view is archived.

`review-v6/selection-checks.json` verifies all three copied source PNGs exactly match
the user's attachments, the 14 unselected primary source entries are unchanged,
and numbering/identity IDs are preserved. `draft-file-checks.json` records image
dimensions, hashes, crop checks and the existing identity relationships. Final cast
approval and names remain pending. The current review is described in
CAST_NAME_REVIEW.md; runtime art is unchanged.

## Named cast, short hair and two new people

Review-v7 saves the exact 13 supplied names in both the cast catalog and canonical
identity data. Names 14-19 remain null; the newly requested foreground couple is
added as unnamed 20-21 without changing existing numbering or identity merges.
Only those two foreground people from the new photo were used as character subjects.

Built-in imagegen created Sarah Jo's very-short-haired revision and two new standing
base-character drafts. Exact prompts and masters are preserved. Sarah Jo retains her
soft face, navy embroidered dress, lace and cameo, with visible ears and cropped nape.
Her first hairstyle pass elongated the body; a follow-up proportion pass is selected.
The new woman has dark brown curls and royal-blue period clothing, and is displayed
at 0.85 comparison standing height as the requested five-foot short adult. She and
the glasses/goatee man are adjacent in the overview for height review. Their skin
tones are neutralized from the source photo's blue event lighting. Final proportions,
likeness and common game scale still require user review; no animation sets result.

Godot check-only parsing and actual SubViewport rendering returned exit 0. The named
overview (1500 x 1865) and alternate-looks sheet (1500 x 1440) were visually inspected:
all 21 cards, the 13 supplied names, 7 same-person variant groups, complete figures,
short-haired Sarah Jo and the shorter new woman are visible. No final render-log errors.

The gallery/check builder validates 21 numbers, 15 photo-based identities, 28 active
views, source reads/alpha/crops and canonical aliases. It includes an archive of 25
generated character masters/source sheets. Names are shown in the PNG headings and
HTML table; 14-21 remain unassigned. change-checks.json separately verifies the exact
13-name sequence, eight null names, unchanged prior 19 identities and the other 18
art selections, plus the new pair's height ordering and adjacent layout slots.
No runtime characters were replaced and no further action-pose sets were generated.
The earlier game names visible as working labels are not user-assigned names.

## Planned final production-file objective checks

Every final file: PNG/RGBA, nonempty transparent border, alpha >= 128 subject bounds,
no opaque rectangular background, no clipped subject, unique content hash, finite
manifest pivot and common documented scale. Store master size, extracted bounds,
head landmarks, final size and opaque-color/alpha statistics. Check all 15 expected
concepts and compare both originals and revised Eleanor in a contact sheet.

## Planned visual checks

Inspect proportions, perspective, hands, gaze, pose, outline and lighting at master
size and in-game size. Do not claim a single pose is a complete animation. Context
renders must layer the reader into a chair, the crouching child under a bed and the
peeking character behind a doorway without painting those props into character PNGs.
