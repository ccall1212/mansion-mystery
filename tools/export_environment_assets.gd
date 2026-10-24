extends SceneTree
## Technical nearest-neighbor export. Generated masters remain unchanged.

func _initialize() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/rooms/room-manifest.json"))
	var only := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--only="):
			only = arg.trim_prefix("--only=")
	var count := 0
	var layouts: Array = []
	for room in manifest.rooms:
		layouts.append_array(room.get("variants", [room]))
	for room in layouts:
		if not only.is_empty() and room.id != only:
			continue
		var image := Image.load_from_file(room.master)
		if image == null or absi(image.get_width() * 2 - image.get_height() * 3) > 2:
			push_error("Missing or non-3:2 environment master: " + str(room.master))
			quit(1)
			return
		if image.get_format() in [Image.FORMAT_RGBA8, Image.FORMAT_RGBAF, Image.FORMAT_RGBAH]:
			for y in image.get_height():
				for x in image.get_width():
					if image.get_pixel(x, y).a < 1.0:
						push_error("Background has transparent gaps: " + str(room.master))
						quit(1)
						return
		image.convert(Image.FORMAT_RGB8)
		image.resize(480, 320, Image.INTERPOLATE_NEAREST)
		if image.save_png(room.asset) != OK:
			quit(1)
			return
		count += 1
		print("ENVIRONMENT_EXPORTED ", room.asset)
	print("ENVIRONMENT_EXPORT_COUNT ", count)
	if FileAccess.file_exists("res://assets/rooms/masters/library-evidence-book.png"):
		export_book()
	quit(0 if count > 0 else 1)

func export_book() -> void:
	var image := Image.load_from_file("res://assets/rooms/masters/library-evidence-book.png")
	image.convert(Image.FORMAT_RGBA8)
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			color.a = 1.0 if color.a >= 0.5 else 0.0
			image.set_pixel(x, y, color)
	image = image.get_region(image.get_used_rect())
	var scale_factor := minf(22.0 / image.get_width(), 14.0 / image.get_height())
	image.resize(maxi(1, roundi(image.get_width() * scale_factor)), maxi(1, roundi(image.get_height() * scale_factor)), Image.INTERPOLATE_NEAREST)
	var canvas := Image.create_empty(24, 16, false, Image.FORMAT_RGBA8)
	canvas.fill(Color.TRANSPARENT)
	canvas.blit_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), (Vector2i(24, 16) - image.get_size()) / 2)
	var result := canvas.save_png("res://assets/rooms/props/library-evidence-book.png")
	if result != OK:
		push_error("Evidence prop export failed")
		quit(1)
