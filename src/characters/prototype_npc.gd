extends StaticBody2D
## One reusable actor for every existing prototype cast design.
const Appearance = preload("res://src/characters/character_render.gd")
var identity: Dictionary
var assignment: Dictionary
var texture: Texture2D
var appearance: Dictionary

func _ready() -> void:
	position = Vector2(assignment.position[0],assignment.position[1])
	texture = load(identity.sprite)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	appearance = Appearance.single(texture)
	collision_layer = 1
	collision_mask = 0
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(14,8)
	shape.shape = rectangle
	shape.position = Vector2(0,-4)
	add_child(shape)

func _draw() -> void:
	Appearance.draw_shadow(self,float(identity.height_ratio))
	Appearance.draw_frame(self,texture,appearance,0,float(identity.height_ratio))
