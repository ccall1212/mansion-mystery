extends Node2D
## Review layout only: loads generated art without changing the source masters.

const ROOT := "res://assets/characters/review-v2/"
var font: Font = ThemeDB.fallback_font
var entries: Array[Dictionary] = []
var textures: Array[ImageTexture] = []

func _ready() -> void:
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	get_window().size = Vector2i(1080, 764)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	entries = [
		{"name": "Protagonist", "role": "Existing / proportion reference", "path": "res://assets/characters/references/protagonist-front.png"},
		{"name": "Eleanor original", "role": "Keep face, hair and costume", "path": "res://assets/characters/references/eleanor-original-front.png"},
		{"name": "Eleanor revision", "role": "DRAFT / compact larger-head version", "path": ROOT + "masters/eleanor-proportion-v2.png"},
		{"name": "Photo 01", "role": "DRAFT / woman in pink", "path": ROOT + "masters/photo-01-woman-v2.png"},
		{"name": "Photo 02 / Photo 03 E", "role": "DRAFT / cap worn", "path": ROOT + "masters/photo-02-hat-pair.png", "half": 0},
		{"name": "Same man / extra pose", "role": "DRAFT / cap off, scratching head", "path": ROOT + "masters/photo-02-hat-pair.png", "half": 1},
	]
	for entry in entries:
		var image := Image.load_from_file(entry.path)
		if image == null:
			push_error("Missing review master: " + str(entry.path))
			get_tree().quit(1)
			return
		image.convert(Image.FORMAT_RGBA8)
		if entry.has("half"):
			var width := image.get_width() / 2
			image = image.get_region(Rect2i(int(entry.half) * width, 0, width, image.get_height()))
		# Technical alpha cleanup in the review copy only; masters remain unchanged.
		var bounds_image: Image = image.duplicate()
		for y in bounds_image.get_height():
			for x in bounds_image.get_width():
				if bounds_image.get_pixel(x, y).a < 0.5:
					bounds_image.set_pixel(x, y, Color.TRANSPARENT)
				else:
					var color := bounds_image.get_pixel(x, y)
					color.a = 1.0
					bounds_image.set_pixel(x, y, color)
		var bounds := bounds_image.get_used_rect()
		if not bounds.has_area():
			push_error("Empty review image: " + str(entry.path))
			get_tree().quit(1)
			return
		entry["source_bounds"] = [bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y]
		textures.append(ImageTexture.create_from_image(bounds_image.get_region(bounds)))
	queue_redraw()
	capture.call_deferred()

func label_at(at: Vector2, value: String, size := 16, color := Color("#d8d9d0")) -> void:
	draw_string(font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1080, 764), Color("#1c272d"))
	label_at(Vector2(24, 31), "SLEUTH / LIKENESS & PROPORTION REVIEW", 22, Color("#dfc895"))
	label_at(Vector2(24, 55), "Drafts for your feedback. Faces and costumes are reviewable; nothing here replaces the game art yet.", 15)
	for index in textures.size():
		var origin := Vector2((index % 3) * 360, 76 + (index / 3) * 312)
		draw_rect(Rect2(origin + Vector2(8, 0), Vector2(344, 302)), Color("#2a383e"))
		draw_line(origin + Vector2(22, 236), origin + Vector2(338, 236), Color("#607075"))
		var texture: ImageTexture = textures[index]
		# All six are standing; equal standing height demonstrates head/body ratio.
		# This is a comparison render, not a production sprite scale calibration.
		var factor := 204.0 / texture.get_height()
		var size := Vector2(texture.get_size()) * factor
		draw_texture_rect(texture, Rect2(origin + Vector2(180 - size.x / 2, 236 - size.y), size), false)
		label_at(origin + Vector2(20, 266), entries[index].name, 18, Color("#e2d2ac"))
		label_at(origin + Vector2(20, 289), entries[index].role, 13, Color("#9fb3b8"))
	label_at(Vector2(24, 728), "Same standing height for comparison. Review face likeness, head size, soft shading and mansion clothing.", 15)
	label_at(Vector2(24, 751), "Group-photo concepts are in separate labelled review boards. Final cast and duplicate matches remain pending.", 13)

func capture() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var error := get_viewport().get_texture().get_image().save_png(ROOT + "likeness-style-review.png")
	if error != OK:
		push_error("Cannot save likeness review: " + error_string(error))
	get_tree().quit(0 if error == OK else 1)
