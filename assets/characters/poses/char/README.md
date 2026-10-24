# Char — character assets

Open [index.html](index.html) to browse approved poses by direction, or
[the alignment review](review/alignment_01/index.html) for comparison/chair contexts.

- `exports/north`, `east`, `south`, `west`: approved directional PNGs.
- Filenames: `char_<posture>_<action>_<direction>_<variant>.png`, including neutral.
- `masters/likeness-review-02`: approved identity design. `masters/alignment_01`:
  unchanged native pose sources; export padding and contact metadata are separate.
- `batches`: production scope and approval records. `prompts`: retained exact
  production instructions/landmarks. `review`: supporting visual fit evidence.
- `production-manifest.json`: source of truth for approval, requirements and progress.
  `directional-index.json`: explicit asset lookup; current runtime does not load it yet.

All seven pose samples have artwork approval. Furniture contact/mask calibration
and runtime pose selection remain pending; a file being in a direction folder does
not make every action or chair compatible. Do not regenerate or overwrite approved PNGs.
