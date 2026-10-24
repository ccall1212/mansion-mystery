extends StaticBody2D
## Approved full-sprite pose, using source contacts and the shared stature rule.
const Appearance = preload("res://src/characters/character_render.gd")
static var cache: Dictionary = {}
var identity: Dictionary
var assignment: Dictionary
var texture: Texture2D
var appearance: Dictionary

func _ready() -> void:
	var asset: Dictionary = assignment.pose_asset
	var path: String = "res://"+asset.export
	assert(asset.approval == "approved" and FileAccess.get_sha256(path) == asset.export_sha256,"Unapproved or changed pose asset")
	if not cache.has(path):
		cache[path] = ImageTexture.create_from_image(Image.load_from_file(path))
	texture = cache[path]
	var record: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://"+asset.landmark_record))
	var feet: Array = record.source_landmarks.feet
	var padding: Array = record.export_padding
	var floor_landmark := Vector2(feet[0]+padding[0],feet[1]+padding[1])
	appearance = Appearance.contact_pose(texture,float(asset.standing_reference_height),floor_landmark)
	position = Vector2(assignment.position[0],assignment.position[1])
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_to_group("character_identity::"+str(identity.id))
	collision_layer = 1
	collision_mask = 0
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(14,8)
	shape.shape = rectangle
	shape.position = Vector2(0,-4)
	add_child(shape)

func _draw() -> void:
	if texture == null:
		return
	Appearance.draw_shadow(self,float(identity.height_ratio))
	Appearance.draw_frame(self,texture,appearance,0,float(identity.height_ratio))
