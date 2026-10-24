# Examination descriptions

Descriptions are configurable JSON data produced by `tools/build_evidence_catalog.py`.
No historical descriptions are copied and no UI code chooses murder conclusions.

| Stage | Trigger | State and response |
| --- | --- | --- |
| Initial | E near a prop or reopen from clue book | Condition.initial; subsequent opens use condition.repeat |
| Detailed | D / Detail | Condition.detailed on first detailed inspection, then condition.repeat |
| Tool-assisted | M / Use lens | Requires a collected magnifier; reads the instance's forensic configuration |
| Discovery | First successful lens observation on configured evidence | Adds forensic.discovery and sets discovered once |
| Repeated lens inspection | M again | Forensic.repeat; no duplicate clue or invented evidence |
| Collected | C / Collect | Sets collected only for collectible definitions; removes the room sprite |
| Clue book | N, left/right, Enter to reopen | Records ordinary observations, inventory and only lens observations actually obtained |

Normal descriptions must not mention hidden specks, fibers or particles. A bent blade
may be described immediately because its bend is visible. A torn page is an ordinary
physical observation, not a magnifier-gated revelation. Damage is not proof of guilt.

The knife sample contains reddish-brown specks at a rivet; its text explicitly avoids
identifying their substance by color. The cracked bust sample has a blue fiber at
a rough stone edge. The hammer has metallic particles in a groove. The bottle,
stool, mirror and poker samples have no additional forensic observation. The lens
returns a neutral result for them, including when their physical condition is damaged.

Text wraps in the 480 × 360 inspection panel. Keep prose concise; long future entries
will need pagination or a scrolling notebook. Currently each authored entry fits.
Initial, detailed and repeated text belongs to the physical variant; tool and discovery
text belongs to the independently configured forensic state.

## Playable route

Current default: collect the foyer lens, then travel through the Main Stair Hall
to inspect/magnify the library knife. See [FIXED_MANSION.md](FIXED_MANSION.md).
The route below describes the independently runnable legacy foyer demonstration.

From the foyer runner, walk left to the knife and press E. D examines the ordinary
blade. Close with Escape. Find the magnifying glass on the small reading stand on
the right, inspect it with E and collect with C. Return to the knife, E then M.
N opens the clue book after closing inspection. The broken mirror on the right
side of the runner is an innocent control. F5/F9 explicitly save/load the investigation.

For every produced object and physical variant, open
`src/evidence/evidence_review.tscn` with Godot F6. Use Previous/Next and Variant.
Find lens opens its sample; C collects it in the disposable review session. M then
works on eligible samples. Saving is disabled in this authoring scene.
