extends Node2D
## Technical contact sheet of actual transparent draft assets, not generated characters.

var font: Font = ThemeDB.fallback_font
var entries: Array = []
var textures: Array[Texture2D] = []

func _ready() -> void:
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_window().size = Vector2i(1080, 730)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/draft-manifest.json"))
	var primary: Dictionary = data.reference_protagonist
	primary["name"] = "Original protagonist"
	primary["role"] = "PRIMARY STYLE / current 48-unit scale"
	var secondary: Dictionary = data.reference_eleanor_original
	secondary["name"] = "Original Eleanor"
	secondary["role"] = "SECONDARY / small-head mismatch"
	entries = [primary, secondary]
	for entry in data.characters:
		entry["role"] = entry.id + " / " + entry.slug
		entries.append(entry)
	for entry in entries:
		textures.append(load(entry.image))
	queue_redraw()
	capture.call_deferred()

func label_at(at: Vector2, value: String, size := 16, color := Color("#d8d9d0")) -> void:
	draw_string(font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1080, 730), Color("#1c272d"))
	label_at(Vector2(24, 30), "SLEUTH / CHARACTER STYLE REVIEW — DRAFTS", 22, Color("#dfc895"))
	label_at(Vector2(24, 53), "Protagonist is the style anchor. Existing Eleanor shows the proportion problem. Four new pose tests below.", 15)
	for index in entries.size():
		var column := index % 3
		var row := index / 3
		var origin := Vector2(column * 360, 72 + row * 298)
		draw_rect(Rect2(origin + Vector2(8, 0), Vector2(344, 290)), Color("#344147") if index < 2 else Color("#2a383e"))
		draw_line(origin + Vector2(22, 226), origin + Vector2(338, 226), Color("#607075"))
		if index < textures.size():
			var entry: Dictionary = entries[index]
			var texture: Texture2D = textures[index]
			var pivot := Vector2(entry.pivot[0], entry.pivot[1])
			var scale_factor := 4.0 / 3.0
			draw_texture_rect(texture, Rect2(origin + Vector2(180, 226) - pivot * scale_factor, Vector2(texture.get_size()) * scale_factor), false)
			label_at(origin + Vector2(20, 253), entry.name, 18, Color("#e2d2ac"))
			label_at(origin + Vector2(20, 276), entry.role, 13, Color("#9fb3b8"))
	label_at(Vector2(24, 698), "Draft review only — remaining 11 characters and Eleanor revision are on hold for your approval.", 16, Color("#dfc895"))
	label_at(Vector2(24, 720), "Pose heights preserve the shared head scale. Crouching and kneeling characters are intentionally shorter.", 13)

func capture() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://assets/characters/qa/style-review-drafts.png")
	get_tree().quit()
