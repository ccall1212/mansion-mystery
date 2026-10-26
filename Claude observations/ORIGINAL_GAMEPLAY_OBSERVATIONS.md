# Original SLEUTH 4.45 — live gameplay observations

Written 2026-10-25 for hand-off to Codex. Source: two live playthroughs of the original
DOS game (SLEUTH0.EXE, "Basic Sleuth" mode) under the existing DOSBox-X build, plus the
shipped data/doc files and this repo's `docs/ORIGINAL_GAME_ANALYSIS.md` and
`docs/DIALOGUE_RANDOMIZATION_DESIGN.md`. The earlier docs list live behaviour as
unverified; this file is the first live evidence.

Conventions:
- **Observed** = seen on screen in a captured game.
- **Documented** = stated in `SLEUTH.DOC`/`README`, not independently seen.
- **Inferred** = my reading; treat as a hypothesis.
- Original dialogue is paraphrased or reduced to templates. Per `AGENTS.md`, the original
  text stays out of the repo. Nothing here modifies the game, executable or reference copy.

Four games were played. Games 1-2 are covered in sections 1-16. **Games 3-4 (both won) were
added later and are in section 17, which also corrects a few earlier statements.** Where
sections 1-16 and section 17 disagree, section 17 wins.

---

## 1. The goal

Three things must be found, then presented together:

1. **Murderer** — one of six suspects.
2. **Murder weapon** — one carryable object, identified with the magnifying glass.
3. **Murder room** — where the killing happened. It is not necessarily the weapon's room.

The accusation sequence is: carry the weapon, stand in the murder room, **ASSEMBLE**, then
**ACCUSE <first name>**. The player is under a hidden clock; see section 9.

## 2. Menu and screen

- Title screen, then the main menu: **A** Basic Sleuth, **B** Personalized Sleuth (type seven
  names: six suspects and one victim), **C** Review Instructions. F10 exits; S toggles sound.
- The game screen shows **two floor plans side by side** (ground floor left, upper floor right),
  with a four-to-five-line message area and a `>` prompt underneath.
- The player is a yellow smiley sprite. Guests are cyan sprites, drawn **only when they are in the
  player's current room** (observed in both games; no remote tracking). After ASSEMBLE all six
  appear in a cluster in the room.
- Plan colours change between games (game 1 ochre, game 2 magenta) while the geometry stayed
  identical. This fits the ten `SUSPICT.V0`–`V9` files (two layouts × colour variants). Inferred.
- Closed doors are drawn as a thin line across the doorway. Seen after ASSEMBLE ("door is now
  locked") and at the end of game 1 (the loss).

## 3. Movement

- Four arrow keys, one grid cell per press. In the 720×540 capture a cell is about 18 px wide and
  21 px tall.
- Rooms are entered through gaps in the walls. Entering a room prints its description. Walking
  through the halls prints the hall text.
- There are **no doors to open and no commands needed to move**.
- **Stairs are a U-shape across both plans:**
  - From the ground-floor hall, press DOWN into the stair box (three cells).
  - Pressing DOWN once more at the bottom cell **switches floors**, and you appear at the bottom of
    the upper-floor stair box.
  - Then press UP three times to reach the upstairs hall.
  - Going down is the same in reverse: DOWN from the upstairs hall into the box, DOWN at the
    bottom to switch, then UP out to the ground hall.
  - Overshooting DOWN switches floors again. Messages: "lower steps" / "upper half of the
    staircase". A guest can bump into you on the landing.
- Inferred, not proven: each arrow press and each command counts as a game turn (see section 9).

## 4. The house (identical layout in both games)

Ground floor, with hall x-centre at the middle of the plan and the front door at the bottom:

| Position | Room | Notes |
| --- | --- | --- |
| NE | Kitchen | Door to the hall on its west wall. A gap in its south wall leads to the pantry. |
| East-middle | Pantry | Reached **only through the kitchen**. |
| SE | Conservatory | Piano, rug and a bust. Door to the hall. |
| NW | Dining room | Door to the hall. |
| West-middle (narrow) | **Hidden room** | No visible entrance; see section 10. |
| SW | Living room | Door to the hall. |
| Stairs | Bottom-left of the hall | U-shaped; see section 3. |

Upper floor:

| Position | Room |
| --- | --- |
| NW | Master bathroom |
| West-middle | Library |
| SW | Guest room (door near the stairs) |
| NE | Master bedroom |
| SE | Study |

All ten visible rooms had the same names and descriptions in both games. Three or four
decorative objects and the **single carryable object** differ per game (section 5).

## 5. Room contents

A room description has up to four parts:

1. Fixed text (name and fixtures).
2. **One carryable object**, introduced as lying, sitting or hanging somewhere. Only this
   object can be picked up and checked as a weapon.
3. One line per guest present, naming them and an activity ("X is searching through the tins",
   "X sits at the piano playing a funeral march", "X is lying on the divan"). These match
   `ACT.V1`'s room-specific activities.
4. Occasionally a special line: **"X is staring at the floor."**

Carryables seen, by room (game 1 / game 2):

| Room | Game 1 | Game 2 |
| --- | --- | --- |
| Kitchen | silver bottle opener | frozen leg of lamb |
| Pantry | tin of salmon | can of vichyssoise |
| Conservatory | bust of Beethoven | **bust of Mozart (the weapon)** |
| Living room | ornate hourglass | silver candy dish |
| Dining room | candelabra | **magnifying glass on the floor** |
| Study | brass plaque | pewter mug |
| Master bathroom | bottle of vitamins | jar of cold cream |
| Library | potted fern | potted fern |
| Master bedroom | gold-gilt mirror | gold-gilt mirror |
| Guest room | **magnifying glass on the floor** | marble egg |

Inferred from this and from `WEAPN.V1/V2` (eleven groups of three): each room has a small pool
of candidate objects and one is chosen per game. The **magnifying glass takes over one room's
carryable slot** and its location changes each game.

## 6. Commands (observed unless noted)

| Command | Behaviour |
| --- | --- |
| `EXAMINE x`, `EX x` | Examines an object or the floor. Also `LOOK AT`. |
| `GET x`, `TAKE x` | Picks up the object. See the gating in section 7. Documented: `PICK UP`. |
| `DROP` | Documented. Not tested. The weapon may land somewhere else. |
| `QUESTION x`, `Q x` | Asks a guest. **`ALIBI` and `QUESTION` are the same command.** |
| `Q` alone | Questions the **nearest** guest. Seen working in game 2. |
| `SEARCH name` | Guest allows it grudgingly and "you find nothing" (both guests searched). Documented use: finding evidence on a person. |
| `SEARCH room` | Refused. Examine specific objects instead. |
| `GUEST LIST` (or `PEOPLE`) | Lists the seven names. Order differs between games. No locations. |
| `ASSEMBLE` (or `GATHER`) | Pulls every suspect into your room; the door locks. |
| `ACCUSE name` | Starts the accusation. Needs the assembled room (section 8). |
| `HELP`, `QUIT`, `RESTART` | Help text; restart returns to the **main menu** (observed after the game ended). |
| `KNOCK` | Present in `SUNDRIES`; effect not tested. |

Generic examines (door, table, wall, shelves) return one-line "nothing unusual" answers. An
object that is not in the room gets "I don't see anything like that around here". Using the
**first name only** is enough for people. Escape clears the message line. Documented (not
tested): arrow keys do not work while you are typing a command, until it is entered or cleared.

**Proximity:** questioning and searching need you **within about two cells** of the guest. Too
far away gives "<name> can't hear you from all the way over there" or "too far away to search".
Examining the floor a guest is staring at gives "I can't see what <name> is looking at from all
the way over here" when you are far.

## 7. The magnifying glass and the weapon

- **Before the glass:** examining a carryable gives one of two non-committal replies, both
  saying it is hard to be sure without a magnifying glass ("doesn't look like the murder
  weapon" / "don't see anything unusual"). Which reply you get depended on the noun I typed.
  Fixtures give "nothing unusual".
- **`GET` is refused for carryables until you have the glass**, with a reminder to examine them
  with the glass first. Seen for the bottle opener in game 1. The glass itself can be taken at
  once ("You are now carrying the magnifying glass").
- **With the glass**, each non-weapon carryable gives its own flavour line (fern needs water,
  mug is old, mirror is broken, egg is decorative, soup, lamb, empty dish, heavy glass jar).
- **The weapon** triggers a **red** message saying there are traces of blood and "this must be
  the murder weapon". After that, `GET` works ("You are now carrying the murder weapon").
- The documents say the murderer gets nervous if you carry the weapon too early. **Not seen.**
  I carried it only for the last ~20 turns of game 2.
- In game 2 the weapon sat **in its ordinary room (conservatory)**; the killing was in the
  study. Neither room was the hidden room.

## 8. The murder room and the accusation

- **Floor examine in the murder room** prints a red "bloodstains... scene of the murder" message
  (game 1, kitchen, found **without** the glass). Floor examine elsewhere returns one of three
  "nothing unusual" lines ("can't see anything unusual... I am rather nearsighted" is one).
- **"X is staring at the floor" is a lead, not a guarantee.**
  - Game 1: Gerald was staring in the kitchen, and the kitchen was the murder room.
  - Game 2: staring guests stood in the living room, guest room and kitchen, and **none** of those
    was the murder room (the study). I did not examine the study floor.
  - So the clue is **unreliable or a decoy**. The user's own rule of thumb is to examine floors
    only when someone is described staring. That fits the game 1 hit and the game 2 misses.
- **ASSEMBLE** works in any room, even before you know the murder room. Message: the suspects
  have gathered here to hear your accusation, and the door is locked.
- **ACCUSE, correct culprit and weapon held, wrong room (observed in game 2):**
  - The culprit "stands up and exclaims" and **confesses, naming the weapon and victim**.
  - He then states the **true room**, corrects you ("not here in the living room"), and the game
    goes straight to the quit-or-restart prompt.
  - Whether that counts as a loss is unclear. No score or win text appeared.
- Correct room/weapon/culprit (a win) and an innocent accusation were not tested.
  The documents say you must carry the weapon and be in the murder room.

## 9. The stalking clock

- At some point a message appears at the bottom of the screen: **"The murderer has grown suspicious
  of your investigation!"** It appeared **once** per game.
- Game 1: it appeared after about **146 arrow presses and ~40 commands**. I was killed roughly
  **100 presses later** (about 250 total). The kill happened while I walked toward the upstairs
  bathroom. The game switched to **"Do you want to quit or to restart?"** and a door was drawn
  closed. I did not capture the death message.
- Game 2: the warning appeared at about 190 presses *sent* (many were dropped or blocked, so the
  real count is lower). I was still alive ~120 presses later and ended the game myself by
  accusing.
- **Conclusions (inferred):**
  - The clock is turn-based, not wall-clock. Only the warning's one-time appearance and the
    loss were seen.
  - The exact trigger and the interval to death are unknown and may be random.
  - The warning is a hard signal the player can act on. Everything else about stalking is
    undecoded.

## 10. The hidden room

- It sits directly above the living room. No doorway is drawn.
- **Game 2:** I entered by standing in the living room's top row at the **fourth column from the
  left** and pressing UP. I passed through the wall and ended inside the narrow room. A few moves
  inside, I was **moved to the upper-floor staircase** (it looks like a secret passage).
- On two later tries at the same column, and at the neighbours, UP was **blocked** and I could not
  repeat it. Reason unknown: carrying the weapon, the warning state, timing or randomness.
- The user states that the secret entrance is reached by "moving upwards in the room below it".
  That is consistent with the first success.
- I did not see the room's description, contents or any guest there.
- The documents say the murderer often hides the weapon there and sometimes kills there.
  **Neither happened in my two games.**

## 11. Guests, movement and activities

- Victim and suspects come from seven default names in Basic mode. **The victim changes**: Maude in
  game 1, Victoria in game 2. The guest list order also differs.
- The suspects are **restless**. Examples: Edward in the pantry, then the conservatory (game 2);
  David claimed the dining room but was in the kitchen; Gerald claimed the living room but was in
  the dining room; Earl was in the pantry in game 1 and never seen in game 2. **Where a guest stands
  is unrelated to their alibi.**
- Guests were never seen leaving a room in front of me; I only compared screens.
- Activities come from furniture and room (pantry: tins; conservatory: piano; living room: divan).
  Activity text carries no clue about guilt.

## 12. Questioning and alibis

### 12.1 Reply shape (observed many times)

`<speaker + mood phrase> "<alibi core> <commentary ending>"`

- **Mood/delivery phrase:** shrugs, forces a laugh, whispers, replies angrily, replies wearily,
  etc.
- **Alibi core**, always one of:
  - "I spent the (entire) evening **alone in the <room>**."
  - "I spent the (entire) evening **with <name> in the <room>**."
- **Commentary ending (separate sentence block):** one of a pool. Seen kinds include:
  - denies motive or opportunity;
  - admits to disliking the victim;
  - admires the victim in secret;
  - tells you to leave;
  - points at another suspect ("question <name>"; "<name> said the victim would be better off dead");
  - claims an airtight alibi;
  - asks "is that all you wanted to know?".
- The ending is chosen **independently of the core**, but is **compatible with it**. Alone-endings
  say "I suppose that looks bad" / "nobody saw me". Two-person endings say the alibi is airtight
  or that the pair never left. This matches the `ALIBI1` (openings/refusals/repeats) and `ALIBI2` (endings with a
  victim/other-person marker) tables.
- Endings that point at another suspect name a **different person** from the speaker, and in the
  cases seen it was a person who was **not** the speaker's alibi partner.

### 12.2 Refusals and repeats

- **Refusal.** Some asks produce no alibi: "ignores you completely", "turns angrily and hisses
  that you should mind your own business", "pays no attention". Observed for Earl, Esther and
  Gerald. Asking again works; refusal **never blocked** a statement for good.
- **Repeat.** A second ask gives a short fixed form: "Like I said before, <core restated>. I can't
  think of anything else to add." The **core facts are identical** and the ending drops out.
- **Mood variety.** Openings, refusals and repeat phrases vary a lot between asks. The data file
  has banks of 12 (six openings, two refusals, four repeat phrases). I did **not** verify how
  banks map to people, moods or events.

### 12.3 The data collected

Game 1 (victim Maude, guests Victoria, Earl, Gerald, Esther, Edward, David):

| Speaker | Claim |
| --- | --- |
| Earl | with David, conservatory |
| Victoria | alone, library |
| Gerald | with Esther, study (repeated identically) |
| Edward | with Gerald, **library** |

- Gerald says Esther/study, Edward says Gerald/library: **Edward and Gerald contradict**.
- Esther and David were never questioned. I was killed before I could resolve it.
- The culprit and the weapon were not found in game 1.

Game 2 (victim Victoria, guests Earl, Gerald, David, Edward, Esther, Maude):

| Speaker | Claim |
| --- | --- |
| Esther | with David, dining room (also repeated) |
| David | with Esther, dining room (**matches**) |
| Edward | with Maude, guest room (repeated twice) |
| Maude | with Edward, guest room (**matches**, twice) |
| Gerald | alone, living room |
| Earl | never found or questioned |

- Result: **Earl was the culprit, the study the room, the Mozart bust the weapon.** The solution
  was revealed by accusing Earl (a guess by elimination).
- The pattern fits the documented rule. **Innocents come in mutually consistent pairs** (each
  names the other and the same room). A **solitary innocent** (Gerald) can exist. I did **not**
  see how the culprit's own claim contradicted the others, because Earl was not questioned.

### 12.4 What this says about the design

- The case structure looks like: a victim, a culprit, and the remaining five arranged into
  **partner pairs plus at most one solo**. That would place the culprit either as the odd one
  out or as the person who names a partner who disagrees.
- **"Alone" is not suspicious by itself.** The solo innocent was a normal-sounding suspect.
- **Contradictions are checked by comparing statements**, not by evidence: no clue text told
  me anyone lied.
- The documents' rule ("the murderer's alibi contradicts the others") is **partly confirmed**
  by the game 1 contradiction (Edward/Gerald) and game 2's consistent pairs, but one clean
  solved example is still missing.

## 13. Guest-list and cast notes

- Default names: Victoria, Earl, Gerald, Esther, Edward, David, Maude (victim or suspect
  depending on the game). Surnames: Crompton (Victoria, Earl, Maude), Brisbane (Gerald, Esther,
  Edward), Malone (David).
- The victim's death is announced with the house name ("the Crompton estate") and "The body was
  removed by persons unknown from the murder scene." The player begins at the front door.

## 14. Practical notes for tooling

- The game drops keystrokes sent faster than about **250 ms apart** under the repo's fixed 1,000
  cycles setting. Several runs of arrow presses silently lost moves.
  **Check positions after movement, not just delivery.**
- Reading the player position from screenshots works: the yellow sprite is a simple colour
  blob. It disappeared from detection once in the hidden room.
- After `RESTART` or the loss prompt, only the menu keys respond.
- I used my own session-owned driver and a disposable copy of the game. The emulator PID I
  launched was stopped at the end. No original files were modified.

## 15. Open questions

1. How exactly does the secret passage work, and where does it lead?
2. What are the stalking interval and trigger? What does the death message say?
3. Is the weapon ever in the hidden room or outside its natural room? Was Earl in it?
4. Does a correct accusation in the correct room end with a victory screen? Does an innocent
   accusation lose?
5. Does the staring-at-the-floor guest correlate with the murder room, or is it random?
6. Do the carryable objects come from fixed three-item pools per room?
7. Are the 12-record `ALIBI1` banks tied to people, moods or events?
8. What does `SEARCH <person>` find when the person holds evidence?
9. What does the "Personalized" mode change, other than names?
10. What does `KNOCK` do?

## 16. Ideas for the remake (clearly separate from the facts above)

- **Case generator:** choose a victim and culprit, a murder room and a weapon room that may
  differ, then arrange the other five suspects into mutually consistent partner pairs and one
  solo, with a culprit statement that conflicts with at least one other.
- **Player loop that worked in the original:** find the glass, check carryables and floors, ask
  everyone, compare alibis, collect the weapon, assemble, accuse.
- **Gating:** the glass should gate weapon identification and pick-up.
- **Confession on a wrong room** is a good, fair hint: it reveals the true room and costs the
  accusation.
- **Warning before the loss** is worth keeping: one visible message gives the player a last
  window.
- **Floor-staring as an unreliable lead** matches the docs' "never a guaranteed signal".
- **Repeat questioning** should restate the same facts in a shorter form and never block
  progress; a refusal should be a retry, not a lock-out.

---

## 17. Games 3 and 4 (both won) and corrections

### 17.1 Results

| Game | House | Victim | Culprit | Weapon | Murder room | Result |
| --- | --- | --- | --- | --- | --- | --- |
| 3 | Winston estate (second house, section 17.3) | Carlotta | Daryl | backgammon set (master bedroom) | family vault | **Won: "case closed after 323 moves", rank "Professional Sleuth"** |
| 4 | Brisbane estate (first house, blue) | Gerald | Maude | jar of cold cream (upstairs bathroom) | upstairs guest room | **Won: "case closed after 233 moves", rank "Master Sleuth"** |

Both wins used the same sequence: find the glass, find the weapon and the murder room, walk
the weapon into the murder room, `ASSEMBLE`, `ACCUSE <first name>`.

### 17.2 What the win looks like (observed twice)

- The accused culprit **turns to the player and confesses in a mood-specific speech**. Game 3's
  was proud and triumphant; game 4's was a shrug, "it seemed the only decent thing to do".
  These match the seven reveal slots in `ALIBI2` (one per bank). Which reveal a person gets
  was not predictable from anything I could see.
- The next line is the game's own result: **"The case is closed after N moves. You now rank as
  a <rank>."** Ranks seen: *Professional Sleuth* (323 moves) and *Master Sleuth* (233 moves).
  The number looks like a **score input** (inferred: fewer moves, higher rank). The full rank
  ladder is unknown.
- The screen keeps all six suspects drawn in a row in the room with the door shown closed.
- The game's "moves" figure was within about 15 of my count of (successful arrow presses +
  commands). I could not reconcile it exactly, so I do not know precisely what increments it.

### 17.3 The second house ("Winston estate"), seen in game 3

The house is not always the same layout. Game 3 was a different plan (matching `DESCR.V2`,
`RMDEF.V2`, `ACT.V2`, `WEAPN.V2`). **Observed layout: one wide floor with a west hall and an east
hall, each with its own stair box at the bottom**; the front door messages say the stairs lead
up to the west hall. The map is **one drawing** and I never needed to switch floors to reach any
room, so treat it as a single-plane house.

| Area | Room | Carryable seen in game 3 |
| --- | --- | --- |
| West column, top | Master bedroom | backgammon set (**weapon**) |
| West column, middle (narrow) | Secret corridor | loose brick |
| West column, bottom | Parlor | brandy snifter |
| Top middle (wide) | Ballroom, with a bandstand | broken violin |
| Inside, off the west hall | Family vault (safe, desk) | hammer (**murder room**) |
| Centre, lower left | Sewing room | **magnifying glass on the floor** |
| Centre | Dining hall (wet bar) | blue vase |
| East column, top | Bathroom (hot tub) | shattered shampoo bottle |
| East column, middle | Butler's bedroom | toy train engine |
| East column, bottom | Kitchen | bottle of cooking sherry |

Notes:

- A cross-corridor links the two halls near the top. The ballroom opens off it.
- Room doorways print a short **threshold message** ("This doorway leads into the master bedroom"),
  then the full description once you step inside.
- House selection, estate name and colour all vary per game. The estate takes **the victim's
  surname** (Crompton in games 1-2, Brisbane in 4; Winston in 3, inferred).
- Default cast in the second house: Daryl Winston, William Seton, Margaret Donleavy,
  John Donleavy, Vanessa Shore, Harriet Seton, plus Carlotta (victim in game 3).
  So the **cast is tied to the house**, not global.
- Activities in this house come from `ACT.V2` (hiding under the bandstand, kneeling at the
  safe, napping in a chair, resting in the far corner).

### 17.4 The secret passage (corrects section 10)

Seen in games 2 and 3 and now understood better:

- The entrance is a wall cell in the **north wall of the room directly below the narrow room**. It
  opens when you press UP at **one specific column**: the 4th column from the west in game 2's
  living room, the 3rd in game 3's parlor. The column differs by house; it may differ by game.
- In both successful entries my previous move was LEFT along the room's top row before pressing UP.
  In game 2 the same column then **refused me on three later tries** (once with the weapon in
  hand). So the door's behaviour is not fully explained; **I could not make it repeat in game 2**.
  In game 3 I used it once and did not retry.
- Inside, the narrow room is **"a secret corridor which spans the length and breadth of the
  house"**. It showed one carryable (a loose brick) and a hiding guest (William, under cobwebs).
  It is a **dead-end strip of about six cells** apart from the passage described next.
- At one cell near the east end, pressing UP **drops you into the "secret passageway"**. The
  message says "walking through a blind corridor", and **the player sprite vanishes from the map**
  while you are inside. You move blind with the arrow keys. Moving UP three times from that
  cell brought me out, **visible again, in a different part of the house**: the upper staircase in
  game 2, the **sewing room** in game 3.
- So the secret passage is a **hidden shortcut/teleport network**, not just a room.
- The murderer did not use it in either game. Neither the weapon nor the murder room was in it.
  Game 3 had the **magnifying glass in the room where the passage exits**, which looks like luck.

### 17.5 Corrections and additions to earlier sections

- **Section 8, wrong-room accusation:** almost certainly a *loss*. Game 2's wrong-room accusation
  went straight to the quit-or-restart prompt with no "case closed" text, unlike games 3 and 4.
- **`ASSEMBLE` is a commitment.** After it, `Q` and similar commands return **"Everyone is waiting
  with baited breath to hear your accusation!"** Only `ACCUSE` progresses. **Question everyone
  and compare alibis before you assemble.** I found this out the hard way in game 3 and had to
  accuse on elimination. `ASSEMBLE` works in any room, with or without the weapon.
- **Section 7 (glass):** the glass was in the pantry (game 4), dining room (game 2), sewing room
  (game 3) and guest room (game 1). It sits in the room's carryable slot and is always visible
  in the text ("A magnifying glass is lying on the floor.").
- **Weapon vs murder room:** never the same room in four games. Weapon rooms: unknown (game 1),
  conservatory, master bedroom (house 2), bathroom. Murder rooms: kitchen, study, vault, guest
  room.
- **Floor-staring guests (section 8):** a guest staring at the floor was in the murder room in
  games 1, 3 and 4 (second sighting) and **not** in game 2 (three sightings) or game 4's first
  sighting (bathroom). A single guest can stare in several rooms during a game (David in game 4
  stared in the bathroom, then in the guest room, which was the murder room). **About 3 of 7
  sightings were true.** Treat staring as a hint to check that room's floor, not as proof.
- **Floor examine:** in every murder-room hit I was standing next to the staring guest. I did not test
  whether the bloodstain message needs that guest nearby; it did not need the glass in game 1.
- **Stalking clock (section 9):** the "murderer has grown suspicious" warning appeared in
  games 1 and 2 only. **It never appeared in game 3 (323 moves) or game 4 (233 moves).** So it
  is not a fixed move count. The warning is probably tied to something else (random chance, how
  many people you question, or which clues you have found); I could not isolate it.
- **Guests are not listed as the victim.** The guest list shows the six suspects only. The
  seventh name from the cast is the victim and is only named in dialogue.

### 17.6 Alibi structure, now confirmed

All four games fit one pattern for the five innocent suspects:

> **Two mutually consistent partner pairs plus one solo innocent.** The sixth person, the
> **culprit**, names a partner and a room that the partner **does not confirm**.

| Game | Pair 1 | Pair 2 | Solo | Culprit and how it shows |
| --- | --- | --- | --- | --- |
| 1 | Earl and David (conservatory) | Gerald and Esther (study) | Victoria (library) | **Edward** said he was with Gerald in the library; Gerald says study. (Inferred; I was killed before accusing.) |
| 2 | Esther and David (dining room) | Edward and Maude (guest room) | Gerald (living room) | **Earl** (never questioned; found by elimination, confirmed by accusation) |
| 3 | John and Vanessa (sewing room) | William and Harriet (kitchen; Harriet not questioned, assumed) | Margaret (parlor) | **Daryl** (never questioned; found by elimination; **win**) |
| 4 | Edward and Victoria (dining room) | David and Esther (kitchen; Esther not questioned) | Earl (library, alone) | **Maude**, who said she was with Earl in the library; Earl says alone. (**Win**) |

Other observations:

- **A solo alibi is not proof of guilt.** In the three games where the culprit is known, the solo
  suspect was innocent.
- **The culprit's claim names an innocent who disagrees.** In game 4 that person was the solo
  suspect. In game 1 it was one half of a pair. A single question to each innocent is enough to
  catch it.
- Culprits **point at others** in their closing sentences, like innocents do. Edward in game 4 told
  me to look at Esther (an innocent), so such pointers are unreliable.
- Where the culprit stood was no clue either: William (innocent) hid in the secret corridor,
  while Daryl was never in any room I visited.
- The structure gives a **practical solving rule**: collect each person's partner and room; the
  one whose claim is not returned is the culprit. With six suspects you need only four or five
  alibis if the claims close into pairs.

### 17.7 Other new observations

- **The game never flags a lie.** Nothing on screen says an alibi is false; the player has to
  compare statements.
- **Reply structure was identical in the second house** (mood phrase, core claim, commentary
  ending, the same repeat form), so the alibi system is house-independent.
- **Input timing:** at 1,000 cycles the game dropped keys when sent faster than 250 ms apart.
  I slowed my driver to about 300 ms per key and had no more drops.

### 17.8 Updated open questions

1. What triggers the "murderer has grown suspicious" warning and the loss? It did not fire in games 3
   and 4. Game 1's death message was missed.
2. What is the full rank ladder, and how are the moves computed? Is a wrong person accused a loss?
3. How is the secret door's column chosen, and why did it refuse me again in game 2?
4. Where do the secret passage's other exits lead? Which exit comes from which cell?
5. What decides when a guest stares at the floor: only in the murder room, or at random?
6. What do `KNOCK` and `SEARCH <person>` do when it matters?
7. Is the pool of carryables fixed per room? Repeated across games: bottle opener (kitchen), Beethoven
   bust, fern, mirror, mug, cold cream, candelabra. So pools of three seem plausible.
