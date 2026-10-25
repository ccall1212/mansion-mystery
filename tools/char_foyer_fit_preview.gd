extends SceneTree
const Appearance = preload("res://src/characters/character_render.gd")

class FitCanvas extends Node2D:
	var backdrop: Texture2D
	var character: Texture2D
	var sample: Dictionary
	var landmark: Vector2
	var show_masks := true
	func _draw() -> void:
		draw_texture_rect(backdrop,Rect2(0,0,480,320),false)
		var contact := Vector2(sample.contact[0],sample.contact[1])
		var scale_factor := Appearance.height()/1673.0
		draw_texture_rect(character,Rect2(contact-landmark*scale_factor,character.get_size()*scale_factor),false)
		if show_masks:
			for points in sample.foreground_polygons:
				var poly := PackedVector2Array()
				var uv := PackedVector2Array()
				for point in points:
					poly.append(Vector2(point[0],point[1]))
					uv.append(Vector2(point[0],point[1])/Vector2(480,320))
				draw_polygon(poly,PackedColorArray([Color.WHITE]),uv,backdrop)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.content_scale_size = Vector2i(1440,960)
	root.size = Vector2i(1440,960)
	var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/poses/char/foyer-fit-review.json"))
	var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(config.layout))
	DirAccess.make_dir_recursive_absolute("res://test-results/char-foyer-fit")
	for sample in config.samples:
		# Furniture owns the reusable contact. Char supplies only the pose landmark.
		var resolved := false
		for instance in layout.instances:
			if instance.id != sample.contact_source.instance_id: continue
			for anchor in instance.anchors:
				if anchor.id != sample.contact_source.anchor_id: continue
				assert(anchor.actor_facing == sample.actor_facing and anchor.posture == "seated")
				sample.contact = [instance.position[0]+anchor.contact[0],instance.position[1]+anchor.contact[1]]
				resolved = true
		assert(resolved,"Missing shared seat anchor")
		var selected := ""
		for argument in OS.get_cmdline_user_args():
			if argument.begins_with("--sample="):
				selected = argument.trim_prefix("--sample=")
		if not selected.is_empty() and sample.id != selected:
			continue
		var record: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://"+sample.landmark_record))
		var canvas := FitCanvas.new()
		canvas.sample = sample
		canvas.landmark = Vector2(record.export_contact[0],record.export_contact[1])
		canvas.backdrop = ImageTexture.create_from_image(Image.load_from_file(config.background))
		assert(FileAccess.get_sha256("res://"+sample.asset)==sample.asset_sha256)
		canvas.character = ImageTexture.create_from_image(Image.load_from_file("res://"+sample.asset))
		var stage := Control.new()
		root.add_child(stage)
		var bg := ColorRect.new()
		bg.size = Vector2(1440,960)
		bg.color = Color("#14232b")
		stage.add_child(bg)
		var title := Label.new()
		title.text = "CHAR / FOYER — "+sample.label
		title.position = Vector2(20,12)
		title.add_theme_font_size_override("font_size",24)
		stage.add_child(title)
		var overview := Control.new()
		overview.position = Vector2(0,62)
		overview.size = Vector2(960,640)
		overview.clip_contents = true
		stage.add_child(overview)
		canvas.scale = Vector2.ONE*2
		overview.add_child(canvas)
		var zoom_clip := Control.new()
		zoom_clip.position = Vector2(960,62)
		zoom_clip.size = Vector2(480,640)
		zoom_clip.clip_contents = true
		stage.add_child(zoom_clip)
		var zoom := FitCanvas.new()
		zoom.sample = sample
		zoom.backdrop = canvas.backdrop
		zoom.character = canvas.character
		zoom.landmark = canvas.landmark
		zoom.scale = Vector2.ONE*4
		zoom.position = -(Vector2(sample.contact[0],sample.contact[1])-Vector2(58,70))*4
		zoom_clip.add_child(zoom)
		var note := Label.new()
		note.position = Vector2(20,727)
		note.add_theme_font_size_override("font_size",18)
		stage.add_child(note)
		for masks in [false,true]:
			canvas.show_masks = masks
			zoom.show_masks = masks
			note.text = sample.contact_id+"\n\n80-unit shared adult stature; same approved PNG; seat landmark aligned to contact.\n"+("Candidate masks ON" if masks else "Raw placement / masks OFF")+"\nOverview and enlarged detail of ONE placement. Seat, skirt, feet and overlap need review."
			canvas.queue_redraw()
			zoom.queue_redraw()
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://test-results/char-foyer-fit/"+sample.id+("-masked" if masks else "-raw")+".png")
		root.remove_child(stage)
		stage.queue_free()

	print("CHAR_FOYER_FIT_READY selected contact previews rendered; source hashes unchanged; fit pending review")
	quit()
