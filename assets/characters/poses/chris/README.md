# Chris: example poses for men

Chris is the example pose set for male characters, as Char is for female characters. The folder mirrors Char's:

- `exports/murderer-reveal`: the five murderer reveal poses (accuse, crouching cry, laugh, shrug, threaten), kept out of
  `exports/south`; their masters and records are in `masters/` and `metadata/murderer-reveal-01`.
- `exports/north`, `east`, `south`, `west`, `lying`: approved PNGs only, named
  `chris_<posture>_<action>_<direction>_<variant>.png` (lying poses use head direction). Each is byte-identical to its
  master; revision suffixes such as `_r2` are dropped.
- `masters/<batch>`: the approved source PNGs under their original names (`model-review-01` is the approved identity,
  `runner-01` the generated poses, `lying-approved-01` the two you supplied).
- `metadata/<batch>`: one record per approved pose with the exact approval quote, hashes, canvas and conditions.
- `drafts/<batch>`: candidates that are not approved (drafts, needs-help, superseded revisions). Organization does not
  grant approval.
- `prompts/runner-01`: the exact generation records. `queue.json`: the production queue the runner reads and writes.
  `review/index.html`: gallery of pending and approved poses. `batches/runner-01.json`: batch summary.
- `production-manifest.json`: source of truth for approval. `directional-index.json`: explicit lookup of approved
  poses, including lying; the runtime does not load it yet. [index.html](index.html): browser of approved poses.

Export canvas and pivot alignment, furniture contact calibration and runtime pose selection are still pending.
Do not regenerate or overwrite approved PNGs. Layout moved from a flat `north/east/south/west` arrangement on 2026-10-26.

Both characters now have 81 approved export images: east19, west19, north11, south20, murderer-reveal5 and lying7. Exact filenames/slots checked in `docs/pose-production/EXPORT_PARITY.json` (repository relative). Original lying PNGs composite cleanly; hidden alpha-zero RGB colors are not a visible background, and peak alpha254 is acceptable. No pixel changes were needed.
