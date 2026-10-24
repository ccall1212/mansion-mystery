# Evidence art guide

Approval and retention: follow [IMAGE_ASSET_WORKFLOW.md](IMAGE_ASSET_WORKFLOW.md), which supersedes older retain-all-experiments instructions. Explicit user approval is a separate required step before finalization/integration or the next art batch.

The playable renderer is Godot 4, 480 × 360, with a 480 × 320 room,
nearest texture filtering and a 2× follow camera. The investigator is 48 pixels
tall. Objects use bottom-centred feet anchors and separate Sprite2D layers.

Match the original library and foyer: elevated three-quarter view, warm light
from the upper left, cool charcoal outlines, restrained brass, walnut, aged iron,
green glass and pale stone. Use deliberate pixel clusters. Avoid photographic
surfaces, smooth vector edges, baked room floors and large drop shadows.

Generate original transparent masters with the built-in imagegen tool. Preserve
masters and exact prompts. Technical export may split equal cells, trim alpha,
threshold edge alpha and resize with nearest sampling; it must not invent art.
Each physical variant retains the parent's material, fittings and viewpoint.
Geometry changes receive complete images; forensic details use reusable magnified
insets, drawn only following explicit successful tool use.

Runtime world canvases are 32 × 40 RGBA; small implements occupy 20–30 pixels,
furniture occupies up to 36 pixels high. Inspection canvases are 160 × 160.
Both are exported independently from masters, with no stretching. Native world
art must be reviewed beside the 48-pixel protagonist at 1× and 2× zoom.

The first seven objects are a style and interaction milestone, not a generated
murder solution. Evidence is an observation, not proof of guilt. Ordinary and
damaged controls must remain innocent when their forensic configuration is none.
