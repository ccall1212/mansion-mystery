# Personality, emotion and mystery-event pose matrix

Planning only. Sources: [brainstorm](GAME_DESIGN_BRAINSTORM.md) §3–8 and §10–13,
current user pose-audit requirements, and the active cast review. No trait, guilt,
relationship or fictional behavior is inferred from photographs or appearance.

## Shared emotional vocabulary

| State | Reuse first | Additional body art only when needed | Applies to |
| --- | --- | --- | --- |
| Shock/startle | Eyes/brows/mouth on grounded base | Raised hands, recoil or hand-to-mouth | Discovery, accused target, witnesses, exposed culprit |
| Fear | Eyes/brows, tense head/shoulders | Guarded stance or backward recoil | Threatened innocent, witness or panicked culprit |
| Suspicion | Skeptical gaze/listening base | Lean/hand-to-chin optional | Anyone with relevant knowledge; not proof of guilt |
| Anger | Frown on talk base | Crossed arms, clenched hand or sharp gesture | Innocent false accusation as well as hostile culprit |
| Sadness | Lowered gaze, softened mouth | Drooped head/shoulders | Knowledge/relationship appropriate grief or regret |
| Embarrassment | Downward/averted gaze | Small self-conscious gesture | Optional response; not automatic guilt |
| Relief | Relaxed expression/shoulders | Unclasp/release-tension gesture optional | Resolved threat or cleared accusation |
| Confidence | Calm expression, upright base | Open-palm speech gesture | Innocent or guilty; never a truth indicator |
| Annoyance | Tight mouth/brow on listen/talk | Turn-away/refusal gesture | Repeated questioning according to future rules |
| Nervousness | Concerned gaze | Fidgeting hands optional | Anxious innocence and deceptive roles alike |
| Confusion | Raised brow/head tilt | Open-handed questioning optional | Contradiction, surprise or mistaken accusation |
| Disbelief | Stare/raised brows | Lean back optional | Witness or accused target |

Remorse, panic and smug manipulation can select this vocabulary plus a contextual
gesture; they need not be entirely new base bodies. Expressions must be tested at
actual gameplay scale. Static expression compositing is not implemented yet.
For front-facing reviews use a proposed south-facing sample; seated variants and
other facings are selected by staging needs, not an automatic cross-product.

## Candidate personalities, all unassigned

These twelve labels are brainstorm §3 candidates, **not a final approved trait list**.
Gesture and branch examples below are proposals. Any may occur in an innocent or
guilty role. A case's knowledge/relationships control whether a response is eligible.

| Candidate trait | Ordinary / questioned | Innocent accusation | Exposed culprit | Witness / group |
| --- | --- | --- | --- | --- |
| Friendly/cooperative | Open-palm talk, attentive listen | Hurt/confused denial | Regret or strained composure | Concern, shock, support |
| Nervous/anxious | Tense listen; optional fidget | Fear or flustered denial | Panic or hesitant confession | Recoil, fear, uncertain gaze |
| Arrogant | Upright/confident, restrained gesture | Indignant anger | Defiance or controlled denial | Disbelief or irritation |
| Secretive | Reserved listen, guarded gaze | Defensive turn-away | Guarded denial, then chosen reveal | Watchful suspicion |
| Hot-tempered | Annoyance, sharp talk gesture | Furious protest | Hostile exposure/threat if branch permits | Anger or protective stance |
| Observant | Targeted gaze, look-up/down | Precise confident response | Controlled assessment | Look between evidence and speaker |
| Gossipy | Animated talk, optional point | Shock and explanation | Fast talk or denial | Whisper/turn-to-partner proposal |
| Deceptive | Ordinary calm/talk; no visual guilt tell | Any justified innocent response | Denial or manipulative reveal | Case-consistent staged surprise |
| Forgetful | Confused gaze/head tilt | Confused/hurt denial | Hesitation or personality-selected confession | Uncertain/disbelieving listen |
| Calm/analytical | Quiet attentive listen | Composed denial | Controlled reveal or admission | Focused, varied restrained reactions |
| Remorseful/emotionally fragile | Sadness/concern | Hurt/fear | Lowered head, regret, confession | Grief, shock or fear |
| Manipulative/threatening | Confident or measured talk | Indignation or controlled denial | Smug/broader-plan reveal; threat if eligible | Controlled appraisal; no impossible knowledge |

Char: **unassigned**. The same is true of the other named likeness identities.
Chris alone has a specifically requested identity gesture: hat removal and head
scratch, with selected existing source art. That gesture is not a trait assignment
and must not be copied to Char. Other signatures require user direction.

## Mystery event/reveal checklist

| Event / source | Target response | Other participants | Preconditions and sequence | Status |
| --- | --- | --- | --- | --- |
| Correct accusation, §10 | Culprit recognizes exposure, then selected remorse/hostility/denial/panic/composure | Detective listens/responds; witnesses react individually | Actual guilt, evidence and event priority; recognition → response → resolution | Confirmed future; selector absent |
| Wrong accusation, §10 | Innocent denial, anger, confusion, hurt or confidence | Actual culprit must not react using knowledge they lack; witnesses vary | Innocence and knowledge; no automatic loss/free retry assumption | Confirmed future |
| Innocent accused while culprit unidentified, §10 | Innocent target remains distinct from culprit | Culprit/witness responses remain state-consistent | Preserve unresolved danger; do not clear culprit by animation | Confirmed future |
| Culprit volunteers after another accusation, §10 | Actual culprit interrupts/reveals | Innocent target reacts separately; group redirects gaze | Branch eligibility and interruption priority must be authored | Confirmed future |
| Remorseful exposure, §10 | Regret, explanation, acceptance | Concern/anger/shock according to relationships | Role + personality + evidence; no mandatory kneeling | Confirmed future |
| Hostile exposure, §10 | Anger, sharp threat or defiance | Fear/anger/guarded poses | No automatic combat or group restraint implied | Confirmed future; restraint is optional |
| Broader-plan reveal, §10 | Composed/smug/manipulative talk | Discovery and threat responses | Prepared plan must exist; loss is branch-dependent | Confirmed future; details open |
| Panicked exposure/escape, §12 | Panic, recoil or guarded stance | Track culprit/gaze; preserve exits | Escape animation/pathing handled separately | Confirmed future range; choreography open |
| Stalking capture, §11 | Eligible culprit threatens; detective guards/reacts | Other people only if actually present | Escalation → encounter → valid lock → threat → authored capture/loss | Danger direction confirmed; exact trap sequence proposed |
| Accidental discovery, §8 | Touch → inspect same finger → context reaction/comment | Detective/witness looks only if they can observe | Actual material/source evidence; no new clue created by pose | Confirmed future event concept; chances/eligibility open |
| Floor glance, §7 | Look down without revealing guilt | Detective may inspect location | May happen at an ordinary clean floor; guaranteed normal clue path | Proposed hint |
| Group reveal, §6/12 | Each occupant retains compatible posture or transitions safely | Distinct shocked/fearful/angry/disbelieving witnesses | Capacity, occupancy, prop continuity, partner facing and knowledge | Confirmed future; staging absent |

## Transitions to plan, not pretend are implemented

- Activity → listening/talking → original activity, retaining book/cup/pen state.
- Sit ↔ stand with valid approach/exit; kneel/crouch ↔ stand without feet sliding.
- Bed sit ↔ lie with head/axis alignment; do not teleport pelvis or flip the bed.
- Touch → same-hand finger examination → reaction; cup/book may need setting down.
- Question → annoyed/refusal → permitted recovery; triggers remain undecided.
- Accusation → recognition/denial → confession/threat → resolution; witness timing
  and interruptions must preserve the actual case state.
- Door interaction → lock → threat → capture: hands meet the actual handle/lock;
  paired restraint/capture needs both participants' targets if approved.

A transition may initially be a documented cut between approved static poses;
smooth animation requires separate authorization and production. Walking remains
externally handled. If the needed reaction is unsupported for an occupied seat,
choose another valid reaction/position or hold that event; never force a wrong pose.
