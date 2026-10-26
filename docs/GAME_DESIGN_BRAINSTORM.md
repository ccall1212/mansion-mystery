# Mansion mystery gameplay brainstorm and future features

The [combined original-game research](ORIGINAL_GAME_ANALYSIS.md) is the shared entry point for Claude's seven-game notes and Codex's observations. This document keeps the detailed remake proposals; source findings and unresolved conflicts are reconciled there.

Recorded 2026-10-23 from the user's gameplay design brief and prior project decisions.
This is the primary record of future gameplay intent for subsequent sessions.
Recording a requirement here does not authorize its implementation or mean it exists.

## Original-game lessons — research update 2026-10-25

The user clarified that studying the original should supply ideas for this game;
building an automatic winner is not the goal. The evidence, caveats and draft
responses are in [Dialogue and case randomization research](DIALOGUE_RANDOMIZATION_DESIGN.md#research-purpose-and-design-lessons--2026-10-25).

**Proposed priorities, not new implementation authorization:**

1. Give the current three speakers persistent claims, varied voice, short recaps
   and recoverable refusals before adding more characters or a large generator.
2. Present present-day activity separately from historical testimony. Use the
   furniture/pose pipeline to make rooms inhabited; avoid extra pose production
   for every delivery phrase. A curious character can inspect shelves or a window
   while facing north, while conversations use suitable conversational facings.
3. Keep the foyer magnifier easy to obtain, distinguish visual hints from verified
   evidence, and let the notebook compare who/where/when claims without naming the
   liar for the player. Telegraph danger and the consequences of a final gathering.

These proposals preserve the user's investigation order: collect the glass first;
identify evidence; leave the weapon until murderer and murder room are established.
Do not infer guilt from anger, being alone, a floor-inspection pose or a present
room. Do not require weapon and crime room to differ: our latest recorded run
placed both clues in the study. Exact original mood and stalking rules remain
unknown and need not be copied to achieve fair, expressive investigation.

## Latest scope decisions — compact house and future map

The user reduced the immediate playable scope to **four main-floor rooms, two
upstairs rooms and one basement room**, growing later. The implemented compact
route uses seven functional rooms plus a main stair hall and upstairs landing;
all nine active backgrounds are unique. This supersedes the larger per-floor
scope below. Existing unused art and furniture annotations remain available.
See [current room review](../test-results/compact-mansion/index.html).

**Confirmed future requirement:** add a small map near the top of the game view
showing the current floor, current room and how many main rooms are on that floor.
Generate it from the active room/portal data so expansion and later random layouts
stay synchronized. Distinguish circulation spaces from main-room counts. Map
visibility of unexplored rooms and exact screen placement remain open. The map is
not implemented yet; TAB currently opens the room directory.

Current baseline corrections: the viewport is now 960×720 over unchanged 480×360
world coordinates. A first authored case with accusations and a written ending
exists; generalized random cases, autonomous schedules and personality systems
remain future work. Older baseline passages below are historical.

## Room-art review follow-up — 2026-10-23

The user accepted the main stair appearance as looking alright and requested rework
of library, dining room, kitchen, upstairs landing, bedroom, study and basement
storage. Record exact door counts and cardinal sides on every background so future
layout pairing can distinguish painted openings from real connections. Remove
unused openings instead of inventing extra rooms just to justify them. Kitchen and
bar are distinct future room types: a bar needs counter-facing stools and usable
seating anchors. Basement storage needs real stored contents and accessible aisles.
Upstairs must arrive from the south/bottom facing north, with carpet branches toward
both bedroom and study. A bathroom remains an alternative future expansion, not an
added room. Full feedback and review policy: [ROOM_ART_REWORK.md](ROOM_ART_REWORK.md).

## 1. Status, scope and related documents

Use these distinctions throughout this document:

- **Confirmed direction:** requested design intent to preserve. It may still require
  implementation and balancing.
- **Implemented baseline:** functionality present in the inspected project.
- **Proposal:** an example, candidate rule or starting value awaiting a decision.
- **Open question:** deliberately unresolved; do not silently turn it into a default.
- **Future requirement:** a dependency or acceptance condition for later implementation.

### Confirmed project direction

Build an original mansion investigation inspired by the DOS-era Sleuth, with an
atmospheric elevated three-quarter pixel-art presentation. Original-game files
inspire interaction types, not copied stories, dialogue, catalogs or implementation.
The locked-house mystery atmosphere is comparable to the user's Knives Out reference;
the remake still needs its own characters, events and solutions.

Start small and make a complete working mystery before expanding. The current
layout direction is about four main rooms per floor, with up to two hallway/stair
spaces if needed. Main and service routes should preserve upstairs/downstairs
identity and return paths. The foyer's north/top doors are the locked front entrance;
there is no playable exit through them. A 10–15-minute case is a playtest target,
not a measured duration or a reason to expand the house immediately.

Character appearance approval remains separate from story roles and personality
assignments. Check with the user before finalizing remaining character looks.
Photo-based likenesses do not establish a real person's fictional personality,
guilt, relationships or behavior. Eleanor is proposed as the opening maid, while
the running prototype still presents her as a house guest.

### Implemented baseline and limits

The inspected project uses Godot 4/GDScript, a 480 × 360 viewport, separate room art,
colliders, actors and UI, and a playable foyer with movement, clock inspection and
Eleanor's authored question menu. Evidence definitions separate identity, condition
and forensics; the foyer has a knife, an innocent broken mirror and a collectible
magnifier. Explicit lens use, object collection, a clue book and limited save/load
exist. Other produced props can be inspected in an authoring review scene.

Four seeded compact mansion graphs remain schematic review alternatives. A separate
[fixed walking prototype](FIXED_MANSION.md) now connects 18 spaces across three
floors using existing art, with provisional room dressing and some passage geometry.
It saves room/position/visits and Eleanor's question history as well as evidence.
Evidence configurations are fixed
examples, not a generated case. Current persistence covers evidence records and
the clock note in the legacy scene; the fixed house extends this as described above.
NPC schedules and ongoing journeys are still future work.
Personalities, a shared event timeline, autonomous room travel, murder-room
selection, accusation outcomes, stalking and endings are future work.

### Reuse these sources rather than duplicating them

| Document | Responsibility |
| --- | --- |
| [Game design](GAME_DESIGN.md) | Visual direction, historical proposals and foyer behavior |
| [Development plan](DEVELOPMENT_PLAN.md) | Delivered milestones and current implementation priorities |
| [Mansion blueprints](MANSION_BLUEPRINTS.md) | Compact seeded layouts, floor memory and logical traversal limits |
| [Mansion asset requirements](MANSION_ASSET_REQUIREMENTS.md) | Per-layout doorway/stair art gaps |
| [Environment art guide](ENVIRONMENT_ART_GUIDE.md), [room roster](ROOM_ROSTER.md) | Rendering, layers and available backgrounds |
| [Object variants](OBJECT_VARIANTS.md), [examination descriptions](EXAMINATION_DESCRIPTIONS.md) | Existing object data, examination stages and persistence |
| [Evidence QA](EVIDENCE_ASSET_QA.md) | Evidence milestone validation and limitations |
| [Cast name review](CAST_NAME_REVIEW.md), [character art guide](CHARACTER_ART_GUIDE.md) | Current identities, appearance approvals and art conventions |
| [Original game analysis](ORIGINAL_GAME_ANALYSIS.md) | Observed versus documented original-game behavior |
| [Testing](TESTING.md) | Existing verification workflows and reports |

Some older design/roster passages describe superseded proposals. Use the current
cast review and latest compact-house notes for their respective topics. This
document records future gameplay; it does not replace those specialist records.

## 2. Dynamic rooms, furniture and placement

**Confirmed direction:** the mansion should behave like an inhabited environment,
not a sequence of static pictures. Each background needs backend metadata for
furniture, inspectable objects, interaction points and suitable character positions.
Examples include chairs, beds, bookshelves, windows, doors, fireplaces, tables,
bar stools and rugs. A painted chair alone is not a usable seating position.

Characters should be able to sit, read, drink at a bar, stand at windows, kneel
to examine something and otherwise interact naturally with available furnishings.
Spawn locations for potential weapons, ordinary inventory and clues must respect
room identity, accessibility, furniture and object suitability. Random placement
must not hide critical evidence behind an unreachable prop or block an exit.

**Future requirements:** metadata must describe compatible activities, actor/prop
anchors, orientation, occupancy, approach space, collision and foreground occlusion.
These are conceptual needs, not a finalized schema. Seated feet, bodies and furniture
must align; placement must avoid overlap and floating characters.

Characters should travel between rooms and may be on their way somewhere when the
detective arrives. Leaving a room must not freeze its occupants permanently in the
last visible positions. Location, current journey, pose, conversation and activity
must agree with shared game state, including after return or load. Whether offscreen
events advance by schedules, discrete turns or continuous simulation is unresolved.

The long-term aim is reusable environment tagging that supports randomized props,
characters and room activities across all compatible mansion layouts.

### Directional furniture labels and pose compatibility

**Implementation update:** the [furniture catalog and background mapper](FURNITURE_IDS.md)
now supply 84 orientation IDs, reusable contact templates, per-background instances,
editable actor facing/contact/approach points, disabled contacts, save/registration,
pose requirement lists and a runtime lookup/overlay. Automated character staging,
pose availability matching, reservations and occlusion remain future work. The
requirements below retain their design context; the initial annotation format is
now implemented in `assets/furniture/` and `src/furniture/`.

**Additional confirmed direction, recorded 2026-10-23; future implementation:**
furniture labels must describe type and orientation separately. This is a shared
dependency between environment assets, furniture metadata, character sprites,
pose selection and procedural room/group staging. The complete system is not
implemented or commissioned by this documentation update.

#### Shared naming convention

Use lowercase `snake_case` for semantic labels. Use `north`, `east`, `south` and
`west` as the canonical room directions: north is screen up/top, east right,
south down/toward the viewer and west left in the current fixed camera convention.
Human-facing tools may display up/down/left/right, but must normalize those aliases
instead of storing a second conflicting vocabulary. These conventions define
meaning; the current annotation JSON and coordinate contract are documented in
[FURNITURE_IDS.md](FURNITURE_IDS.md). Full procedural staging structures remain open.

| Concept | Convention and meaning |
| --- | --- |
| Furniture type | Stable type such as `chair`, `bed`, `bookshelf`, `desk`, `bar_stool`, `window`, `doorway` or `fireplace`; keep individual asset/instance IDs separate |
| Furniture facing | Direction its usable front faces, where applicable; describes the object, not an occupant |
| Bed axis | `east_west` for horizontal or `north_south` for vertical |
| Headboard edge | `west`, `east`, `north` or `south`, consistent with the bed axis |
| Asset view | `front`, `side` or `rear` describes the authored depiction; it does not substitute for room orientation |
| Interaction side | The side from which an actor can approach/use the object; may vary by anchor and must not be inferred solely from furniture facing |
| Actor facing | The direction the character faces while using a particular anchor; independent of furniture facing |
| Lying alignment | Body axis and head-toward direction; a lying pose needs more than a standing facing label |

Thus the four chair directions are `chair` plus furniture facing `west`, `east`,
`north` or `south`. A horizontal bed uses axis `east_west` with headboard edge
`west` or `east`; a vertical bed uses `north_south` with headboard edge `north`
or `south`. Reject incompatible combinations such as a horizontal bed with a
north headboard rather than interpreting them differently in different assets.

A bookshelf or desk facing the player has its usable front facing `south`; facing
away is `north`. A side-view bookshelf needs an appropriate facing and authored
`side` depiction, not just an ambiguous label saying "side." A stool facing a
counter needs a relationship to that counter's interaction point, resolved to a
canonical actor direction. Windows, doorways and fireplaces need explicit usable
sides rather than an assumption that actors always approach from below.

Do not encode every combination into one growing furniture-type list. New types,
activities and pose families should extend the vocabulary without changing the
meaning of existing labels. Inapplicable orientation concepts should remain
explicitly inapplicable, not acquire a misleading default.

#### Reusable anchors and interaction positions

**Future requirements:** define named anchors relative to the furniture asset's
documented origin and orientation wherever practical. An anchor needs a local
offset, approach/access side, required actor facing or body alignment, posture,
compatible activity/pose information and occupancy/clearance requirements. Placing
a furniture instance should resolve its anchors into room positions without
manually rebuilding every anchor in each room. Room-specific obstacles still need
validation; a reusable anchor does not guarantee a clear approach in every layout.

| Furniture | Positions and compatibility to describe |
| --- | --- |
| Chair | Seating/contact position, approach, seated facing and compatible seated pose family |
| Bed | Sitting and lying anchors, accessible sides, body axis and headboard/head alignment |
| Desk | Chair/seated-work position and standing interaction position on the correct usable side |
| Bookshelf | Reading/book-inspection position with the actor facing the shelves |
| Bar stool | Seated position, counter relationship, facing toward the counter, feet/body alignment |
| Fireplace | Standing and kneeling inspection points on a valid accessible side |
| Window or doorway | Standing/inspection/interaction points and the side from which each is usable |

For example, a chair whose front faces `west` needs a compatible west-facing seated
pose. A south-facing desk can have a user anchor south of it with the actor facing
`north` toward the desk. These examples show why furniture orientation and actor
facing cannot share a single field. A west-headboard bed needs the lying actor's
head toward `west` along an `east_west` body axis, not a generic sideways idle pose.

#### Asset and character-pose contracts

As assets are produced, document each furniture type, orientation, depiction,
origin, usable anchors and compatible poses in its asset metadata. Character pose
metadata must identify supported posture/action, facing or lying alignment,
contact points and any constraints involving clothes, carried objects or props.
Pose selection must match the anchor and current activity, including reading at a
desk and facing an intended conversation partner. Do not seat a character sideways,
lie them across the wrong bed axis, face them away unintentionally, or leave their
feet/body floating above the stool or chair.

Use authored orientation variants when needed. Rotation or mirroring is acceptable
only after checking projection, lighting, depth/occlusion, anchor transforms and
visual correctness in the existing renderer. A fixed-view pixel-art chair cannot
automatically become a convincing differently facing chair through 2D rotation.
Do not assume poses can be mirrored: handedness, clothing, held items and other
asymmetries may require separate artwork. If no compatible pose/asset exists, do
not force an invalid pairing; another valid position/activity or a documented
unsupported combination is needed. The fallback policy remains to be designed.

#### Random layouts and group staging

When generating or entering a room, future placement must determine which furniture
instances exist, which anchors are unoccupied, which poses the character supports,
the resulting facing/alignment and whether the approach/occupied footprint leaves
space for other actors and player travel. Reserve a position for its occupant;
multiple logical seats need distinct usable anchors. Update reservations when
characters move or change activity so an old seat is not falsely occupied.

Gatherings should use this same compatibility/occupancy information around chairs,
beds, desks, shelves, bars and other furnishings, rather than a separate collection
of hardcoded character coordinates. Validate non-overlap, navigation/exit clearance,
furniture contact and appropriate conversation orientation. Reaction poses during
a reveal must remain compatible with the occupied furniture or use a valid
transition to a different position.

#### Inspection required before implementation

Before choosing a schema or coding placement, inspect the current engine's room
coordinates, asset origins/loading, transforms, character feet/contact anchors,
depth sorting, collision and pose representation. Check the existing 480 × 360
presentation and fixed camera against each proposed furniture anchor convention.
Decide how asset-local orientation variants map to room coordinates and how
unsupported poses are represented. No new classes, file format or automatic
rotation/mirroring behavior is prescribed here.

Future validation should cover four chair directions; horizontal and vertical beds
with each valid headboard edge; desks/shelves from the supported views; stools
facing their counter; standing/kneeling fireplace anchors; transformed local
anchors; incompatible-pose rejection; asymmetric art that cannot be mirrored;
and multi-character staging without blocked paths or floating bodies.

## 3. Personalities and stable identities

**Confirmed direction:** assign each participating character a personality at new
game creation. Assignments can differ between games but remain stable throughout
one playthrough. Appearance and identity can stay constant while mystery role,
relationships, behavior and dialogue vary. A personality is not a guilt indicator:
nervous people can be innocent and friendly people can deceive.

**Candidate types, not a final list:** friendly/cooperative; nervous/anxious;
arrogant; secretive; hot-tempered; observant; gossipy; deceptive; forgetful;
calm/analytical; remorseful/emotionally fragile; manipulative/threatening.

Personality must influence more than wording. Future behavior should account for:

- Speech, volunteered information, cooperation and withholding information.
- Annoyance thresholds and reactions to repeated questioning.
- Facial expressions, body language, pose choice, movement and social behavior.
- Responses to accusations, exposure as murderer and the detective being caught.

The initial personality count, whether traits combine, and how they interact with
relationships and roles remain open. Do not reroll traits on conversation or room entry.

## 4. Stories, timeline, alibis and questioning

**Confirmed direction:** characters need individual stories, whereabouts,
relationships, knowledge and alibis. Author original narrative combinations.
Statements must suit the speaker's personality, location, current pose, relationship
and knowledge. Someone cannot report an event they could not reasonably witness
or learn about. Deceptive statements must be intentional parts of a mystery.

Repeated questioning may make a character annoyed, angry and eventually unwilling
to speak, where appropriate. The threshold, recovery rules and whether genuinely
new evidence reopens conversation remain undecided. Refusal must not remove the
only route to a critical fact; provide alternative evidence or other witnesses.

### Future dialogue portraits — recorded 2026-10-24

**Later scoped implementation, 2026-10-24:** the user authorized a simple first
version using enlarged existing idle sprites. Current case conversations, prototype
guest statements and Eleanor now use a shared portrait layer behind the dialogue
box. Source images are unchanged; no automatic conversational turning, new
expressions or timer were added. Native previews for eight current speakers:
[idle portrait review](../test-results/dialogue-portraits/index.html). The broader
activity-aware portrait requirements below remain future work; current framing
was approved for now by the user on 2026-10-24; see
`assets/characters/dialogue-portrait-approval.json`.

**Confirmed future direction; not implemented:** use a visual-novel-style
conversation presentation inspired by *Doki Doki Literature Club*. Enlarge the
speaking character's **existing current sprite**, placing it behind or partially
behind the dialogue box so the character appears to emerge from the interface.
Preserve the current pose and expression; portrait presentation alone must not
substitute idle artwork, reinterpret the design or require new character art.

- An east-facing character appears toward the **upper-left** of the dialogue box.
- A west-facing character appears toward the **upper-right** of the dialogue box.
- Position using visible bounds, transparent padding and visual center, rather
  than assuming the file center is the character center. Keep text, controls and
  important interface elements unobscured.
- Apply a consistent presentation scale across the cast while accommodating
  individual proportions and silhouettes. Do not stretch poses or enlarge seated
  characters merely to force an identical bounding-box height.
- Remain compatible with directional artwork, future expression/personality
  variants and character-specific dialogue.

**Before implementation:** inspect the current dialogue UI, sprite renderer,
source landmarks, UI scaling and layer order. The current first-case controller
uses text panels; it does not implement this portrait composition. North/south
placement, unusually tall/wide silhouettes, kneeling/seated framing, clipping and
the relationship between portrait scale and world scale remain open decisions.
Reuse the [directional pipeline plan](CHARACTER_DIRECTIONAL_PIPELINE_PLAN.md) and
[measurement standard](CHARACTER_MEASUREMENT_STANDARD.md); no overlay architecture
or new portrait asset format is selected by this requirement.

### Future conversation orientation — recorded 2026-10-24

**Confirmed future direction; not implemented as a general NPC system:** when a
conversation starts, the character should generally turn toward the detective's
current position **if appropriate directional artwork for the activity exists**.
Select the correct authored direction; never automatically mirror asymmetric
clothing, handedness or props. Do not replace every activity with standard idle.

Meaningful actions/reactions take priority over automatic turning. Preserve the
pose and intended gaze when the character is inspecting suspicious/bloody material
on their fingers, reacting with confusion/curiosity to an object, examining a
possible weapon/evidence, studying the floor for blood, reaching toward a bookshelf,
inspecting a wall, or expressing significant fear/suspicion or another reaction.
Use a contextual variation or transition only if it supports that action. Speaking
must not abruptly divert attention from evidence. Seated and other furniture-bound
actions must retain the orientation/contact constraints in section 2.

If no appropriate directional/activity variant exists, retain the closest suitable
existing pose and its supported orientation rather than breaking animation or
forcing an invalid turn. Position, current activity, gaze, facial expression and
the case's stable personality assignment must inform future selection. The older
Eleanor-specific addressed behavior is not a complete cast-wide implementation.

**Open decisions:** direction-selection boundaries, how personality influences
turning, eligible transition timing, head-only versus whole-body turns, whether to
restore prior facing/activity after conversation, and framing exceptions. The
portrait should display the resulting selected conversation pose/expression;
portrait placement must not independently select a conflicting pose.

### Alibi balancing

Build a coherent underlying timeline before producing accounts of it. Different
characters may remember, omit or deliberately misrepresent different intervals.
Two people in the same room should not automatically solve the case for the player.
One might describe a shared portion of the evening while another gives an incomplete
or misleading account of a different interval.

Do not assign unrelated random alibis that accidentally make the culprit immediately
obvious. Do not remove all contradictions either: discoverable, meaningful
inconsistencies are central to deduction. The player needs evidence and alternate
investigative routes with which to recognize and test those inconsistencies.

**Future requirements:** distinguish ground truth, personal knowledge, claims,
deliberate lies and the player's discovered information. Test each account against
the timeline and its intended deception, not just against dialogue grammar.

## 5. Poses, animations and action continuity

**Planning audit update, 2026-10-23:** the complete source-linked
[pose audit](CHARACTER_POSE_AUDIT.md), [reaction matrix](CHARACTER_REACTION_MATRIX.md),
[production workflow](CHARACTER_POSE_PRODUCTION_WORKFLOW.md) and
[reusable prompt](CHARACTER_POSE_PRODUCTION_PROMPT.md) now record the required
coverage. Char's manifest is initialized for planning only; no new pose art or
personality/guilt assignments were produced. All room contacts, including disabled
ones and catalog-only orientations, are accounted for. These documents do not
implement the future systems described below.

**Confirmed direction:** provide each character with suitable action and reaction
poses. The planned library should cover:

| Situation | Required range of poses/actions |
| --- | --- |
| Movement and rest | Idle, directional walking, sitting in different furniture |
| Everyday activity | Reading, drinking at a bar, conversing, listening |
| Looking and investigating | Pictures/clocks/objects, looking down, kneeling at the floor, examining a finger after touching a surface |
| Emotional response | Annoyed, angry, nervous, confused, frightened, startled |
| Accusation and exposure | Innocent accusation reactions, shocked witnesses, remorseful/furious/deceptive/threatening reveals |
| Danger | Stalking, door-locking, trapping the detective and capture poses |

Pose, dialogue and current action must agree. An angry threat should not use a
relaxed idle unless that controlled calm is an intentional characterization.
Preserve previously requested individual poses, such as Chris removing his hat to
scratch his head, as variants of the same identity rather than extra cast members.
The existing weak walking animation still needs its own later art pass.

This is a production requirement, not a claim that these animations exist. Shared
pose coverage, character-specific exceptions and the first production subset need
decisions after appearance review.

## 6. Group gatherings and accusation staging

**Confirmed direction:** gatherings should use room geometry and furnishings.
Multiple seats must accommodate multiple characters; reading chairs and bar stools
need activity-compatible occupants. Conversation groups should look believable.
Assign each attendee an individual position, pose and orientation, with enough
space to avoid excessive overlap, floating or characters blocking one another.

When the murderer is exposed, witnesses should transition into individual reactions
such as shock, fear, anger or disbelief according to their personalities and knowledge.
They should not all adopt one identical reaction pose.

**Future requirements:** use environment tags and occupancy to stage the group,
reserve reachable positions, and coordinate reaction transitions. Capacity limits,
gathering eligibility and behavior when a room has too few seats remain open.

## 7. Murder-room selection and floor investigation

**Confirmed direction:** each new mystery selects an appropriate murder room.
The player discovers it through investigation rather than receiving its identity
at the start. A room/location owns its evidence; a character's departure cannot
erase that evidence.

**Proposed hint:** a character occasionally looks down at the floor. The detective
may approach and examine that location. A clean location can give an ordinary
floor description; a relevant location may reveal traces such as blood or other
configured evidence. Looking down is a lead, never a guaranteed murder-room signal.
Characters can look down for legitimate reasons unrelated to the crime.

### Hint timing and discoverability

The user recalled the original hint becoming more likely after roughly one or two
passes through the rooms. This is reference inspiration, not a verified timing rule
in the project's original-game analysis.

**Proposal:** make hints eligible after sufficient exploration of the accessible
mansion. The visited-room threshold, repeat-visit contribution and any further chance
are undecided. Desired pacing avoids an immediately obvious room clue in every game
without forcing aimless wandering.

**Open distinction:** decide whether progress gates only the NPC hint, a particular
examination step, or some other presentation. Do not silently equate hint eligibility
with creating or deleting evidence. A reliable normal discovery path must exist
even if the hint never occurs; its precise rules still need design.

## 8. Rare accidental discoveries and difficulty

**Confirmed direction:** characters may rarely discover an existing clue during
a plausible interaction. For example, after touching a bed, wall, lamp, book or
carpet, a character might notice reddish material on a finger and comment on its
source. Similar leads can involve residue, dust, fibers or marks rather than blood.
This is an illustrative event, not mandatory final dialogue or a confirmed substance.

The source object must actually contain the clue. The action, pose and personality-
appropriate reaction must agree. The lead should help without necessarily solving
the case. The player can investigate the object, follow up on the observation or
use a magnifier where required. Normal investigation must still find the evidence;
an accidental event can never be its sole discovery route.

### Proposed starting chances — not finalized balance

| Difficulty | Accidental discovery chance |
| --- | ---: |
| Easy | 5% |
| Medium | 1% |
| Hard | 0% |

Define the unit of a roll before implementing these values. An eligible character-
object interaction is one candidate; per-character, per-visit or per-investigation-
event opportunities remain alternatives. Never roll continuously every frame.
Eligibility, repeat-roll limits and timing must make the event genuinely rare.

Evidence must remain consistent across difficulties. Hard removes these accidental
shortcuts, not the underlying evidence or the ability to solve the case. Whether
other aspects of difficulty change cast size, rooms or behavior is unresolved.

## 9. Evidence, variants and examination tools

**Confirmed direction, partly implemented:** keep these concepts distinct:

| Concept | Meaning |
| --- | --- |
| Object identity | Which underlying object this is |
| Visible physical condition | Bent, worn, dull, broken, unusually clean, missing a component, etc. |
| Hidden forensic state | Configured traces or other details, independent of visible condition |
| Player discovery state | What has actually been inspected, collected or revealed |
| Tool requirement | Which examination action/tool can reveal a detail |
| Description stage | Initial, detailed, tool-assisted, discovery and repeat observations |

Potential evidence includes blood traces, scratches/dents/marks, missing components,
unusual cleaning/wear, fibers/residue, moved objects and tampering. Not every object
is suspicious and not every clue involves blood. A knife might be dull, bent, very
clean or have a perforated handle; those are possible content variants, not a claim
that each already has art. Hidden evidence is configured separately.

The magnifier reveals only an eligible object's configured detail after explicit
use. Possessing the tool must not expose every clue or invent blood on clean items.
Support new objects and observations through data rather than unrelated interaction
code changes. Follow [object variants](OBJECT_VARIANTS.md) and
[examination descriptions](EXAMINATION_DESCRIPTIONS.md) for the implemented contract;
extend it deliberately when room clues or case-specific assignments require more.

## 10. Accusations, reveals and endings

**Confirmed direction:** support distinct outcomes based on actual guilt, available
evidence, character knowledge and assigned personality. These situations need a
future ending library; they are not eight implemented or fully specified branches.

| Situation to support | Narrative/presentation intent |
| --- | --- |
| Correct accusation | Expose the actual murderer; select an appropriate response and resolution |
| Wrong accusation | Give the innocent target a believable individual reaction |
| Innocent accused, murderer still unidentified | Preserve the unresolved danger and other characters' responses |
| Murderer voluntarily reveals after another accusation | Let a state-appropriate reveal interrupt or follow the mistake |
| Remorseful exposure | Regret, explanation and acceptance of responsibility |
| Hostile exposure | Fury, threats or hostility; possible restraint by others is a proposal |
| Broader-plan reveal | Manipulation or a prepared plan can lead to a loss |
| Stalking capture | Trapping the detective leads into its own loss sequence |

False accusation is not yet defined as an automatic loss or a free retry. Likewise,
correct identification is not yet defined as unconditional victory. Evidence
requirements, event priority and branch eligibility need decisions.

Outcomes should combine role, personality, authored dialogue, pose, animation/scene
transition, witness reactions, sound/visual effects and a clear win/loss/other ending
state. A data-driven library is preferable to manually scripting every cast/trait
combination, but its structure must be checked against the eventual case model.

**Example emotional range, not final scripts:** remorseful confession; hostile
confession; an innocent person's premature accusation while the culprit exploits
the distraction; a manipulative reveal that triggers a prepared loss. None should
play unless the underlying mystery and current state justify it.

### Future countdown and timeout endings — recorded 2026-10-24

**Confirmed future direction; not implemented:** introduce a countdown, with an
intended **10-minute default**, configurable separately for each difficulty.
Per-difficulty durations are not specified yet. This time limit is a new gameplay
requirement, distinct from the earlier unmeasured 10–15-minute playthrough target.
Do not reinterpret that older pacing target as an implemented timer.

If time expires before the detective successfully solves the case, choose randomly
among eligible generic failure endings. At minimum preserve these two:

| Ending | Required result |
| --- | --- |
| The Killer Escapes | The detective runs out of time; the murderer escapes before being caught. |
| The Police Arrive | Police reach the mansion before the detective has identified a suspect; insufficient information prevents an arrest and the case remains unsolved. |

These are future additions to the outcome library above. The first authored case
currently has evidence-gated accusations, retries and a written resolution; it has
no countdown or timeout ending selector. Do not change those prototype rules as
part of recording this requirement.

**Open implementation decisions:** when the countdown starts; difficulty values;
whether time continues during conversations, clue-book reading, inspection/lens
use or accusation selection; and which room transitions, pause states or sequences
pause it. Define how successful resolution and timeout are ordered on the same
update. A timeout must not interrupt or replace an ending already in progress;
the future ending/state model needs a single resolution guard. Exactly when an
accusation becomes a successful solve and when that guard is acquired remain open.

Determine eligibility/weights for generic failures rather than playing an ending
that contradicts established case facts. In particular, “The Police Arrive” as
described assumes no suspect has been identified; treatment of an identified but
unproven suspect or an earlier withdrawn accusation is unresolved. An eventual
escape resolution also needs a coherent explanation alongside the locked-house
premise; recording it does not unlock the front door or add an exterior route now.
Keep timeout distinct from the stalking/capture losses in section 11. Future
save/load and reproducibility planning must address remaining time, pause state,
selected ending and prevention of repeated ending rolls; policies are not selected.

## 11. Suspicion, stalking and capture

**Confirmed direction:** the murderer should become more dangerous as investigation
progresses. The user's recollection that the original used steps is inspiration;
the exact original suspicion/timing mechanic remains unverified.

**Proposed escalation:** exploration advances a configurable progress measure;
the murderer begins stalking; an encounter under defined conditions allows a trap;
the murderer locks the door behind the detective; a personality-specific threat and
visual sequence precede an attack and a clear game-over transition.

Steps, room visits, elapsed turns, investigation actions or a combination are
candidate progress measures. Thresholds, how stalking is communicated, trap eligibility,
escape/deterrence and whether encounters are avoidable remain open. Triggering rules
must be understandable and reproducible in tests, not arbitrary untraceable losses.

The capture presentation should support a door-locking action/animation, threatening
pose, personality-specific dialogue, dramatic lighting/atmosphere and appropriate
sound where available. A brief red flash and background lightning are proposed
effects, not implemented requirements with settled timing or intensity.

## 12. Personality-driven outcomes and witness reactions

The same identity may be innocent in one game and the murderer in another, with
different stable personality assignments. Murderer responses can include confession,
remorse, hostility, panic, smugness, manipulation or desperate escape attempts.
Innocent suspects need varied responses to false accusations too.

Do not make anger synonymous with guilt or calmness synonymous with innocence.
An innocent hot-tempered person can be furious; a calm culprit may remain composed.
Personality should alter words, body language and choices during exposure and
capture without overriding ground truth or inventing unsupported knowledge.

Group reactions should vary by identity, personality and the relationships/knowledge
established in that case. Reuse the staging requirements in section 6 and the outcome
requirements in section 10 rather than maintaining separate contradictory ending rules.

## 13. Fair randomization and persistence

**Confirmed direction:** each game must create a logically solvable, mutually
consistent configuration of murderer, murder room, character roles, personalities,
relationships, stories, alibis and evidence. Movement and witness accounts must
respect the underlying timeline. Critical clues need valid discovery paths even
without accidental discoveries or optional hints.

**Future validation requirements:** distinguish intentional lies from accidental
contradictions; reject impossible knowledge, unreachable evidence and combinations
that cannot be solved. Verify that location, activity, dialogue, placement and pose
agree. Personality alone must never identify the culprit.

**Proposal:** use a reproducible case seed, extending the existing seeded blueprint
approach. Mansion selection alone does not reproduce a mystery that does not exist
yet. The future save/debug record should retain the generated case assignments,
timeline, character journeys, conversations/refusals, evidence/discovery state,
difficulty and progress/escalation state. Random event opportunities and outcomes
must be reproducible or persisted so loading/revisiting does not silently reroll them.
Exact save schema, simulation clock and random-stream policy are future decisions.

## 14. Future architecture and candidate milestone order

The current separation of presentation, mansion-session data and evidence data is
a useful starting point. The following are responsibilities to coordinate, not
newly prescribed classes, files or technologies:

| Responsibility | Integration requirement |
| --- | --- |
| Room metadata and furniture points | Canonical type/orientation labels, local anchors, capacity, approach, pose compatibility and occlusion; see section 2 |
| Character movement and occupancy | Room travel, offscreen continuity and timeline-consistent locations |
| Pose selection and group staging | Action/personality/geometry-compatible placement and reactions |
| Personality and relationship assignments | Stable within a game; independent of appearance and guilt |
| Stories, alibis and questioning | Truth, knowledge, claims, lies, annoyance and refusal state |
| Object variants and hidden evidence | Extend the existing examination model without leaking clues |
| Murder-room selection and hints | Persistent room-owned clues and a guaranteed discovery path |
| Difficulty and accidental discovery | Explicit eligible events and bounded, testable probabilities |
| Suspicion and stalking | Progress measure, escalation, trap eligibility and capture outcomes |
| Accusation and endings | State-appropriate branches, dialogue, poses and witness reactions |
| Countdown and terminal state | Difficulty-configured time, activity/pause rules and one eligible resolution; see section 10 |
| Conversation presentation | Activity-safe directional selection followed by portrait layout; see section 4 |
| Save and reproducibility | Preserve the case and ongoing state across room changes and reloads |

**Shared future dependencies, recorded 2026-10-24:** conversational orientation
resolves an available pose/expression using position, activity, furniture and
personality; the portrait uses that same resolved sprite. Both consume existing
directional assets and shared measurement conventions. Dialogue, examination,
room transitions and accusations expose their current state to the future timer
according to an agreed pause policy. Timer expiry and other resolutions coordinate
through the ending lifecycle so an active ending cannot be interrupted or selected
twice. Inspect the actual controllers before choosing shared structures; this
describes coordination, not a prescribed new class, clock or implementation.

**Proposed sequence, not authorization to implement now:** first connect a compact
ground-floor slice and author a small solvable case with existing evidence. Then
establish room tags and a coherent timeline, add a limited personality/dialogue/pose
subset, and validate reproducible case combinations. Add group accusations and a
small ending subset before optional accidental hints and stalking. The exact minimum
cast, features and order must be agreed in a focused implementation brief. Do not
attempt all systems at once or expand floors merely because backgrounds exist.

Future acceptance should include a complete case solved without random shortcuts,
repeat questioning without a permanent evidence dead end, offscreen travel/re-entry,
room clues surviving NPC departure, capacity-safe gatherings, valid ending branches
and seed/save reproduction of a reported failure. These are planned checks, not new
tests executed during this documentation task.

## 15. Outstanding decisions

Keep these unresolved until explicitly discussed:

| Area | Questions |
| --- | --- |
| Case size | How many characters participate? How many rooms are accessible at each difficulty? |
| Movement and time | How often do characters move? How do schedules and alibis relate to time, room visits and player actions? |
| Countdown | Difficulty durations, start/pause rules, same-update solve/timeout ordering, save/load policy and timeout-ending eligibility? See section 10. |
| Dialogue portraits | North/south placement, nonstanding/tall/wide framing, visual-center alignment and consistent scale? See section 4. |
| Conversational facing | Which activity-preserving turns/transitions exist, how does personality affect selection, and when is prior orientation restored? See section 4. |
| Personalities | How many initially? Which traits affect behavior, dialogue and endings? Can traits combine? |
| Murder room | How is it selected? What guarantees its discovery in every valid case? |
| Floor hints | When do they become eligible? What is gated: hint, examination step or presentation? |
| Accidental clues | What makes an interaction eligible? Is a roll per interaction, character, room visit or investigation event? What prevents repeated farming? |
| Difficulty | Are 5%/1%/0% appropriate once the roll unit is defined? What else, if anything, changes by difficulty? |
| Tools | Which clues require the magnifier, and how is access to required tools guaranteed? |
| Questioning | What causes refusal, how long does it last, and what alternative paths preserve solvability? |
| Accusation | How does the player recognize sufficient evidence? What must be supplied, and what are the consequences of a mistake? |
| Gatherings | Which rooms can hold the selected cast, and what happens when seats/approaches are insufficient? |
| Furniture and poses | Which asset-local origin/anchor representation fits the engine? Which orientations need separate art, which transforms are visually safe, and how should missing compatible poses be handled? |
| Stalking | What triggers it? How is it signaled? Can the player escape or deter the culprit? |
| Endings | Which accusation/capture outcomes belong in the first playable case? How do interruptions and branch priority work? |
| Minimum prototype | Which of these systems are essential before the first complete small mystery can be playtested? |

### Continuity rule for later sessions

Read the implemented baseline and linked specialist documents before planning work.
Keep examples and proposed balance values marked as proposals. Record subsequent
user decisions here with a date and update the implementation plan only when scope
is agreed. No gameplay implementation or new art was requested by this brief.


## South-facing murderer reveal poses

Selected on 2026-10-25: triumphant evil laugh, remorseful crying after an unintended killing, and defiant pointing accusation (revised from refusal). All three south-facing artwork variants are approved; the remorseful version is full sobbing with both hands wiping tears. Reuse ordinary surprised, nervous, sad and defensive poses for other reveal moments. These variants are selected only after the story establishes the murderer and response; they do not assign permanent personalities or imply guilt during ordinary interaction. Artwork approval is separate from runtime fit and reveal logic.

Additional approved south-facing confrontation pose (2026-10-25): furious threat, with a forward stance, clenched fists and full shout. This expands the selected reveal/confrontation artwork to four variants. Runtime fit and story selection remain pending.
