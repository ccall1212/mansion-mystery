# Prioritized development plan

Original research direction (2026-10-25): the user wants ideas for the remake,
not an automatic-win system. The existing MCP adapter is an observation tool.
The latest focused study checked waiting, repeated refusal/recovery and room
revisits after collecting the glass; it did not pick up a weapon, gather or accuse.
Next authoring work: review equivalent full accounts, concise recaps and temporary
refusals for The Silent Library's existing facts. Then use small targeted studies
only for unresolved design questions. See DIALOGUE_RANDOMIZATION_DESIGN.md for
prioritized lessons and original draft lines. No new runtime features are delivered
by this research, and building an automatic solver is not a milestone.

Dialogue research update (2026-10-25): [the full original-data audit and proposed
randomization design](DIALOGUE_RANDOMIZATION_DESIGN.md) separates identities,
personalities, case roles, timelines, knowledge and claims. Proposed next dialogue
slice: preserve the authored first-case facts while reviewing a small set of
equivalent voice/repeat/accusation responses, then add a constrained case generator.
This is research/planning only; randomized cases, personality selection and general
NPC activity staging were not implemented by the audit.

**Current compact scope:** four ground-floor rooms, two upstairs rooms and one
basement room, plus a main stair hall and upstairs landing (nine spaces total).
Every active background is unique. Earlier 18-space descriptions below are historical.
[Current room review](../test-results/compact-mansion/index.html). A top-of-screen floor/current-room map is recorded as future work.

Latest Char milestone: seven static alignment samples, common-scale padded draft exports and three room-context mockups are [ready for review](CHAR_ALIGNMENT_01_REVIEW.md). The user approved all seven artwork samples. No runtime integration or calibrated furniture fit is complete. Next-phase planning is in CHARACTER_DIRECTIONAL_PIPELINE_PLAN.md; no additional art is authorized by that plan.

## Current milestone — one fixed walkable house

The default now connects 18 spaces (four main rooms and two circulation spaces per
floor), with main/service stair returns, collision, explicit doorway interaction,
room/floor directory, persistent inventory and save/load from any room. The lens
is collected in the foyer and used on the library knife. Existing art is reused;
dining/kitchen/washroom dressing and some passage/stair depictions are provisional.
See [FIXED_MANSION.md](FIXED_MANSION.md) for routes, art gaps and validation.
Walking/scale review now includes a shared 64-pixel adult renderer, faster existing-frame
animation, revised Eleanor, and seven seeded temporary guests with stable room-specific
statements. See [CHARACTER_RENDERING.md](CHARACTER_RENDERING.md). Next playtest
these proportions and fit the awkward connections before the first small solvable case. The four seeded blueprint plans remain separate review tools.

## Furniture annotation foundation

Implemented 84 orientation IDs across 21 furniture types, a background-local JSON
format, 118 draft tags across 14 backgrounds / 18 playable rooms, and a visual
mapper for drawing, moving, resizing, disabling contacts, calibrating contact/approach
points and listing required poses. Background registration lets new images reuse
this workflow. Runtime room-scoped lookup and F6 labels are integrated; automated
NPC furniture placement, pose production and foreground occlusion remain pending.
See [FURNITURE_IDS.md](FURNITURE_IDS.md) and all 18 rendered review screenshots in
[TAGGED_ROOM_SCREENSHOTS.md](TAGGED_ROOM_SCREENSHOTS.md). Char is the first planned
full static pose set; [CHAR_POSE_PLAN.md](CHAR_POSE_PLAN.md) begins with seven
standing/seated alignment samples after room review. Pose art, automatic staging
and foreground overlap remain pending.

The full [pose audit](CHARACTER_POSE_AUDIT.md) records 45 concrete directional
requirements and 34 semantic action/reaction families, with every enabled/disabled
room contact mapped. Char's planning manifest and the reusable production workflow/
prompt are initialized. Next resolve presentation size and review the seven-sample
alignment batch; new art, nonstanding renderer, masks, personality/event selection
and actual pose integration are not implemented by this documentation task.

## Initialization delivered

- Preserve ZIP and extracted reference, record hashes and inventory.
- Reuse installed DOSBox-X; isolate launches from the reference.
- Implement local stdio MCP inspection, control, capture and testing.
- Verify real SDK modern/legacy discovery, original startup and Codex discovery.
- Preserve the existing Godot project and record the current 2D haunted-mansion direction.

## P0 — small playable 2D mansion foyer (implemented)

Build one room in Godot's 2D tools with an elevated three-quarter view, a controllable
sprite, collision, depth sorting and one inspectable portrait or clock. Use original
placeholder art with a Wild Arms-inspired sense of scale and detail. Add candlelight
or a storm-lit window to establish the scary-mansion mood. Use the supplied gothic
landing and furnished-interior examples as the main visual anchors: central runner,
shallow stair, ornate doorway, compact sprite and readable inspection panel. The
stair and far doorway may remain scenery in this milestone. Acceptance: launch into
the room, move around furniture, inspect the object, read and close its response,
capture and inspect native/enlarged screenshots, and repeat the interaction in a test.
Implement and validate launch_remake and the keyboard adapter for the actual remake
window. Mouse support is optional for this keyboard-first milestone. The first scene
is now implemented at src/foyer/foyer.tscn, using an original generated backdrop and
an original investigator. The clock opens a clue panel and increments the clue count.
The north doors and stairs are scenery with a locked-door response. The separate
reading stand demonstrates depth sorting and furniture collision. The previous
first-person 3D milestone is superseded.

Validation: Godot physics/interaction checks and a real-window MCP smoke exercise
movement, clock inspection, clue state, closing the panel, screenshots and cleanup.
Evidence is in test-results/foyer-engine-tests.json and remake-smoke.json. This is an
initial art and interaction slice, not a complete room editor or mystery system.

## P1 — deduction slice

Evidence milestone implemented: independently configured identity, condition,
forensics and examination stages; eleven original props with two physical states
each and a collectible magnifier; three forensic detail insets; clue-book and
inventory memory; explicit save/load through mansion room memory. The foyer hosts
the knife/lens/innocent mirror route. A separate production scene reviews all props
and variants. See OBJECT_VARIANTS.md and EVIDENCE_ASSET_QA.md for validation and
the remaining curated catalog. Next place these objects in connected ground-floor
rooms and author a small solvable case before adding further floors.

Blueprint milestone: four original seeded layouts now define ground, upper and
basement floors before further asset changes. Main/service stair shafts have paired
endpoints and redundant circulation; per-room art references remain stable on revisit.
MansionWorld provides logical floor/arrival/visited memory and validated blueprint
session snapshots. A separate review scene rehearses graph routes and shows art gaps.
The foyer now reports selected mansion metadata in its development status, but its
physical scene and sealed-door behavior remain the same. See MANSION_BLUEPRINTS.md.
Next review the four plans, fit door/stair art, then validate one actual connected
room before extending to full mystery systems.

First step implemented: Eleanor Vale stands at the right-hand window and turns
toward the player when questioned. A topic menu offers her alibi, unusual sounds,
and a response about the clock that changes after inspection. Conversation locks
movement, can be repeated, and records which topics have been asked. These are
authored prototype statements; a solvable generated case is not implemented yet.

Add a second room, two suspects with fixed alibis, one clue, extend the current inventory and a simple
correct/incorrect accusation. Separate state logic from the presentation and expose
a local test hook rather than relying only on pixels for gameplay correctness.

## P2 — full mystery systems

Environment art milestone: eighteen original backgrounds now cover the nine requested
room types with two floor plans each. Upstairs ascent and basement descent use
separate assets. A standalone Godot art viewer, source/runtime manifest, separate
library book, contact sheets and 36 engine captures are available. The original foyer
is preserved. Environment checks pass; connected room collision/exit implementation
remains pending. See ROOM_ROSTER.md and ENVIRONMENT_ASSET_QA.md.

Observe original SEARCH/EXAMINE, room clues, alibis, roaming, suspicion, gathering,
accusation and losing. Record evidence, then implement deterministic generation and
seeded scenarios with solvability tests. Expand the house and art only after the
small deduction slice works.

## Remaining environment checks

- Reopen Codex and confirm sleuth_game is connected in the actual desktop chat.
- Validate the original's directional movement and parser commands through captures.
- Check sound and sound toggle; do not assume the observed title proves audio works.
- Validate prototype bindings, sprite scale and pixel readability in the foyer.
- Decide whether the haunting is real, staged or ambiguous before changing mystery rules.
- Engine checks and remake launch validation are implemented; keep them passing.
- Review the playable foyer's character scale, art and movement feel with the user.
- Refine the investigator's actual walk-cycle artwork: user reported weak leg
  movement and a floating appearance. Alpha bounds now ignore translucent fringes,
  the contact shadow is tighter, animation follows distance travelled and the camera
  uses smoothing. A proper animation-art pass remains pending; do not claim it fixed.

## Character art review in progress

Four original pose tests established the compact, larger-head direction. User feedback
asks to retain Eleanor's face and costume with those proportions and soft flattering
skin shading. Personal photographs now guide adult likeness concepts, with blurred
faces excluded and mansion attire replacing modern/party clothes. The explicitly
matched hat portrait/front-left group man gets an additional hat-off head-scratching
pose. See CHARACTER_LIKENESS_REVIEW.md for source labels and pending duplicate checks.
Present review boards before finalizing the cast; existing runtime art stays in place
through this review. Likeness concepts are not complete animation sets or final assets.

Latest review: keep the first-group A–F faces and outfits but redraw taller adult
bodies; use the accepted party group for body proportions. Party F is merged into C,
party G into H, and their separate designs are removed from the current review.
First-group E remains the cap/head-scratch character. Final cast approval is pending.

Identity update: party C = first-group D (including earlier party F alias), and party
D = first-group B; keep their alternate looks as pose/outfit variants. First-group E
is the user. Face refinement targets E and first-group C in the blue waistcoat,
with reduced forehead exaggeration. Use E's newer, fuller-beard photo consistently
across his neutral, cap-worn and cap-removed/head-scratch poses.

Naming checkpoint: merge party I with the pink-cardigan woman, party M with first A,
and party K with first F. Refine F/K's existing looks with goatee and cheek scruff.
Present all current character designs together with stable numbers, including earlier
game/fictional drafts, and wait for user-supplied names before generating more poses.
Current combined sheets and catalog are under assets/characters/review-v5/.

Latest primary-look review is assets/characters/review-v6/: user-selected I → 01,
M → 02, C → 05, hat-on/head-scratch pair → 06, K → 07. Numbering and other primary
images are retained. Continue with user-supplied names before producing more poses.

Review-v7 saved the first 13 supplied names and revised Sarah Jo to very short hair.
The latest request also adds two base character drafts from a new couple photo:
20 is a short adult woman (about five feet), 21 is the glasses/goatee man. Both
were initially unnamed, as were 14-19. That 21-design overview is retained as
historical review evidence.

Current review-v8 names 20 Jessica and 21 John, with cartoon face revisions using
the established party cast as the style reference. Sarah Jo's new look is approved
and preserved. Remove 16-19 from the active roster, retaining their historical art.
The overview now shows 17 designs, with original numbering and 24 active views.
Eleanor is the proposed opening maid; costume and runtime narrative changes remain
pending. Review the remaining appearances before pose sets or runtime integration.

## Compact locked-house revision

The user's smaller-first direction supersedes the 32-36-space blueprints. All four
versions now have four functional rooms plus two integrated hallway/stair spaces
per floor (18 total spaces). The north-facing foyer door is a locked boundary,
with no exterior graph link. Main/service routes and stable floor memory remain.
First connect the ground-floor foyer, library, dining room and kitchen; evaluate
a complete small deduction case before opening further floors or adding rooms.
A 10-15-minute case is an unmeasured target. The later evidence milestone adds a
first clue book for examined objects and collected items; the blueprint revision
itself only establishes topology and floor memory.

## Directional asset organization and side-contact review

Char's seven approved PNG exports now live in exports/north, east, south and west.
Each filename contains character, pose/direction and variant; original image bytes
and approval hashes are unchanged. Her root index.html is the human asset browser.
Windows/pictures/clocks now have additive side viewing contacts, separate facing
and gaze targets; 38 unique draft anchors were added. Shared transforms/validation,
mapper resize support and the all-room review gallery were updated. No automatic
NPC pose selector, new pose art or staging approval was added. Next: user review
of the galleries, then shared contact rendering and Char's actual chair calibration
before expanding environment-interaction poses.

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


## First authored case and chair fit preview — 2026-10-23

F4 opens The Silent Library: three suspects, room-owned rug observation, evidence
gates, statements in the notebook, accusation and written ending. Wrong accusations
allow retries in this prototype. Case progress and roster round-trip through the
fixed session snapshot. The focused native integration run passes 31 checks;
actual Compatibility captures are in test-results/first-case/index.html. Three
Char chair offsets/foreground polygons are preview-only and await visual review.
Approved character PNGs are unchanged. See [FIRST_PLAYABLE_CASE.md](FIRST_PLAYABLE_CASE.md)
for controls, reproduction and remaining group/reveal/randomization work.

Evidence rendering preview: shared source-detail loader replaces tiny object exports for world props and inspection artwork while preserving world footprints/anchors. See test-results/evidence-detail/index.html; visual review pending. No object artwork regenerated.


Reworked-room tagging: nine approved room candidates now have registered furniture layouts and a 126-tag review gallery. Next: calibrate the library with Char (east/west reading armchairs, south desk/rear-table chairs), add proper masks/clearance and resolve the missing north seated pose before enabling placement. Live room integration and the library west-to-south route change remain pending.
