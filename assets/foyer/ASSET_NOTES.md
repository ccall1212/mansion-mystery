# Foyer prototype assets

Created 2026-10-23 using the built-in imagegen tool, then copied into this project.
These are original generated prototype assets. No ripped Wild Arms sprites, tiles,
logos or DOS assets are loaded by the remake. The supplied reference sheets remain
under ignored reference/art-direction/ for visual analysis only.

- `foyer-background.png`: original static 1536 x 1024 room backdrop, displayed in a
  480 x 320 region. Its lighting is baked into the image; no dynamic lighting system
  is claimed. UI and the player are separate. The background also appears in the editor.
- `investigator-sheet.png`: original 1254 x 1254 transparent sheet, four columns and
  four rows. Rows face down, left, right and up. Runtime alpha bounds normalize the
  feet and frame scale to a 48-pixel character height. This was increased from 29
  after user feedback about the investigator's scale relative to the room.
  Generated poses are an initial
  animation pass, subject to refinement after playtesting.
- `src/foyer/table.gd`: original code-drawn foreground reading stand. This is deliberate
  placeholder furniture for testing character occlusion and collision, not final art.
- `src/foyer/player.gd`: contains a code-drawn fallback plus the generated sprite renderer.
- `eleanor-sheet.png`: original two-pose transparent guest sheet, generated with the
  built-in imagegen tool. Back pose looks out the window; front pose is used while
  questioning. The guest is drawn 47 logical pixels tall. Both character renderers
  now ignore alpha below 0.5 when locating visible feet, using sprite_frames.gd.

Prompts used are preserved below. The background generation used the user's cold
statue hall reference only for general mood and readability; the investigator was
generated from the original design brief without a supplied image.

## Background prompt

Create an ORIGINAL production game background asset, not a screenshot or mockup. Landscape 3:2 composition. A single 2D top-down three-quarter-view pixel-art haunted manor foyer in the spirit of richly detailed late-1990s console RPG environments. Fixed orthographic projection, floors seen from above, tall back wall seen from front, NO vanishing point, NO isometric diamond, NO realistic perspective. The attached image is ONLY a style/mood reference for cold stone and readability; design a distinct original room and do NOT copy its characters or architecture. Entire room visible at once. Designed on a crisp low-resolution approximately 480x320 pixel grid then enlarged evenly with hard pixels. Beautiful richly textured pixel clusters, limited dusky teal palette, charcoal stone, antique brass, warm small amber candles and blue moonlight. Room layout EXACT: top 35% is a tall detailed back wall with centered sealed arched dark wooden double doors on a shallow 3-step landing. Tall mullioned blue windows on either side, carved pilasters. Upper LEFT side of playable floor a grandfather clock with gold circular face and dark wooden case at x=22% y=49%, warm candle nearby. Upper RIGHT side of floor a high-backed dark red armchair and small round side table with candle at x=78% y=51%. Wide CLEAR walkable stone tiled floor from y=50% through y=93%, central faded burgundy carpet runner from the landing all the way down to bottom center. Small portrait on left back wall. Architectural symmetrical frame, subtle asymmetrical lived-in props. Bottom edge simply ends the floor with dark stone border, no tall front wall hiding the player. IMPORTANT NO characters, NO sprites, NO text, NO UI, NO borders outside room, NO watermarks, NO logos, NO glowing magic portals. Ambient haunting implied through atmosphere, not monsters. Tiny readable details, moody but navigable, sufficient contrast to see every floor tile. This image will be used as the actual static background of a playable game with collision geometry added separately.

## Investigator prompt

Original production game asset: ONE transparent PNG sprite sheet for a haunted-mansion 2D top-down three-quarter adventure game. Strict 4 columns x 4 rows uniform grid, NO drawn grid lines. All 16 cells have exactly equal width/height, same character scale and feet baseline within each cell. Landscape? Use square overall sheet, 4x4 equal square cells. Each cell has ample transparent padding. Character is an original adult investigator, compact expressive late-1990s RPG pixel sprite proportions, approximately 18 pixels wide and 30 pixels tall on a virtual pixel grid. Wavy swept chestnut hair, warm tan skin, long charcoal-teal overcoat, burgundy waistcoat, cream shirt collar, brown leather ankle boots. No hat, no weapons, no lantern, no accessories extending outside body, no other characters. Distinct design from any existing franchise. Beautiful readable hard-edged pixel art, 12-18 colors, subtle warm outlines, directional light from upper left, no blur or antialiasing. Front face has visible small eyes and nose. Side views have visible profile nose and one eye. Back has hair and coat back only. ROW 1 = facing viewer/down, four walk-cycle frames (left foot forward, neutral, right foot forward, neutral). ROW 2 = facing left, same four walk-cycle frames. ROW 3 = facing right, same four walk-cycle frames. ROW 4 = facing away/up, same four walk-cycle frames. Keep head consistent between frames, gentle alternating coat hem and arms. Exact regular grid with sprite feet centered horizontally at 80% of each cell height. Each character occupies approximately 55% of cell height so transparent padding separates every sprite. No shadows below feet, no floor, no background color, NO letters, NO labels, NO text, NO captions, NO color palette swatches. Output must have true transparent background.

## Eleanor prompt

Create an ORIGINAL transparent game sprite asset for a late-1990s-style 2D pixel-art haunted manor murder mystery. Exactly TWO full-body standing poses of the SAME original adult female manor guest, side by side in two equal-width cells on one horizontal row, generous transparent space between them, no grid, no captions. LEFT pose: back view, standing quietly looking out a window, arms relaxed. RIGHT pose: front view, subtly turned head, reserved wary expression, hands gently clasped. Character design: elegant woman in her late 50s, silver hair in a low bun, long dark emerald Victorian-inspired dress, narrow ivory collar, small burgundy brooch, modest black shoes. Distinct from any existing franchise character. Compact expressive RPG sprite proportions matching hand-crafted 32-to-48 pixel-tall game characters, warm outlines, crisp controlled pixel clusters, readable face and silhouette, no realistic illustration rendering. Same body size and foot baseline in both poses. No room, no window, no background, no ground plane, NO floor shadow, no glow, no weapons, no walking, no extra characters, no text or labels or swatches. True transparent PNG. Asset will be scaled to 48 logical pixels tall in the actual game.
