extends SceneTree
var viewport: SubViewport
var canvas: Node2D
var catalog: Dictionary
var font: Font
var textures: Dictionary = {}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	catalog = JSON.parse_string(FileAccess.get_file_as_string("res://assets/objects/object-manifest.json"))
	font = ThemeDB.fallback_font
	viewport = SubViewport.new()
	viewport.size = Vector2i(1040, 96 + catalog.definitions.size() * 180)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	canvas = Node2D.new()
	canvas.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	canvas.draw.connect(paint)
	viewport.add_child(canvas)
	canvas.queue_redraw()
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var path := "res://assets/objects/review/object-contact-sheet.png"
	viewport.get_texture().get_image().save_png(path)
	print("EVIDENCE_CONTACT_SAVED ", path)
	quit()

func label(at: Vector2, value: String, size := 14, color := Color("#d7ccaf")) -> void:
	canvas.draw_string(font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func texture(path: String) -> Texture2D:
	if not textures.has(path):
		textures[path] = load(path)
	return textures[path]

func paint() -> void:
	canvas.draw_rect(Rect2(Vector2.ZERO, viewport.size), Color("#101c25"))
	label(Vector2(20, 27), "SLEUTH / EVIDENCE OBJECTS — PHYSICAL VARIANTS AND LENS OBSERVATIONS", 20)
	label(Vector2(20, 52), "Original generated art · world sprites at 1× and 2× · enlarged inspection art · no automatic evidence reveal", 14)
	label(Vector2(220, 78), "Physical variant A", 13)
	label(Vector2(408, 78), "Physical variant B", 13)
	label(Vector2(610, 78), "Normal inspection", 13)
	label(Vector2(810, 78), "After explicit magnifier use", 13)
	var row := 0
	for id in catalog.definitions:
		var definition: Dictionary = catalog.definitions[id]
		var y := 92 + row * 180
		canvas.draw_rect(Rect2(12, y, 1016, 174), Color("#20313b") if row % 2 == 0 else Color("#1a2a34"))
		label(Vector2(24, y + 24), definition.name, 14)
		var variants: Array = definition.conditions.keys()
		for i in variants.size():
			var variant: Dictionary = definition.conditions[variants[i]]
			var at := Vector2(218 + 188 * i, y + 22)
			canvas.draw_texture_rect(texture(variant.closeup), Rect2(at, Vector2(132, 132)), false)
			label(at + Vector2(0, 146), str(variants[i]), 13)
			canvas.draw_texture(texture(variant.asset), Vector2(28 + 70 * i, y + 53))
			canvas.draw_texture_rect(texture(variant.asset), Rect2(Vector2(24 + 70 * i, y + 94), Vector2(64, 80)), false)
		var forensic_id: String = definition.allowed_forensics.back()
		var normal: Dictionary = definition.conditions[variants[1] if id == "bust" else variants[0]]
		canvas.draw_texture_rect(texture(normal.closeup), Rect2(Vector2(604, y + 23), Vector2(132,132)), false)
		if forensic_id != "none":
			canvas.draw_texture_rect(texture(catalog.forensics[forensic_id].inset), Rect2(Vector2(814, y + 23), Vector2(132,132)), false)
			label(Vector2(806, y + 164), "Configured: " + forensic_id, 13)
		else:
			label(Vector2(806, y + 75), "No additional evidence.", 14)
			label(Vector2(806, y + 96), "Innocent control / tool.", 13)
		row += 1
