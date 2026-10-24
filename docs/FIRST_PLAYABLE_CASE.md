# First playable case: The Silent Library

This is an authored prototype using the existing fixed mansion. Open **F4** and
choose **Begin the first case**. It starts a fresh investigation with three fixed
suspects: Char in the library, Justin in the dining room and Chris in the kitchen.
Case roles are temporary fiction, not permanent personality assignments.

Use E to inspect/question, C to collect, M to use the lens and N for the clue book.
The foyer magnifier, library knife, disturbed library rug and three accounts form
the investigation. The rug has a small nearby interaction marker; its observation
is text, not newly generated floor artwork. Statements and rug findings join the
existing evidence notebook. F4 lists remaining leads and opens accusation choices.
Present a suspect, weapon and room in the foyer. Incorrect accusations permit a
retry; a correct supported reconstruction produces a written ending.

F5/F9 preserve case state, collected evidence, accounts, room and positions through
the existing fixed-house save. Beginning/restarting the case resets investigation
progress in memory; it does not overwrite a save until F5. Char's F7/F8 placement
test is separate and disabled while a case is active. Restart the application for
ordinary exploration/Char testing, or F9 to load an earlier exploration save.

Data: `assets/mysteries/first-case.json`. Case rules: `src/mystery/case_state.gd`.
UI: `src/mystery/case_controller.gd`. Normal randomized exploration is retained.
The case uses ground-floor rooms; upper/basement routes remain accessible.

## Chair review

`assets/characters/poses/char/chair-fit.json` maps the three exact existing seat IDs
to small world-unit seat offsets and background-local foreground polygons. The
renderer redraws existing background pixels over the outer chair arms. No source
PNG, body proportion or shared scale changes. This mechanism is a narrow Char fit
preview, not a universal furniture mask/staging system. It still needs user visual
approval, particularly skirt/arm overlap. Furniture's general staging flags stay
false. Approved source landmark records retain their original coordinates; the
offset is explicit in the fit file rather than silently changing those records.

Review: [chair and case captures](../test-results/first-case/index.html).

## Focused verification

Run configured Godot with `--headless --path . --script tools/first_case_checks.gd`.
Add `-- --capture` without headless for rendered previews, then run
`python tools/build_first_case_review.py`. The 31 integration checks cover three
chairs, unique/reachable suspect placements, question/floor interactions, notebook
entries, evidence gates, wrong suspect/weapon/room, correct ending and snapshot
restore/rejection. Test evidence is synthesized through the actual evidence API;
this is not a timed manual walk-through or proof of final difficulty/balance.

`python tools/dos-game-mcp/first_case_preview.py` opens the actual owned game window
at its F4 briefing for a manual playtest, then cleans up when that window closes.

Pending: user review of chair masks and case flow; gathered character placement,
emotional/reveal art, randomized cases, new victim artwork, sound and pacing.
The 10–15 minute target has not been measured. No new character artwork was made.
