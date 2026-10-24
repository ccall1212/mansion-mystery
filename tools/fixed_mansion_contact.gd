extends SceneTree
## Assemble real native viewport captures; this creates no new environment art.
var viewport: SubViewport
var canvas: Node2D
var textures: Array[Texture2D] = []
var labels: Array[String] = []
var font: Font

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/mansion/fixed-mansion.json"))
	for floor_id in [0,1,-1]:
		for id in data.rooms:
			if int(data.rooms[id].floor) == floor_id:
				var source := Image.load_from_file("res://test-results/fixed-mansion/"+id+".png")
				assert(source != null and source.get_size() == Vector2i(480,360))
				textures.append(ImageTexture.create_from_image(source))
				labels.append(data.rooms[id].name)
	font = ThemeDB.fallback_font
	viewport = SubViewport.new()
	viewport.size = Vector2i(1440,2388)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	canvas = Node2D.new()
	canvas.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	canvas.draw.connect(paint)
	viewport.add_child(canvas)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	viewport.get_texture().get_image().save_png("res://assets/mansion/review/fixed-mansion-contact.png")
	print("FIXED_CONTACT_SAVED")
	quit()

func paint() -> void:
	canvas.draw_rect(Rect2(0,0,1440,2388),Color("#101d28"))
	canvas.draw_string(font,Vector2(20,29),"SLEUTH / ONE FIXED WALKABLE MANSION — 18 ROOM SPACES",HORIZONTAL_ALIGNMENT_LEFT,-1,23,Color("#e0c58d"))
	canvas.draw_string(font,Vector2(20,53),"Existing backgrounds, provisional room dressing · Actual engine captures · E enters marked passages · TAB opens room directory",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("#a3b6ba"))
	for column in 3:
		canvas.draw_string(font,Vector2(column*480+20,84),["GROUND FLOOR","UPPER FLOOR","BASEMENT"][column],HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("#e0c58d"))
		for row in 6:
			var i := column*6+row
			var at := Vector2(column*480,100+row*380)
			canvas.draw_texture(textures[i],at)
			canvas.draw_string(font,at+Vector2(12,375),labels[i],HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("#e0c58d"))
