# Objects, physical variants and evidence

Current fixed-house integration: [FIXED_MANSION.md](FIXED_MANSION.md). It relocates
the stable knife instance to the library, places other samples across rooms, and
extends save/load to room position and visits. The original foyer demonstration
and its evidence milestone contract remain available independently.

The authored source is `tools/build_evidence_catalog.py`; running it writes
`assets/objects/object-manifest.json`. Runtime code reads that JSON, not the builder
or historical WEAPN files. Those two private reference files were read only as
examples of categories. All current descriptions and artwork are newly authored.

## Data boundaries

- **Definition:** identity, category, allowed conditions/forensics, collectibility,
  world and inspection asset references, and description stages.
- **Condition:** exactly one named physical state, never simultaneous intact/broken
  flags. Geometry changes use complete sibling PNGs. Current overlays are empty;
  decorative overlays with no physical difference were deliberately not invented.
- **Instance:** stable ID, one definition, one condition, one permitted forensic
  state, room and feet position. Configurations are authored demonstrations, not
  randomized clues or conclusions about a murder weapon.
- **Record:** five validated booleans: seen, detailed, collected, magnified,
  discovered. Inspecting an object does not collect it. Ownership of the lens does
  not set magnified. Clean objects never set discovered.

The ordinary image path depends only on definition and condition. Hidden evidence
does not select a different ordinary image. Explicit tool use displays a separate
enlarged inset and records its observation. Insets depict the actual sampled
material: walnut/rivet, pale stone or dark steel. They are not world overlays.
The fiber is restricted to the cracked bust. Conditions and permitted forensic
IDs are validated; incompatible configurations are rejected.

## Production set

The initial seven have two physical states each: straight/bent knife;
intact/cracked bust; sealed/broken bottle; sound/splintered hammer;
upright/overturned stool; intact/broken mirror; straight/bent poker.
The magnifying glass has one serviceable state. The expansion adds sound/split
mallet, stoppered/empty decanter, whole/missing-page ledger and unmarked/dented safe.
All have independently exported world and inspection PNGs. The remaining curated
catalog entries are explicitly planned, with no invented runtime asset references.

## Adding content

1. Add an identity and original descriptions to ROWS in the builder. Add an allowed
   forensic ID only when that observation belongs to that identity/material.
2. Generate a master with cells ordered exactly as the condition keys, and preserve
   its prompt under `assets/objects/prompts`. Use a separate master if fitting a
   different number of cells. Add dimensions to the export limits where necessary.
3. Build the manifest, run `tools/export_evidence_assets.gd` with Godot headless,
   and import with `--headless --editor --import`. Inspect world and close-up art.
4. Add an instance with a unique ID, valid room, feet position and one condition.
   Foyer placements are currently knife, broken mirror and lens on the reading
   stand. Remaining samples live in the separate evidence review scene, avoiding
   a foyer full of unrelated weapons. No collider is baked into an image.
5. Run evidence checks, the actual rendered playtest, and the full pytest suite.

Runtime validation is in `src/evidence/evidence_state.gd`; UI and prop placement are
in `evidence_controller.gd`. New conditions or examination wording need no UI edits.
Review controls mutate a disposable local catalog, never the playable session.

## Persistence and scope

Evidence snapshots are stored under `MansionWorld.session.room_memory.g_foyer`.
F5 explicitly saves the mansion session; F9 loads it. No background autosave or
automatic load occurs. Validation rejects malformed flag combinations and unknown
instances atomically. Collection, ordinary examinations, lens results and the clock
note survive save/load. NPC dialogue history and player position are not saved.
The foyer loader rejects saves whose current logical room is elsewhere; the
blueprint authoring review can still load its own floor/room sessions normally.

The current instance configuration is fixed by the manifest. A future case generator
must persist condition/forensic assignments with a versioned case ID, then validate
them before restoring records. Do not randomize these assignments on room entry.
The existing compact floor graphs are logical plans; physical transitions remain
pending. Review samples are not silently placed into unimplemented rooms.
