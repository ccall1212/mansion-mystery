extends SceneTree
## Deterministic extraction/export only. Character artwork comes from imagegen.

func _initialize() -> void:
	if "--export-cast" in OS.get_cmdline_user_args():
		export_cast("--drafts" in OS.get_cmdline_user_args())
		return
	DirAccess.make_dir_recursive_absolute("res://assets/characters/references")
	var protagonist := Image.load_from_file("res://assets/foyer/investigator-sheet.png")
	protagonist.get_region(Rect2i(398, 41, 130, 251)).save_png("res://assets/characters/references/protagonist-front.png")
	protagonist.get_region(Rect2i(313, 313, 313, 313)).save_png("res://assets/characters/references/protagonist-left.png")
	var woman := Image.load_from_file("res://assets/foyer/eleanor-sheet.png")
	woman.get_region(Rect2i(1110, 131, 313, 720)).save_png("res://assets/characters/references/eleanor-original-front.png")
	print("Extracted canonical references; original sheets unchanged")
	quit()

func clean_alpha(image: Image) -> Image:
	image.convert(Image.FORMAT_RGBA8)
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			if color.a < 0.5:
				image.set_pixel(x, y, Color.TRANSPARENT)
			else:
				color.a = 1.0
				image.set_pixel(x, y, color)
	return image

func export_one(source: String, destination: String, head_fraction: float, head_units: float, source_region := Rect2i()) -> Dictionary:
	var image := Image.load_from_file(source)
	if image == null:
		push_error("Missing master: " + source)
		return {}
	if source_region.size != Vector2i.ZERO:
		image = image.get_region(source_region)
	var source_size := image.get_size()
	image = clean_alpha(image)
	var bounds := image.get_used_rect()
	var source_head := bounds.size.y * head_fraction
	var factor := head_units * 3.0 / source_head
	image = image.get_region(bounds)
	image.resize(maxi(1, roundi(bounds.size.x * factor)), maxi(1, roundi(bounds.size.y * factor)), Image.INTERPOLATE_NEAREST)
	# Determine ground contact from the lowest solid shoe/knee pixels, not the whole
	# silhouette centre (which would move a pivot when an arm points sideways).
	var foot_x := 0.0
	var count := 0
	for y in range(maxi(0, image.get_height() - 6), image.get_height()):
		for x in image.get_width():
			if image.get_pixel(x, y).a > 0.5:
				foot_x += x
				count += 1
	foot_x = foot_x / maxf(1, count)
	var final := Image.create(image.get_width() + 24, image.get_height() + 24, false, Image.FORMAT_RGBA8)
	final.fill(Color.TRANSPARENT)
	final.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), Vector2i(12, 12))
	final.save_png(destination)
	return {"image": destination, "source": source, "source_size": [source_size.x, source_size.y],
		"source_bounds": [bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y],
		"head_landmark_fraction": head_fraction, "estimated_source_head_pixels": source_head,
		"target_head_units": head_units, "pixels_per_world_unit": 3, "render_scale": 1.0 / 3.0,
		"pivot": [foot_x + 12, image.get_height() + 12], "size": [final.get_width(), final.get_height()],
		"pose_height_units": image.get_height() / 3.0}

func export_cast(drafts := false) -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/production.json"))
	var manifest := {"version": 1, "render_scale": 1.0 / 3.0, "description": "15 distinct posed characters; not full animation sets", "characters": []}
	var folder := "res://assets/characters/drafts/" if drafts else "res://assets/characters/"
	DirAccess.make_dir_recursive_absolute(folder)
	manifest["status"] = "drafts-awaiting-user-review" if drafts else "production-review-required"
	for entry in data.roster:
		var filename: String = entry.id + "-" + entry.slug
		if entry.id == "01":
			filename = "01-jonas-investigating-clue"
		var source := "res://assets/characters/masters/" + filename + ".png"
		if not FileAccess.file_exists(source):
			if drafts:
				continue
			push_error("Missing generated master: " + source)
			quit(1)
			return
		var path: String = folder + "character-" + entry.slug + ".png"
		var exported := export_one(source, path, float(entry.head_fraction), float(entry.head_units))
		exported.merge(entry)
		exported["image"] = path
		manifest.characters.append(exported)
		print("Exported ", entry.id, " ", entry.name, " ", exported.size)
	# Canonical comparison figures use the exact same head calibration rule.
	manifest["reference_protagonist"] = export_one("res://assets/characters/references/protagonist-front.png", folder + "reference-protagonist.png", 90.0 / 251.0, 48.0 * 90.0 / 251.0)
	manifest["reference_eleanor_original"] = export_one("res://assets/characters/references/eleanor-original-front.png", folder + "reference-eleanor-original.png", 155.0 / 720.0, 47.0 * 155.0 / 720.0)
	var revised := Image.load_from_file("res://assets/characters/masters/eleanor-style-matched.png") if FileAccess.file_exists("res://assets/characters/masters/eleanor-style-matched.png") else null
	if revised:
		var cell := Vector2i(revised.get_width() / 2, revised.get_height())
		manifest["eleanor_back"] = export_one("res://assets/characters/masters/eleanor-style-matched.png", "res://assets/characters/eleanor-back.png", 0.34, 16, Rect2i(Vector2i.ZERO, cell))
		manifest["eleanor_front"] = export_one("res://assets/characters/masters/eleanor-style-matched.png", "res://assets/characters/eleanor-front.png", 0.34, 16, Rect2i(Vector2i(cell.x, 0), cell))
	var file := FileAccess.open("res://assets/characters/draft-manifest.json" if drafts else "res://assets/characters/manifest.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest, "  "))
	print("CAST_EXPORT_COMPLETE ", manifest.characters.size())
	quit()
