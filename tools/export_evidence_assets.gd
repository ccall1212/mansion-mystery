extends SceneTree
## Technical cell split/alpha trim/nearest exports; generated source art is preserved.
const LIMITS := {"knife": Vector2i(23, 25), "bust": Vector2i(26, 32), "bottle": Vector2i(25, 27), "hammer": Vector2i(24, 26), "stool": Vector2i(30, 31), "mirror": Vector2i(21, 24), "poker": Vector2i(30, 38), "magnifier": Vector2i(18, 20)}

func _initialize() -> void:
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/objects/object-manifest.json"))
	for id in catalog.definitions:
		var source := Image.load_from_file("res://assets/objects/masters/" + id + ".png")
		assert(source != null, "Missing master " + id)
		var variants: Array = catalog.definitions[id].conditions.keys()
		var width := source.get_width() / variants.size()
		for i in variants.size():
			var region := source.get_region(Rect2i(i * width, 0, width, source.get_height()))
			region = opaque_trim(region)
			var variant: Dictionary = catalog.definitions[id].conditions[variants[i]]
			export_fit(region, Vector2i(32, 40), LIMITS.get(id, Vector2i(28, 34)), variant.asset, true)
			export_fit(region, Vector2i(160, 160), Vector2i(148, 148), variant.closeup, false)
	var details := Image.load_from_file("res://assets/objects/masters/details.png")
	assert(details != null)
	var detail_width := details.get_width() / 3
	var names := ["red-trace", "fiber", "filings"]
	for i in 3:
		var patch := opaque_trim(details.get_region(Rect2i(i * detail_width, 0, detail_width, details.get_height())))
		export_fit(patch, Vector2i(160, 160), Vector2i(148, 148), "res://assets/objects/closeups/detail-" + names[i] + ".png", false)
	print("EVIDENCE_EXPORTED world/inspection variants and three forensic insets")
	quit()

func opaque_trim(source: Image) -> Image:
	source.convert(Image.FORMAT_RGBA8)
	for y in source.get_height():
		for x in source.get_width():
			var pixel := source.get_pixel(x, y)
			pixel.a = 1.0 if pixel.a >= 0.5 else 0.0
			source.set_pixel(x, y, pixel)
	return source.get_region(source.get_used_rect())

func export_fit(source: Image, canvas_size: Vector2i, bounds: Vector2i, path: String, feet: bool) -> void:
	var image: Image = source.duplicate()
	var ratio := minf(float(bounds.x) / source.get_width(), float(bounds.y) / source.get_height())
	image.resize(maxi(1, roundi(source.get_width() * ratio)), maxi(1, roundi(source.get_height() * ratio)), Image.INTERPOLATE_NEAREST)
	var canvas := Image.create_empty(canvas_size.x, canvas_size.y, false, Image.FORMAT_RGBA8)
	canvas.fill(Color.TRANSPARENT)
	var at: Vector2i = (canvas_size - image.get_size()) / 2
	if feet:
		at.y = canvas_size.y - image.get_height() - 1
	canvas.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), at)
	assert(canvas.save_png(path) == OK)
