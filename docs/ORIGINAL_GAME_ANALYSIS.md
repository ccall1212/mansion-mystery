# Original Sleuth: combined research and remake ideas

Consolidated 2026-10-25 from Claude's gameplay notes, Codex's observed screens and
static data audit, and the user's investigation guidance. **This is the current
combined research entry point.** Its purpose is learning what to bring to Mansion
Mystery, not building an automatic winner. Research conclusions do not authorize
new gameplay implementation or additional art.

## Sources and confidence

| Source | Coverage | How to use it |
| --- | --- | --- |
| [Claude's gameplay notes](<../Claude observations/ORIGINAL_GAMEPLAY_OBSERVATIONS.md>) | Seven reported games: initial observations in sections 1–16, games 3–4 and corrections in section 17, games 5–7 in section 18. Three reported wins, a wrong-room ending and three reported deaths. | Claude's reported live observations. Later corrections supersede earlier claims within that report; inferred rules remain hypotheses. |
| Codex surveys and focused study | Three map/dialogue surveys, one glass-first inspection survey, and one focused waiting/question/revisit study. No terminal accusation outcome attempted. | Directly recorded visible text; selected screenshots inspected. 82 question attempts yielded 72 parsed claims and ten refusals across 16 speaker/case combinations. These are sample counts, not probabilities. |
| [Static data and dialogue research](DIALOGUE_RANDOMIZATION_DESIGN.md) | Read-only audit of all 33 preserved archive entries, dialogue/activity/object tables and current remake code. | Measured file structure and text semantics; no original source code or recovered executable algorithm. |
| User guidance | Glass first; use short commands; defer weapon pickup until culprit and crime room are established. | The operating policy for our research. Distinguish it from a mandatory parser prerequisite or an experimentally isolated danger trigger. |

GitHub's source note at the start of consolidation contained games 1–4 on
`docs/original-gameplay-observations` (base commit `099c6af`). The newer working-copy
section 18, covering games 5–7, is included with this consolidation. Neither
researcher's raw original-game transcripts, screenshots nor executable copies are
published here. Source material is paraphrased; private evidence remains ignored.

## Combined understanding of the original

### Investigation and evidence

The player investigates a victim, six suspects, a weapon and a crime room. The
glass occupies a room's carryable-object slot and changes location between cases.
Claude observed inconclusive object examinations and collection restrictions
before obtaining it; with the glass, the game can explicitly identify the weapon.
Codex independently confirmed glass pickup followed by weapon identification.

A crime-room floor examination can produce explicit bloodstain evidence. Claude
reported one such discovery without the glass, so **glass-first is our chosen
workflow, not proof that every floor clue technically requires the glass**.
Ordinary fixture/object examinations also provide flavor or negative findings.
A negative search of one guest does not establish that all searches are useless
or that a guest is innocent.

**Weapon location and crime location may differ or coincide.** Claude's resolved
cases placed them separately. Codex's glass-first transcript identified both in
the study, at item position [69,12] and floor position [73,11]. Those two messages
have text records without dedicated event screenshots. The combined evidence
supports allowing both arrangements, rather than enforcing separation.

### Alibis and deduction

Across Claude's cases, the recurring model is two mutually corroborating innocent
pairs, one solo innocent, and a culprit whose partner/location claim is not
confirmed. Some counterpart statements were not collected and some conclusions
used elimination, so this is a strongly supported observed pattern, not a recovered
universal generation rule. Codex's partial surveys also contain reciprocal pairs,
solo claims and competing claims about one partner.

Compare **speaker, partner and room together**. Two guests naming the same partner
in different rooms expose a conflict worth checking; that alone does not identify
which claimant is lying. Being alone, disliking the victim, pointing at another
suspect, or standing in an odd room does not establish guilt. In the observed
conversations the game leaves the comparison to the player rather than labeling
an account false.

### Dialogue, personality and memory

Both sources describe a delivery opening, a stable solo/shared alibi core and a
commentary ending. Initial responses may refuse; answered repeats generally become
shorter while preserving the core. Codex's 72 answered claims retained one claim
per observed speaker/case combination. In the focused study a refusal was followed
by a successful answer on the next ask.

Mood phrases, refusals and repeat wording vary. Neither researcher established
how the original assigns personalities, whether an entire profile persists, the
selection odds, or the meaning of every table bank. Do not infer seven personalities
from seven ending banks, or statistical independence from modular-looking prose.
Use personality, momentary mood, cooperation, case role and stored claims as
separate concepts in the remake.

### Guests, rooms and activities

Guests can be encountered in different rooms while retaining their historical
alibi. Claude observed room-specific actions including sitting, reading, hiding,
playing music and inspecting the floor. Codex verified two different occupants
using the same piano position/activity after a leave-and-return excursion.

In that focused test, visible markers stayed unchanged during eight seconds of
waiting and six questions plus a search. This does not prove a universally
turn-based clock, that guests never move while watched, or how unseen travel works.
The occupied-room display is not a reliable tracker of remote guests.

Two layouts are observed: a split lower/upper plan with a verified U-shaped stair
transfer, and one wide plan with connected halls. Earlier statements that every
case uses the first layout are superseded. Exact hidden-passage behavior remains
less certain than normal room travel.

### Floor-staring and hidden passages

Claude's latest tally reports four true crime-room leads among eleven floor-staring
sightings, plus a game with no such sighting. That is a small descriptive sample,
not a probability to copy. Treat the pose as motivation to inspect, not as proof,
and provide another way to discover a required clue.

Claude entered the narrow secret corridor through a particular part of the north
wall of the room below it, then found a blind passage where the player marker
vanished and movement led elsewhere. Entry was not consistently repeatable.
Codex has not independently reproduced that route. Neither the exact entrance rule
nor a complete shortcut network is established. Do not promote a successful route
or an invisible marker into a general navigation algorithm.

### Suspicion, stalking and death

The combined record distinguishes an earlier suspicion warning, explicit stalking
messages, and terminal ambushes. Codex saw suspicion warnings without weapon pickup.
Claude's games 6–7 ended roughly 35–45 reported moves after weapon identification,
on entering a room occupied by the culprit; the death speech disclosed culprit,
room and weapon. In game 5, explicit stalking messages followed pickup and Claude
survived approximately 80 further reported moves before concluding the case.

These observations suggest phases and an encounter risk, but **identification,
carrying, isolation, elapsed time and game actions were not controlled separately**.
The claim that identification/pickup starts stalking, or that being alone with the
culprit is the complete kill condition, remains a hypothesis. Survival in a busy
route does not prove other guests provide immunity. Keep the user's cautious order:
glass first, investigate, defer weapon pickup until the culprit and crime room are
established. Do not use the previous notes' automatic-win objective as a research goal.

### Final gathering, outcomes and scoring

Claude reports that assembly gathers the suspects, locks the door and blocks
further ordinary questioning. Three successful cases ended with a confession,
closure text, a move figure and a rank. The wrong-room accusation produced a
confession/correction and a terminal restart/quit prompt without the successful
closure; treat that as a likely failure rather than a demonstrated success.

A death can reveal the solution and explain what the player missed. Confession
styles differed, supporting varied authored reveals, but their exact personality
selection remains unknown. Reported ranks include Master Sleuth at 233 moves,
Professional Sleuth at 323 and Bumbling Sleuth at 549; thresholds, the full ladder
and exactly what contributes a move are unknown. Sent keys, successful movement,
commands and the game's score count must not be treated as interchangeable.

## What to bring into Mansion Mystery

These are proposals for review, not new implementation requirements.

| Keep or adapt | Concrete remake idea | Avoid assuming |
| --- | --- | --- |
| Stable testimony with expressive delivery | Store claims once; author full accounts, concise recaps, recoverable refusals and new-evidence follow-ups. | Every mood change means changed history or guilt. |
| Corroboration and contradictions | Notebook entries compare speaker, partner, room and time. Let the player identify the conflict. | Every future case must use exactly six suspects and two pairs. |
| Room-specific activity | Reuse compatible furniture anchors and approved reading/sitting/inspection poses; give characters feasible journeys. | A refreshed original room display proves continuous travel or justifies teleporting our actors. |
| Investigative tool and stages | Keep the current foyer glass accessible while testing clue interpretation. Separate ordinary observation from forensic confirmation. | Random tool hunting improves pacing or all clues share one gate. |
| Suggestive behavior, reliable evidence | Curious/window/bookshelf poses and floor inspection can suggest leads; record confirmed evidence only after inspection. | Anger, solitude, hiding or looking down reveals the culprit. |
| Escalating tension | Make changes in attention legible and decide explicitly which actions advance risk. Preserve cautious weapon handling. | The original trigger, warning interval or crowd protection is known. |
| Deliberate final commitment | Warn what a gathering changes and preserve notebook access before the player commits. | An accidental parser lockout is desirable design. |
| Personality-compatible reveals and informative losses | Use approved laugh/remorse/defiance/threat artwork when case circumstances justify it; explain failed reasoning. | Every wrong accusation should reveal the whole solution, or every culprit should laugh. |

**Smallest useful next authoring step:** retain The Silent Library's facts and
review varied full accounts, short recaps and temporary refusals for its three
existing speakers. [Dialogue research](DIALOGUE_RANDOMIZATION_DESIGN.md) contains
original draft lines and the proposed content contract. [The brainstorm](GAME_DESIGN_BRAINSTORM.md)
records the broader approved direction. Neither document should turn an observation
into an unrequested implementation or automatic-solving milestone.

## Unresolved questions worth targeted study

- Which event advances each danger phase, and what separates identification from
  carrying? Study only if it will inform a fair, legible remake rule.
- Can guests visibly change position without a room transition in other conditions?
- What produces the floor-staring activity, and how can required room evidence be
  found without it?
- When can searching a person yield useful evidence, and what is KNOCK for?
- What are the recoverability rules for secret-passage entry and blind movement?
- Which original identity/profile/relationship choices affect reply and reveal style?

A small observation that answers one of these is more valuable than maximizing
case count. Full original-game algorithm recovery is unnecessary to author a fair
and coherent replacement.

## Dated Codex research details

The sections below retain the earlier audit, experiment scope and preservation
record. Read them as dated observations; the combined synthesis above incorporates
Claude's newer corrections and takes precedence over outdated open questions.

## Focused behavioral learning — 2026-10-25

The user clarified that the purpose is learning ideas for the remake, not an
automatic win. Existing surveys were compared for consistency, then a 53.82-second
live study collected the glass and observed one guest under passive waiting,
repeated questioning, search and a leave/return excursion. No weapon was picked
up and no gathering or accusation was attempted. The owned emulator was stopped.

Across the earlier 76 replies, 67 contained a parsed alibi and nine were manually
checked refusals. Each of 15 observed speaker/case combinations retained one
partner/room claim. In the focused case, five of six asks restated one claim; a
refusal on the second ask recovered on the third. These are sample counts, not
refusal odds or proof of original profile assignment.

Visible player/guest markers stayed unchanged over eight seconds of waiting and
six questions plus a search. Leaving and returning showed a different named guest
at the same piano position/activity, verified in both entry screenshots. This
supports occupancy and activity reuse; it does not show the journey, the exact
update trigger, or whether passive waiting elsewhere can advance events. The
search found nothing in this single test and cannot establish guilt or inventory
behavior. Raw evidence stays in ignored original-research/behavior-2ee94a3d.

A correction to an apparent pattern in Claude's four-game handoff: our prior
glass-first transcript identifies both the weapon and murder-room floor clue in
the study (item inspected at [69,12], floor inspected at [73,11]). Those two event
messages have text records but no dedicated event screenshots. Weapon/crime-room
separation must therefore remain a possibility, not a universal generation rule.

See [Dialogue research](DIALOGUE_RANDOMIZATION_DESIGN.md) for the proposed design
uses, explicit limits and original draft dialogue. No game mechanics changed.

## Automated live observation — 2026-10-25

The original-game MCP adapter now reads only the displayed video text, navigates
against visible walls and verifies each movement. Three bounded surveys completed
in 67.21–81.26 seconds, covering the two observed map layouts with three different
introduction/roster fingerprints. They sent 532 movement keys and captured 60
responses across 15 encounters (including repeat encounters). These were route
surveys, not solved cases; individual runs reached three to five distinct guests.
Screenshots corroborate the displayed player/guest markers and sampled responses.
Original transcripts and captures remain local in ignored test-results.

Observed behavior: guest markers appear in the currently occupied room; short
questioning and named questioning work; initial and repeated replies can refuse;
answered repeats keep the same companion/location claim while shortening or
changing delivery. Both solo and paired claims occurred. One guest was encountered
in different rooms while retaining the same claimed historical location. In the
split layout, descending beyond the last lower stair cell transfers to the upper
stair box, after which UP returns to the hall. These findings do not establish
personality-bank assignments, refusal probabilities or the complete case generator.

The user's investigation order is now enforced in the survey: first find and
confirm pickup of the magnifying glass, then inspect and interview. Never collect
a weapon during a survey. A further live run completed this order in 136.48 seconds,
with 328 movement keys, 16 dialogue responses and 12 object/floor inspections.
Only the glass was collected. The game identified a weapon and murder-room
bloodstains; insufficient suspects were interviewed to establish the murderer,
and no assembly or accusation was attempted. That run used full examination
commands; subsequent runs use the user's shorter `q <name>` and `ex <keyword>`.

Claude's updated four-game handoff on `docs/original-gameplay-observations` adds
successful accusation evidence, an alibi-pairing hypothesis and secret-passage
observations. Those outcomes were reported by Claude, not independently reproduced
by these surveys. The survey does not enter blind secret corridors or assume a
missing suspect is guilty. User instruction and historical documentation motivate
leaving the weapon until culprit and crime room are established; the acceleration
of stalking after pickup was not experimentally measured here.

## Full data-table audit — 2026-10-25

All 33 ZIP entries match the preserved reference hashes. The archive contains no
program source. A read-only data audit identified 36 delivery/refusal/repeat
fragments, 56 statement endings with seven regularly spaced reveal slots, two
120-record activity tables and two 33-slot object tables. Exact original selection
logic and personality counts remain unknown; table bank counts are not personality
counts. Printable executable data was inspected without disassembly/decompilation.

See [Dialogue and case randomization research](DIALOGUE_RANDOMIZATION_DESIGN.md)
for evidence levels, complete file-family coverage, current-code gaps and a proposed
truth-first replacement. Reproduce with `tools/audit_original_dialogue.py`; decoded
original text remains only in ignored local output. No live original-game behavior
was newly verified and no gameplay implementation changed in this audit.

Inspection date: 2026-10-23 (America/Denver).

## Preservation and inventory

The supplied ZIP is `sleuth.zip` in the user's Downloads directory. The exact source
path and emulator path are recorded in ignored `tools/dos-game-mcp/local.json`.
The original ZIP SHA-256 is:

`b294d2815ee285cd1f03c377af4d866a420676994abcf6348ff75e4ccb4bada8`

The archive has 33 files, 57,959 compressed archive bytes. A separately extracted
reference resides at `reference/original/`. `reference/inventory.json` records sizes,
types, compressed sizes and individual extracted SHA-256 hashes. Launch verifies
all inventoried files and emulator identity, then copies the reference to a unique
disposable run directory. No original executable was decompiled or modified.

| Group | Files | Interpretation |
| --- | --- | --- |
| Executable | SLEUTH0.EXE | DOS MZ executable; no source code found |
| Historical scripts | SLEUTH.BAT, BW.BAT | Game launcher; destructive monochrome conversion utility |
| Character behavior | ACT.V1, ACT.V2, ALIBI1, ALIBI2 | Actions and alibi data per FILES.TXT |
| Rooms | DESCR.V1, DESCR.V2, RMDEF.V1, RMDEF.V2 | Descriptions and borders per FILES.TXT |
| Floorplans | SUSPICT.V0 through SUSPICT.V9 | Display data per FILES.TXT |
| Other game data | SUNDRIES, WEAPN.V1, WEAPN.V2 | Language and possible weapon descriptions |
| Documents | README, SLEUTH.DOC, FILES.TXT, VENDOR.DOC | Startup, controls, inventory and historical distribution terms |
| Promotional/catalog material | PLUG, ORDER.FRM, CATALOG.TXT, FILE_ID.DIZ, DESC.SDI | Non-gameplay supporting files |

BW.BAT overwrites color floorplan data; it was inspected as text and never executed.
Historical document instructions are evidence, not project instructions. All original
content and screenshots remain ignored by Git; no publication is authorized.

## Proven launch path and environment

README directs users to run SLEUTH. SLEUTH.BAT contains `sleuth0`, then `type plug`.
A pre-existing separate local setup has Play Sleuth.cmd and sleuth.conf, launching
the installed DOSBox-X Windows SDL2 build with VGA, 16 MB memory and fixed 1,000
cycles. Its contents were read, not changed. Our adapter reuses the emulator with
an isolated configuration, software surface rendering and fresh game data.

Windows 11 64-bit cannot run this DOS executable directly. The identified dependency
is DOSBox-X 2026.10.01; archive documentation describes an 80-column display and
128 KB memory. Current host: Windows 11 build 26200, Python 3.14.7 (also 3.12.10
installed), Node 24.19.0, Git 2.54.0, Godot 4.7.2 and Codex CLI 0.163.0-alpha.11.1.
Emulator, Godot and uv were absent from PATH; the first two were found locally.

## Directly observed

The captured title identifies **SLEUTH Version 4.45**, Eric N. Miller / Norland
Software. It shows a magenta house outline, cyan text and animated red title lettering.
The main menu offers A Basic Sleuth, B Personalized Sleuth, C Review Instructions;
F10 exits. Title-to-menu advancement using window-targeted ENTER was verified by
inspecting the captured images. Main menu footer says copyright 1983.

Pressing A entered Basic Sleuth. Its captured starting view shows an ochre/gray
house plan, a yellow player marker at the front entrance, a text description of
the recent murder, an open front door and a command prompt. This establishes actual
game startup beyond the animated title; directional movement was not tested in that initial startup check; see the later live surveys above.

Baseline captures and exact launch conditions are stored locally in
`reference/screenshots/`, `test-results/smoke.json` and each run's `dosbox.conf`.
Captures are 720 × 540 through PrintWindow, surface output, VGA, fixed 1,000 cycles,
normal CPU core, aspect correction and no scaler. Timing and mystery randomness mean
these images are reference evidence, not deterministic golden tests.

## Documented mechanics (not all play-tested)

Every game randomizes a murder mystery. Search rooms and objects, find a magnifying
glass, identify the weapon and murder room, compare suspects' alibis, then gather
the suspects and accuse the culprit while holding the weapon in the correct room.
Guests move and may refuse to answer. The murderer becomes suspicious and may kill
the investigator. Dropped weapons can relocate. A room has no obvious entrance.
Personalized mode accepts seven names: six suspects and a victim.

Movement uses four cursor directions; stair direction changes matter. Commands include
EXAMINE/EX, SEARCH, LOOK AT, QUESTION/Q, ALIBI, GET, DROP, GATHER, ACCUSE, GUEST LIST,
HELP, QUIT and RESTART. Use first names for people. Escape/backspace clears the
message line. README documents S at the menu for sound toggling. Sound output,
the parser's precise timing rules, staircase handling, accusation outcomes and
all failure conditions still require gameplay observation.

## Technology recommendation

Keep the existing Godot 4.7.2 project and use GDScript with its 2D tools for room
exploration, sprite movement, object inspection and UI. On 2026-10-23 the user
superseded the first-person 3D plan with a Wild Arms-inspired 2D haunted mansion.
See GAME_DESIGN.md for the supplied-reference analysis and current visual brief.
Implement deduction and mystery generation as independent testable data/state
logic, separated from room presentation. New assets must be authored or licensed;
the DOS binary supplies behavioral reference, not source.
