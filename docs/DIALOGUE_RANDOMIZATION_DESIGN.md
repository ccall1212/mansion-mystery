# Dialogue and case randomization research

2026-10-25. Static audit of all 33 files in the user's original-game archive,
plus the current remake controllers and prior brainstorm. This document records
findings and an implementation proposal; it does not add randomized cases to the game.

## Findings and confidence

The archive contains a DOS executable, data and documentation, not program source.
All archive entries were read and matched byte-for-byte against the preserved local
reference and its recorded hashes. No original program or batch script was run,
and no executable was disassembled or decompiled. Printable executable data was
read to identify statement-building fragments; this does not recover control flow.

Three kinds of evidence must remain distinct:

- **Data observation:** directly measurable records and text semantics.
- **Historical documentation:** what the original instructions say happens.
- **Inference/proposal:** plausible selection behavior or our replacement design.

The original ZIP, decoded text, executable strings and supporting material remain
local and ignored. This document paraphrases structure; it is not a copied dialogue
bank. Reproduce the audit with `.venv/Scripts/python.exe tools/audit_original_dialogue.py`.
Its detailed outputs are under ignored `test-results/original-dialogue-audit/`.

| Files | Direct findings | What remains unknown |
| --- | --- | --- |
| ALIBI1 | 36 records of 70 bytes; three consecutive banks of 12. Each bank contains six delivery openings, two refusal responses and four repeated-question responses. A backslash terminates each padded record. | Exact bank assignment, probabilities, refusal/repeat thresholds and recovery rules. |
| ALIBI2 | 56 records of 188 bytes; seven banks of eight. Each bank's last slot is an admission/reveal, at zero-based indices 7, 15, 23, 31, 39, 47 and 55. Other slots include denials, claimed opportunity/motive, referrals and shared-alibi commentary. | Whether a bank belongs to an identity, behavioral type or another case attribute; eligibility and selection rules for its first seven slots. |
| ACT.V1 / ACT.V2 | 120 records of 55 bytes each. Each table repeats five banks of 24, with twelve pairs of context-related alternatives per bank. V1 has 56 distinct texts; V2 has 50. Activities correspond to furniture and room contexts. | Bank meaning, selection weights, duration, travel timing and event overrides. Five activity banks do not establish five personalities. |
| DESCR.V1 / DESCR.V2 | Two environment families, descriptions, entry messages, room names, object keywords/examination responses and seven default name triplets per family before the DOS end marker. Bytes after that marker include stale trailing data. | Exact runtime indexing and whether identity slots constrain any other assignments. |
| WEAPN.V1 / WEAPN.V2 | 33 records of 220 bytes in each. Eleven groups of three slots; fields contain presentation text, a short name, two keyword slots and an examination description, with a ten-byte gap. V2 has three empty short-name slots. | Exact slot-to-room placement, weapon selection distribution and relocation algorithm. Empty candidates must not be treated as real objects. |
| SUNDRIES | Command aliases map to numeric action codes, followed by generic object keywords and fallback responses. Questioning and asking for an alibi share a command code. | Whether deeper context produces additional branches after shared dispatch. |
| RMDEF.V1 / RMDEF.V2 | Numeric room/border data paired by suffix with the other environment tables. | Complete geometry schema and its runtime use were not decoded in this dialogue audit. |
| SUSPICT.V0 through V9 | Ten display-data files, each 2,816 bytes. The historical monochrome script copies two base files over the other display variants. | Exact display-selection conditions. Ten files are not evidence of ten distinct case layouts. |
| SLEUTH0.EXE | DOS MZ binary. Readable data includes solo/shared-location statement fragments, accusation prerequisites, culprit admissions, escalation/stalking messages and solution/status labels. | RNG implementation, truth-table construction, role selection, name substitution, mood changes and branch priority. Embedded strings establish available wording, not reachable execution paths. |
| SLEUTH.DOC / README / FILES.TXT | Document randomized games, moving/moody guests, alibi contradictions, seven entered names (six suspects and one victim), evidence gathering and accusation prerequisites. | These mechanics were not newly verified in live gameplay during this audit. |
| SLEUTH.BAT / BW.BAT | Historical launcher and destructive display-conversion script, inspected only as text. | Neither supplies mystery-generation source. |
| VENDOR.DOC / PLUG / ORDER.FRM / CATALOG.TXT / FILE_ID.DIZ / DESC.SDI | Distribution, marketing and catalog material; no personality/timeline generator source found. | Historical instructions are not authorization to execute or republish anything. |

ALIBI2 uses a victim-name marker and another-person marker, respectively
`#+++++++++` and `@+++++++++` (38 and 15 occurrences). Their meaning is inferred
from sentence context; actual substitution implementation is unavailable. Our
replacement should use named fields with explicit character IDs instead.

## How the original appears to combine dialogue

The data and readable executable fragments support this **inferred assembly model**:

1. A delivery opening, or a complete refusal.
2. A factual-sounding core about being alone or with another guest in a room.
3. A selected commentary ending involving the victim or another suspect.
4. A repeat-question modifier when applicable.
5. A separate confession/reveal branch once the relevant accusation conditions hold.

This is not a recovered executable algorithm. In particular, randomly concatenating
any opening, core and ending would be wrong: some fragments already close a speech,
some admit guilt, some require a partner, and others assert specific relationships.
One denial even contains a hypothetical admission phrase, so keyword matching alone
cannot classify confessions. The seven reveal slots were manually read in full.

The important reusable idea is to separate case-dependent content from delivery,
then filter before choosing. Do not reproduce the DOS padding or its sentence text.

## Keep these assignments separate in our remake

| Layer | Examples | When chosen or changed |
| --- | --- | --- |
| Identity | Stable ID, display name, approved appearance, own pose catalog | Persistent across games; cast selection may vary. |
| Case role | Victim, culprit, witness, other suspect | New case only; never inferred from appearance/personality. |
| Personality | Cooperation, temper, confidence, verbosity and habitual delivery | Sample once per case from compatible profiles; preserve on load. |
| Relationship | Victim bond, dispute, debt, loyalty or private secret | Case generation with explicit directed facts. |
| Ground truth | Crime time/location/weapon and actual movements/events | Construct and validate once; never reroll on questioning. |
| Personal knowledge | Direct observations, own actions and explicitly learned reports | Derived from timeline, visibility and information transfer. |
| Claims | Truthful testimony, permitted omissions and authored deliberate lies | Built from knowledge/deception plans and stored. |
| Conversation state | Topic counts, evidence already discussed, irritation, refusal | Updates through explicit conversation events. |
| Live activity | Current room, journey, reading, seated, observing or inspecting | Future activity scheduler; not retroactive alibi generation. |
| Reveal response | Laugh, remorse, defiant accusation or threat | Case motive/circumstances plus eligible personality weights, then persisted. |

The same Char can be an anxious innocent in one case and a confident culprit in
another. A temperamental innocent may shout. The culprit can have a convincing
partial alibi, while an innocent may be alone. Do not make an animation a hidden
truth flag. Appearance-based fictional personalities remain unassigned.

## Proposed generation order

1. Select a case template compatible with the active mansion, available evidence
   and selected cast. Use the existing compact mansion rather than adding rooms.
2. Select participating identities and designate a victim and culprit. Detectives,
   excluded designs and a victim without a usable representation need explicit
   eligibility rules. Do not assume the original six-suspect count is our final count.
3. Assign personality profiles separately from guilt. Author compatible motives,
   relationships and reveal responses; do not independently roll contradictory traits.
4. Instantiate a constrained crime timeline: when the culprit and victim meet,
   travel feasibility, attack, weapon handling, movement and any cleanup.
5. Schedule innocent activity and encounters around that timeline. Give each
   alibi an interval, room, activity and witness coverage. Shared time need not
   cover the entire crime interval. Store known gaps instead of inventing witnesses.
6. Derive each character's knowledge with provenance. Hearing a report is distinct
   from seeing an event. Presenting new evidence can legitimately teach new facts.
7. Author culprit lies/omissions deliberately. Optional innocent secrets need
   their own explanations and independent exculpatory evidence. Begin with a small
   controlled lie set before adding unreliable innocent accounts.
8. Place weapon, room trace and corroborating evidence on valid reachable anchors.
   Ensure tools and alternative discovery paths exist without lucky hint events.
9. Check the intended solution against all candidate suspects and admissible crime
   reconstructions. Reject ambiguous, impossible or clue-inaccessible combinations.
10. Realize eligible dialogue from stored facts, claims and voice. Store line IDs,
    chosen substitutions and an authoring version, so repeated questions/save-load
    do not silently produce a different account.
11. Validate and persist the completed case. Only then supply future staging with
    compatible activity/pose requests. General NPC activity staging remains deferred
    until character pose production is complete.

Use a master seed with separate named random streams for case construction, voice
variation, activities and cosmetics. Merely seeding everything through one RNG
would let an added decorative choice change the murderer. Derive streams with a
documented stable algorithm/version and save the actual generated state as well.

## Dialogue records and selection contract

Suggested authoring fields, not implemented schema:

| Field | Purpose |
| --- | --- |
| id / topic / intent | Stable line identity, question subject and semantic meaning. |
| requires / forbids | Case phase, known facts, relationship and claim predicates. |
| asserted_fact_ids / claim_ids | Exact propositions the line communicates, including an explicit lie when allowed. |
| knowledge_sources | Observation, self-knowledge, report or evidence-presentation event. |
| voice_tags / weight | Personality-compatible wording and bounded variation. |
| slots | Typed speaker/victim/partner/room/time fields resolved from case IDs. |
| pose_request | Semantic activity, emotion/gesture and desired facing. |
| effects | Topic heard, irritation update, fact discovery or explicit refusal/recovery event. |
| fallback | Safe eligible response when no authored variant matches. |

Selection should be: resolve question context; compute eligible intents from
knowledge and claims; filter lines; select voice variant; resolve typed slots;
emit text, assertions and pose request; apply explicit effects once. A refusal
must terminate the answer rather than being followed by an alibi paragraph.
New evidence needs its own topic/context version so it is not mistaken for an
identical repeated question. Requests without valid targets cannot reveal hidden IDs.

Do not interpolate separately randomized clauses with incompatible syntax. For
the first version, author complete short responses around a shared semantic core,
or use tightly typed segments with explicit punctuation rules. Any generative
wording assistance belongs in authoring; facts must not be invented at runtime.

Example semantic content, entirely original proposal: during interval T, A was
in the library with B, but B left before the interval ended. A cooperative line
may volunteer the departure; a guarded line can initially omit it, provided the
claim accurately states the covered interval. Another witness or evidence must
expose the gap. A volatile delivery can express irritation while preserving the
same room, partner and times. The gap is a case fact, not a personality effect.

## Refusals, revelations and poses

Repeated questioning may change delivery and cooperation, not history. Irritation
thresholds, recovery and evidence-based reopening remain balance proposals. Require
an alternative route to every essential clue if refusal is possible; no permanent
dead end from exhausting one character's patience. Persist decisions rather than
allowing save/load or room re-entry to farm a favorable cooperation roll.

| Context | Existing Char artwork to request | Eligibility |
| --- | --- | --- |
| Ordinary account | Neutral, friendly talk, nervous, confident or curious | Voice/current mood; independent of guilt. |
| Doubt or challenged account | Suspicious, defensive or surprised | Actual conversation context; no automatic confession. |
| Floor activity | Looking down or kneeling reach | Target geometry and fitted contact; not an alibi by itself. |
| Triumphant reveal | South evil laugh | Established culprit plus an authored triumphant response. |
| Unintended killing/remorse | South sobbing, both hands wiping tears | Established culprit and compatible case circumstances. |
| Blaming others after exposure | South defiant pointing accusation | Authored reveal/confrontation branch. |
| Explicit hostile threat | South furious threat | Eligible confrontation/escalation event. |

All four reveal/confrontation images have artwork approval. Runtime scale/contact
and scene fit remain separate. These sprites do not prove that accusation, threat
or ending logic exists. Other characters must resolve to their own approved art;
do not use Char's sprite as a universal reaction or demand more art for every line.
Missing compatible art falls back to an eligible neutral pose, never the wrong facing.

South-only reveal staging needs actors positioned to face the detective/viewer.
The world sprite and portrait should consume the same resolved pose per the
brainstorm's existing conversation-orientation contract.

## Current code and safe next implementation slice

- `src/characters/prototype_roster.gd` seeds room/position and statement-index
  choices from `assets/characters/prototype/statements.json`. These are temporary
  room-flavor accounts, not mutually validated alibis or personality assignments.
- `src/mystery/case_state.gd` loads one fixed `first-case.json`, returns authored
  statements, tracks question history and checks a fixed suspect/weapon/room tuple.
  It permits retrying wrong accusations as a prototype rule; that is not proof of
  the original game's behavior or a final ending design.
- `src/mystery/case_controller.gd` presents accounts, evidence requirements,
  accusation and the written ending. It does not currently select the new reveal
  poses or personality dialogue.
- `src/mansion/fixed_session.gd` persists NPC assignment state. Its current schema
  is not yet a generated timeline, knowledge graph or conversation-state schema.

First proposed slice: preserve The Silent Library's facts and solution, add four
small unassigned voice profiles (cooperative, anxious, proud/reserved, volatile),
and author equivalent accounts, repeat-question responses and innocent/culprit
reaction branches. Choose profiles once at case start and persist them. Review
the dialogue content before changing the live case. Keep clue logic intact.

Then introduce one constrained case template whose identity bindings, crime
location/evidence and witness timeline can vary coherently. Initially keep cast
size fixed rather than attempting every 17-design combination. Only expand
templates, traits and schedules once that small generator is demonstrably fair.
Neither slice is implemented by this research task.

## Acceptance checks for future implementation

- The same seed and content version reproduces assignments, claims and reveal style.
- Different cosmetic/voice choices cannot alter case truth or consume its random stream.
- Every identity can be innocent or guilty when eligible; no profile dictates guilt.
- Every asserted fact is known or is an explicitly recorded lie; hearsay stays labeled.
- Timelines obey reciprocal routes, travel duration and physical co-location constraints.
- Corroboration covers the same interval; conflicting accounts are deliberate and discoverable.
- Solving constraints leave exactly one intended culprit/reconstruction after the
  guaranteed clue set, rather than merely comparing against a hidden answer tuple.
- Critical clues remain reachable under allowed refusals and without random hints.
- Repeating a question, changing rooms and saving/loading preserve facts and selected variants.
- Normal accusations against innocents cannot trigger culprit admissions or reveal art.
- Exposed-culprit, false-accusation, interruption, threat and ending transitions obey
  explicit eligibility/priority; a terminal outcome cannot fire twice.
- Missing pose, invalid slots or no eligible wording yields a safe response without leaking truth.

## Remaining original-game verification

Only controlled gameplay observations can establish exact repeat/refusal behavior,
bank-to-character assignments, event timing and live branch conditions without
program source. Future observations should use the existing owned-process MCP
adapter, record actual screenshots and keep original dialogue/captures local.
Do not claim original odds, a personality count, or a recovered randomization
algorithm from these tables. We have enough evidence to design an original,
consistent replacement without copying or reverse-engineering those unknown rules.
