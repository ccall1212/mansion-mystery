extends Node
## Technical review layout of existing art; never redraws or replaces character art.

var review_root := "res://assets/characters/review-v5/"
var source_cache: Dictionary = {}

class SheetCanvas extends Node2D:
	var entries: Array = []
	var variant_mode := false
	var footer_note := ""
	var font: Font = ThemeDB.fallback_font
	var sheet_size := Vector2i(1500, 1515)

	func entry_name(entry: Dictionary) -> String:
		return str(entry.name) if entry.get("name") != null else "NAME PENDING"

	func label_at(at: Vector2, value: String, size := 16, color := Color("#d8d9d0")) -> void:
		draw_string(font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

	func figure(texture: Texture2D, box: Rect2, height_ratio := 1.0) -> void:
		var factor := minf(box.size.x / texture.get_width(), box.size.y * height_ratio / texture.get_height())
		var size := Vector2(texture.get_size()) * factor
		var at := Vector2(box.position.x + (box.size.x - size.x) / 2, box.end.y - size.y)
		draw_texture_rect(texture, Rect2(at, size), false)

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, Vector2(sheet_size)), Color("#1c272d"))
		if variant_mode:
			draw_variants()
		else:
			draw_overview()

	func draw_overview() -> void:
		label_at(Vector2(24, 32), "SLEUTH / CURRENT CAST — NAME REVIEW", 26, Color("#dfc895"))
		var has_names := false
		var name_count := 0
		var photo_count := 0
		for entry in entries:
			if entry.get("name") != null:
				has_names = true
				name_count += 1
			if entry.group == "photo-based":
				photo_count += 1
		label_at(Vector2(24, 58), "%d designs / %d photo-based people. %d names saved; unassigned entries remain unnamed." % [entries.size(), photo_count, name_count] if has_names else "One number per person/design. %d photo-based people; %d earlier designs. Names are pending." % [photo_count, entries.size() - photo_count], 16)
		for index in entries.size():
			var entry: Dictionary = entries[index]
			var layout_index := int(entry.get("overview_slot", index))
			var at := Vector2((layout_index % 5) * 300, 76 + (layout_index / 5) * 350)
			draw_rect(Rect2(at + Vector2(8, 0), Vector2(284, 340)), Color("#2a383e"))
			label_at(at + Vector2(18, 27), "#" + str(entry.number) + "  " + entry_name(entry), 19, Color("#e2d2ac"))
			var overview_variants: Array = entry.get("overview_variants", [0])
			var slot_width := 260.0 / overview_variants.size()
			for slot in overview_variants.size():
				var variant_index := int(overview_variants[slot])
				var texture: Texture2D = entry.variants[variant_index].texture
				figure(texture, Rect2(at + Vector2(20 + slot * slot_width, 43), Vector2(slot_width - 4, 224)), float(entry.height_ratio))
			draw_line(at + Vector2(20, 268), at + Vector2(280, 268), Color("#607075"))
			label_at(at + Vector2(18, 296), str(entry.label), 14)
			var note := "Same-person variants on companion sheet" if entry.variants.size() > 1 else "Current review design"
			if entry.group != "photo-based":
				note = "Earlier game / fictional draft"
			note = str(entry.get("review_note", note))
			label_at(at + Vector2(18, 322), note, 12, Color("#9fb3b8"))
		var footer := footer_note if not footer_note.is_empty() else ("Names shown as supplied. Unassigned entries remain unnamed. Appearance review before further poses." if has_names else "Reply with numbers and names, e.g. 01 = …, 02 = … . Next: names, then poses. Comparison layout; game scale remains under review.")
		label_at(Vector2(24, sheet_size.y - 19), footer, 14, Color("#dfc895"))

	func draw_variants() -> void:
		label_at(Vector2(24, 32), "SLEUTH / SAME PERSON — EXISTING ALTERNATE LOOKS", 25, Color("#dfc895"))
		label_at(Vector2(24, 58), "Each panel shares the number from the cast overview. These existing images are one identity, not extra cast members.", 16)
		for index in entries.size():
			var entry: Dictionary = entries[index]
			var at := Vector2((index % 3) * 500, 76 + (index / 3) * 440)
			draw_rect(Rect2(at + Vector2(8, 0), Vector2(484, 428)), Color("#2a383e"))
			var heading := entry_name(entry) if entry.get("name") != null else str(entry.label)
			label_at(at + Vector2(20, 28), "#" + str(entry.number) + "  " + heading, 17, Color("#e2d2ac"))
			var count: int = entry.variants.size()
			var cell_width := 464.0 / count
			for vi in count:
				var variant: Dictionary = entry.variants[vi]
				var texture: Texture2D = variant.texture
				figure(texture, Rect2(at + Vector2(18 + vi * cell_width, 64), Vector2(cell_width - 8, 280)))
				label_at(at + Vector2(23 + vi * cell_width, 373), str(variant.caption), 13)
			label_at(at + Vector2(20, 410), "One person / one name", 13, Color("#9fb3b8"))
		label_at(Vector2(24, sheet_size.y - 22), "Current alternate looks share one identity and name. Earlier rejected passes remain archived in the full gallery.", 14, Color("#dfc895"))

func source_image(path: String) -> Image:
	if not source_cache.has(path):
		var image := Image.load_from_file(path)
		if image == null:
			push_error("Missing cast image: " + path)
			return null
		source_cache[path] = image
	return source_cache[path]

func review_texture(variant: Dictionary) -> ImageTexture:
	var original := source_image(str(variant.source))
	if original == null:
		return null
	var image: Image = original.duplicate()
	if variant.has("crop_grid"):
		var grid: Array = variant.crop_grid
		var column := int(grid[2]) % int(grid[0])
		var row := int(grid[2]) / int(grid[0])
		var left := roundi(float(column) * image.get_width() / int(grid[0]))
		var top := roundi(float(row) * image.get_height() / int(grid[1]))
		var right := roundi(float(column + 1) * image.get_width() / int(grid[0]))
		var bottom := roundi(float(row + 1) * image.get_height() / int(grid[1]))
		image = image.get_region(Rect2i(left, top, right - left, bottom - top))
	if variant.has("crop_rect"):
		var rect: Array = variant.crop_rect
		image = image.get_region(Rect2i(int(rect[0]), int(rect[1]), int(rect[2]), int(rect[3])))
	if variant.has("panel_crop"):
		var crop: Array = variant.panel_crop
		var bounds := Rect2i(roundi(float(crop[0]) * image.get_width()), roundi(float(crop[1]) * image.get_height()), roundi(float(crop[2]) * image.get_width()), roundi(float(crop[3]) * image.get_height()))
		image = image.get_region(bounds.intersection(Rect2i(Vector2i.ZERO, image.get_size())))
	if bool(variant.get("transparent", false)):
		image.convert(Image.FORMAT_RGBA8)
		for y in image.get_height():
			for x in image.get_width():
				var color := image.get_pixel(x, y)
				if color.a < 0.5:
					image.set_pixel(x, y, Color.TRANSPARENT)
				else:
					color.a = 1.0
					image.set_pixel(x, y, color)
		var rect := image.get_used_rect()
		if not rect.has_area():
			push_error("Empty cast image: " + str(variant.source))
			return null
		image = image.get_region(rect)
	return ImageTexture.create_from_image(image)

func _ready() -> void:
	get_window().size = Vector2i(320, 180)
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--review="):
			var folder := argument.trim_prefix("--review=")
			var pattern := RegEx.create_from_string("^review-v[0-9]+$")
			if pattern.search(folder) == null:
				push_error("Invalid review folder")
				get_tree().quit(1)
				return
			review_root = "res://assets/characters/" + folder + "/"
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(review_root + "cast-catalog.json"))
	var all_entries: Array = catalog.entries
	var alternate_entries: Array = []
	for entry in all_entries:
		for variant in entry.variants:
			var texture := review_texture(variant)
			if texture == null:
				get_tree().quit(1)
				return
			variant["texture"] = texture
		if entry.variants.size() > 1:
			alternate_entries.append(entry)
	var max_slot := 0
	for index in all_entries.size():
		max_slot = maxi(max_slot, int(all_entries[index].get("overview_slot", index)))
	var overview_rows := ceili((max_slot + 1) / 5.0)
	var variant_rows := ceili(alternate_entries.size() / 3.0)
	var output_specs := [
		{"file": "current-cast-overview.png", "size": Vector2i(1500, 76 + overview_rows * 350 + 39), "entries": all_entries, "variants": false},
		{"file": "same-person-variants.png", "size": Vector2i(1500, 76 + variant_rows * 440 + 44), "entries": alternate_entries, "variants": true},
	]
	var viewports: Array[SubViewport] = []
	for spec in output_specs:
		var viewport := SubViewport.new()
		viewport.size = spec.size
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		add_child(viewport)
		var canvas := SheetCanvas.new()
		canvas.entries = spec.entries
		canvas.variant_mode = bool(spec.variants)
		canvas.sheet_size = spec.size
		canvas.footer_note = str(catalog.get("overview_footer", ""))
		canvas.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		viewport.add_child(canvas)
		canvas.queue_redraw()
		viewports.append(viewport)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	for index in viewports.size():
		var path: String = review_root + str(output_specs[index].file)
		var error := viewports[index].get_texture().get_image().save_png(path)
		if error != OK:
			push_error("Failed saving " + path + ": " + error_string(error))
			get_tree().quit(1)
			return
		print("CAST_REVIEW_SAVED ", path)
	get_tree().quit()
