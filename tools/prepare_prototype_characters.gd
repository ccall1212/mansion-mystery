extends SceneTree
## Technical extraction from existing approved-for-testing artwork. No generation,
## pose synthesis, recolouring or per-character resampling. Masters stay untouched.

func _initialize() -> void:
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/review-v8/cast-catalog.json"))
	var selected := ["01","02","04","06","13","20","21"]
	var roster: Array = []
	for entry in catalog.entries:
		if not selected.has(entry.number):
			continue
		var variant: Dictionary = entry.variants[0]
		var image := Image.load_from_file(variant.source)
		assert(image != null)
		if variant.has("crop_grid"):
			var grid: Array = variant.crop_grid
			var cell := Vector2i(image.get_width()/int(grid[0]),image.get_height()/int(grid[1]))
			image = image.get_region(Rect2i(Vector2i(int(grid[2])%int(grid[0]),int(grid[2])/int(grid[0]))*cell,cell))
		if variant.has("crop_rect"):
			var rect: Array = variant.crop_rect
			image = image.get_region(Rect2i(rect[0],rect[1],rect[2],rect[3]))
		if variant.has("panel_crop"):
			var rect: Array = variant.panel_crop
			image = image.get_region(Rect2i(roundi(rect[0]*image.get_width()),roundi(rect[1]*image.get_height()),roundi(rect[2]*image.get_width()),roundi(rect[3]*image.get_height())))
		image.convert(Image.FORMAT_RGBA8)
		if not variant.get("transparent",false):
			# Trim review-panel border only, then remove its connected blue-grey matte.
			image = image.get_region(Rect2i(0,12,image.get_width(),image.get_height()-24))
			remove_matte(image)
		for y in image.get_height():
			for x in image.get_width():
				var c := image.get_pixel(x,y)
				c.a = 1.0 if c.a >= 0.5 else 0.0
				image.set_pixel(x,y,c)
		image = image.get_region(image.get_used_rect())
		var path: String = "res://assets/characters/prototype/cast-"+entry.number+".png"
		assert(image.save_png(path) == OK)
		roster.append({"id":entry.identity_id,"name":entry.name,"review_number":entry.number,
			"sprite":path,"height_ratio":entry.get("height_ratio",1.0),"source":variant.source,
			"pose":"existing_standing","appearance_status":"temporary-test-use; not final approval"})
	var file := FileAccess.open("res://assets/characters/prototype/roster.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"schema_version":1,"characters":roster},"  "))
	file.close()
	# The user's selected revised Eleanor, reused as one existing standing pose.
	var eleanor := Image.load_from_file("res://assets/characters/review-v2/masters/eleanor-proportion-v2.png")
	eleanor.convert(Image.FORMAT_RGBA8)
	for y in eleanor.get_height():
		for x in eleanor.get_width():
			var c := eleanor.get_pixel(x,y)
			c.a = 1.0 if c.a >= 0.5 else 0.0
			eleanor.set_pixel(x,y,c)
	eleanor = eleanor.get_region(eleanor.get_used_rect())
	assert(eleanor.save_png("res://assets/characters/prototype/eleanor-revised.png") == OK)
	print("EXTRACTED_EXISTING_CAST ",roster.size())
	quit()

static func removable(c: Color) -> bool:
	return c.a < 0.5 or (c.b > c.r*1.08 and c.b >= c.g and c.v < 0.30 and c.v > 0.065 and c.s < 0.60)

static func remove_matte(image: Image) -> void:
	var queue: Array[Vector2i] = []
	var width := image.get_width()
	var height := image.get_height()
	var visited := PackedByteArray()
	visited.resize(width*height)
	for x in width:
		queue.append(Vector2i(x,0))
		queue.append(Vector2i(x,height-1))
	for y in height:
		queue.append(Vector2i(0,y))
		queue.append(Vector2i(width-1,y))
	var at := 0
	while at < queue.size():
		var p: Vector2i = queue[at]
		at += 1
		if p.x < 0 or p.y < 0 or p.x >= width or p.y >= height:
			continue
		var key := p.y*width+p.x
		if visited[key] != 0:
			continue
		visited[key] = 1
		if not removable(image.get_pixelv(p)):
			continue
		image.set_pixelv(p,Color.TRANSPARENT)
		for step in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			queue.append(p+step)
