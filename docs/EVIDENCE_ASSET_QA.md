# Evidence asset and integration QA

Validated locally on 2026-10-23, Godot 4.7.2, Compatibility renderer, Windows.

## Delivered files

- `assets/objects/object-manifest.json`: 12 produced identities, 23 physical states,
  three forensic inset definitions and 24 explicitly planned expansion entries.
- `assets/objects/object-*.png`: 23 world sprites, 32 × 40 RGBA.
- `assets/objects/closeups/`: 23 inspection images plus three forensic insets,
  each 160 × 160 RGBA. There are 49 runtime PNGs total.
- `assets/objects/masters/`: original generated sheets, preserved unchanged.
- `assets/objects/prompts/`: exact built-in imagegen prompts; `*-retry.txt` records
  the successful replacement prompts for book, decanter and safe. No API CLI used.
- `assets/objects/review/object-contact-sheet.png`: all physical states, normal
  inspections, eligible enlarged lens observations and native/2× world sprites.
- `assets/objects/review/asset-checks.json`: dimensions, alpha bounds, SHA-256 hashes
  and actual behavior/render validation counts.

The initial seven objects and magnifier were validated with 59 behavior checks,
13 rendered interaction checks and an inspected contact sheet before expanding.
The expansion adds mallet, decanter, ledger and safe, each with two physical states.

## Observed results

The full pytest suite passes **36 tests**. Evidence-specific Godot checks pass
**76 assertions**. The actual rendered foyer/review playtest passes **39 assertions**.
The existing foyer checks remain **14**, and mansion-session checks remain **180**.
The real-window MCP regression also passed movement, zoom, clock, Eleanor's
questions, restart and owned-process cleanup (`test-results/remake-smoke.json`).

`tools/evidence_playtest.gd` launches the actual foyer scene in a real graphical
Godot process, dispatches keyboard events through `Input.parse_input_event`, and
captures the viewport. It does not use desktop keyboard injection. It verifies:

- E selects the nearby knife and pauses movement; Escape releases it.
- D shows physical detail. M before tool collection cannot reveal the inset.
- E/C finds and collects the lens from the reading stand; its world sprite disappears.
- Lens ownership alone leaves evidence concealed. Explicit M reveals configured
  specks and records the observation once.
- The broken mirror stays an innocent control with no fabricated evidence.
- Collected objects disappear from the world and remain available through the book.
- N opens the notebook, and the observation survives an actual file save/load.
- A corrupt evidence save and an inappropriate room load are rejected atomically.
- Every produced identity and its alternate can be displayed by the review scene.

All saved native captures in `test-results/evidence/` were visually inspected:
foyer-native, foyer-zoom, knife-normal, knife-magnified, mirror-innocent, clue-book
and object-review. The forensic inset fits its 112-pixel panel without overlapping
the controls. Text wraps at the actual 480 × 360 display resolution.

## Art checks

Every master was inspected before export. Identity persists through the paired
material/fitting designs. Changes are physical: blade bow, stone fracture, missing
bottle neck, splintered handle, stool orientation, missing mirror glass and poker
bend. Expansion changes are split mallet head, removed stopper/empty decanter,
torn page and safe dents. No arbitrary recolors count as variants.

Godot performs technical cell splitting, alpha trimming and nearest export.
Runtime alpha is exactly 0/255, with transparent margins. World silhouettes share
a bottom-centred anchor and one-pixel foot margin. No compositing overlays are
currently used; forensic insets occupy a separate UI region and cannot accidentally
misalign with or leak into ordinary room art. Automated hashes reject duplicate
physical variant images. The contact capture is also checked against a previous
missing-texture/white-square rendering failure.

Readability was inspected beside the 48-pixel protagonist at 1×/2×. Small implements
read primarily by silhouette at world scale; inspection supplies detail. Final
placement/scale in other rooms still requires their collision and furnishing pass.

## Reproduce

Use the configured local Godot executable; paths remain in ignored local.json.

1. Run `python tools/build_evidence_catalog.py` using the project environment.
2. Godot: `--headless --path . --script tools/export_evidence_assets.gd`.
3. Godot: `--headless --path . --editor --import`.
4. Godot: `--headless --path . --script tools/evidence_checks.gd`.
5. Godot GUI: `--path . --resolution 480x360 --script tools/evidence_playtest.gd`.
6. Godot GUI: `--path . --script tools/evidence_contact_sheet.gd`.
7. Run `python tools/validate_evidence_assets.py`, then `python -m pytest tests -q`.

The rendered test uses a uniquely named temporary user save and removes it. It
does not overwrite the player's saved investigation. Test processes are bounded
and owned by the invoking Python subprocess or MCP session.

## Remaining work

There is no generated murder solution, accusation system or case assignment yet.
The clock is the existing authored prototype clue. Other object findings are
sample observations, not proof of a particular weapon, crime or suspect.

Only knife, mirror and magnifier have playable foyer placements. Other assets are
fully inspectable in the production review scene. Next connect the four ground-floor
rooms, fit per-room object positions/collisions, and author a compact solvable case.
Then add candlestick/paperweight/letter opener and ordinary room dressing from the
planned catalog. Add service-door marks and moved-object clues once rooms support
those environmental interactions. Telephone/electrical examples require a settled
period brief; the frayed electric lamp has deliberately not been introduced.

Notebook entries have no pagination/search yet. Persistence covers object records
and the clock note, not player position or conversation history. Future randomized
case conditions must be serialized separately from the current fixed manifest.
