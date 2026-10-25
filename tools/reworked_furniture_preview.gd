extends SceneTree
const Library = preload("res://src/furniture/furniture_library.gd")

class ReviewCanvas extends Node2D:
	var layout: Dictionary
	var texture: Texture2D
	func _draw() -> void:
		var font := ThemeDB.fallback_font
		draw_rect(Rect2(0,0,1440,960),Color("#14232b"))
		draw_texture_rect(texture,Rect2(0,52,960,640),false)
		draw_string(font,Vector2(18,32),layout.source_room_id+" — FURNITURE / DRAFT CONTACTS",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("#edce98"))
		var n := 0
		for item in layout.instances:
			n += 1
			var origin := Library.vector(item.position)
			var bounds := Library.rect(item.bounds)
			bounds.position += origin
			bounds.position = bounds.position*2+Vector2(0,52)
			bounds.size *= 2
			draw_rect(bounds,Color("#f2c779"),false,1.5)
			draw_rect(Rect2(bounds.position,Vector2(25,22)),Color("#14232b"))
			draw_string(font,bounds.position+Vector2(2,17),str(n),HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color.WHITE)
			draw_string(font,Vector2(978,78+n*32),str(n)+". "+item.id,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("#f2d69d"))
			draw_string(font,Vector2(998,92+n*32),item.variant_id,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("#adc5d0"))
			for anchor in item.anchors:
				if not anchor.get("enabled",true): continue
				var contact := (origin+Library.vector(anchor.contact))*2+Vector2(0,52)
				var approach := (origin+Library.vector(anchor.approach))*2+Vector2(0,52)
				draw_line(contact,approach,Color(0.3,0.8,0.9,0.6),1)
				draw_circle(contact,3,Color("#ff9559"))
				draw_circle(approach,2,Color("#68deee"))
				var direction: Vector2 = {"north":Vector2.UP,"south":Vector2.DOWN,"east":Vector2.RIGHT,"west":Vector2.LEFT}.get(anchor.get("actor_facing"),Vector2.ZERO)
				draw_line(contact,contact+direction*12,Color.WHITE,1.5)
		draw_string(font,Vector2(20,732),"Gold: object ID/bounds   Orange: contact   Cyan: approach   White: actor facing",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color.WHITE)
		draw_string(font,Vector2(20,766),"Annotations only — no navigation, furniture masks or seated pose fit approved.",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("#edce98"))
		draw_string(font,Vector2(20,800),"No room artwork, live routes or approved character sprites changed.",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("#adc5d0"))

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.content_scale_size = Vector2i(1440,960)
	root.size = Vector2i(1440,960)
	var library := Library.new()
	var inventory: Array = JSON.parse_string(FileAccess.get_file_as_string("res://test-results/reworked-furniture/inventory.json"))
	var tags := 0
	for room in inventory:
		var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(room.layout))
		var errors := library.validate(layout)
		assert(errors.is_empty(),str(errors))
		assert(not library.for_background(room.background).is_empty())
		for item in layout.instances:
			assert(not item.ready_for_staging)
			tags += 1
		var canvas := ReviewCanvas.new()
		canvas.layout = layout
		canvas.texture = ImageTexture.create_from_image(Image.load_from_file(room.background))
		root.add_child(canvas)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://test-results/reworked-furniture/"+room.room+".png")
		root.remove_child(canvas)
		canvas.queue_free()
	print("REWORKED_FURNITURE_OK ",inventory.size()," layouts / ",tags," tags; all staging disabled")
	quit()
