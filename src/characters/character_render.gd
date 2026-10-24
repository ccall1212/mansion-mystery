extends RefCounted
## One source-resolution-independent rendering rule for player, guest and roster.
const CONFIG_PATH := "res://assets/characters/rendering.json"
static var config: Dictionary = {}

static func settings() -> Dictionary:
	if config.is_empty():
		config = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
	return config

static func height(height_ratio := 1.0) -> float:
	return float(settings().adult_height) * height_ratio

static func sheet(texture: Texture2D, columns: int, rows: int) -> Dictionary:
	var regions := preload("res://src/foyer/sprite_frames.gd").opaque_regions(texture,columns,rows)
	var reference_height := 0.0
	var pivots: Array[Vector2] = []
	var image := texture.get_image()
	for index in regions.size():
		var region: Rect2 = regions[index]
		# Generated cells are not centred consistently (Eleanor differs by 120
		# source pixels). Align a median torso axis rather than the moving coat edge.
		var centres: Array[float] = []
		for y in range(int(region.position.y+region.size.y*0.30),int(region.position.y+region.size.y*0.55)):
			var left := int(region.end.x)
			var right := int(region.position.x)
			for x in range(int(region.position.x),int(region.end.x)):
				if image.get_pixel(x,y).a >= float(settings().alpha_threshold):
					left = mini(left,x)
					right = maxi(right,x)
			if right >= left:
				centres.append((left+right)*0.5)
		centres.sort()
		var axis: float = centres[centres.size()/2] if not centres.is_empty() else region.get_center().x
		pivots.append(Vector2(axis,region.end.y))
		reference_height = maxf(reference_height,regions[index].size.y)
	return {"regions":regions,"pivots":pivots,"reference_height":reference_height}

static func single(texture: Texture2D) -> Dictionary:
	var data := sheet(texture,1,1)
	return data

static func contact_pose(texture: Texture2D, standing_reference: float, floor_landmark: Vector2) -> Dictionary:
	# Use common standing source units for every posture, and floor feet for y-sort.
	assert(standing_reference > 0)
	return {"regions":[Rect2(Vector2.ZERO,texture.get_size())],"pivots":[floor_landmark],"reference_height":standing_reference}

static func floor_from_contact(world_contact: Vector2, source_contact: Vector2, floor_landmark: Vector2, standing_reference: float, height_ratio := 1.0) -> Vector2:
	return world_contact+(floor_landmark-source_contact)*height(height_ratio)/standing_reference

static func draw_frame(canvas: CanvasItem, texture: Texture2D, data: Dictionary, frame: int, height_ratio := 1.0) -> void:
	var region: Rect2 = data.regions[frame]
	var factor := height(height_ratio)/float(data.reference_height)
	var at: Vector2 = (region.position-data.pivots[frame])*factor
	canvas.draw_texture_rect_region(texture,Rect2(at,region.size*factor),region)

static func draw_shadow(canvas: CanvasItem, height_ratio := 1.0) -> void:
	canvas.draw_set_transform(Vector2(0,-0.5),0,Vector2(1,0.20))
	canvas.draw_circle(Vector2.ZERO,height(height_ratio)*0.18,Color(0.01,0.02,0.025,0.45))
	canvas.draw_set_transform(Vector2.ZERO)
