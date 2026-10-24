extends Node2D
## Reuse painted chair pixels. The source background and character remain immutable.
const FIT := "res://assets/characters/poses/char/chair-fit.json"

static func settings(contact: String) -> Dictionary:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FIT))
	return data.contacts.get(contact,{})

static func seat_offset(contact: String) -> Vector2:
	var offset: Array = settings(contact).get("seat_offset",[0,0])
	return Vector2(offset[0],offset[1])

static func install(parent: Node2D, background: Texture2D, contact: String) -> void:
	var data := settings(contact)
	for points in data.get("foreground_polygons",[]):
		var shape := Polygon2D.new()
		var polygon := PackedVector2Array()
		var uv := PackedVector2Array()
		for point in points:
			polygon.append(Vector2(point[0],point[1])+Vector2(0,24))
			uv.append(Vector2(point[0],point[1])*background.get_size()/Vector2(480,320))
		shape.polygon = polygon
		shape.uv = uv
		shape.texture = background
		shape.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		parent.add_child(shape)
