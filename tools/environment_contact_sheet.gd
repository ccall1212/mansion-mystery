extends Node
## Compose native-resolution room thumbnails, without changing the source art.

class Sheet extends Node2D:
	var entries: Array = []
	var size := Vector2i(1440, 2204)
	var cell_height := 350
	var font: Font = ThemeDB.fallback_font
	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#101a21"))
		draw_string(font, Vector2(18, 30), "SLEUTH / MANSION ENVIRONMENTS", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#dfc895"))
		draw_string(font, Vector2(18, 54), "Nine rooms, two layouts each. Side/bottom entrances vary; stairwell A goes up, B descends to basement.", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#b9c7c6"))
		for i in entries.size():
			var room: Dictionary = entries[i]
			var at := Vector2((i % 3) * 480, 70 + (i / 3) * cell_height)
			draw_texture(room.texture, at)
			draw_string(font, at + Vector2(12, cell_height - 11), "%02d%s  %s" % [room.number, room.layout, room.name], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#dfc895"))
		draw_string(font, Vector2(18, size.y - 14), "Native 480 x 320 assets. Separate actors/props; playable-room collisions and connections pending.", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#9ab0b4"))

func _ready() -> void:
	get_window().size = Vector2i(320, 180)
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/rooms/room-manifest.json"))
	var all: Array = []
	var first: Array = []
	var second: Array = []
	for room in manifest.rooms:
		for variant in room.variants:
			var entry: Dictionary = room.duplicate(true)
			entry.merge(variant, true)
			entry.texture = load(variant.asset) as Texture2D
			all.append(entry)
			if variant.layout == "A":
				first.append(entry)
			else:
				second.append(entry)
	var specs := [
		{"entries": all, "path": "environment-contact-sheet.png", "cell_height": 350},
		{"entries": first, "path": "environment-layouts-a.png", "cell_height": 350},
		{"entries": second, "path": "environment-layouts-b.png", "cell_height": 350},
	]
	for zoom in [1, 2]:
		var captures: Array = []
		for entry in all:
			var capture: Dictionary = entry.duplicate()
			var path := "res://test-results/environments/%s-%dx.png" % [entry.id, zoom]
			if not FileAccess.file_exists(path):
				continue
			capture.texture = ImageTexture.create_from_image(Image.load_from_file(path))
			captures.append(capture)
		if captures.size() == all.size():
			specs.append({"entries": captures, "path": "engine-actors-%dx.png" % zoom, "cell_height": 390})
	for spec in specs:
		var rows := ceili(spec.entries.size() / 3.0)
		var viewport := SubViewport.new()
		viewport.size = Vector2i(1440, 70 + rows * int(spec.cell_height) + 34)
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		add_child(viewport)
		var sheet := Sheet.new()
		sheet.entries = spec.entries
		sheet.size = viewport.size
		sheet.cell_height = spec.cell_height
		sheet.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		viewport.add_child(sheet)
		await get_tree().process_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var path := "res://assets/rooms/review/" + str(spec.path)
		if viewport.get_texture().get_image().save_png(path) != OK:
			get_tree().quit(1)
			return
		print("ENVIRONMENT_SHEET_SAVED ", path)
		viewport.queue_free()
	get_tree().quit()
