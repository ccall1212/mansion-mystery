extends CanvasLayer
## Presentation-only enlargement of the speaker's existing idle sprite.
## Keeps the source texture, pose, facing, proportions and world actor unchanged.
const Appearance = preload("res://src/characters/character_render.gd")
const ZOOM := 3.0
var picture: Sprite2D
var speaker_id := ""

func _ready() -> void:
	layer = 19 # Behind dialogue/HUD, above the room.
	scale = Vector2.ONE*preload("res://src/presentation.gd").scale_for(get_viewport())
	picture = Sprite2D.new()
	picture.centered = false
	picture.region_enabled = true
	picture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(picture)
	hide()

func show_actor(actor: Node2D) -> void:
	if actor == null or actor.texture == null:
		hide()
		return
	var texture: Texture2D = actor.texture
	var bounds := Rect2(texture.get_image().get_used_rect())
	if bounds.size.x <= 0 or bounds.size.y <= 0:
		hide()
		return
	var data: Dictionary = actor.appearance
	var ratio := 1.0
	var facing := "south"
	if actor.get("identity") is Dictionary:
		ratio = float(actor.identity.get("height_ratio",1.0))
		speaker_id = actor.identity.get("id","")
	if actor.get("assignment") is Dictionary:
		facing = actor.assignment.get("pose_asset",{}).get("actor_facing","south")
	var factor := Appearance.height(ratio)*ZOOM/float(data.reference_height)
	# Shared world-relative enlargement, with a uniform viewport-fit cap only.
	factor = minf(factor,minf(240.0/bounds.size.x,270.0/bounds.size.y))
	var center := 360.0 if facing == "west" else 120.0
	var pivot: Vector2 = data.pivots[0]
	picture.texture = texture
	picture.region_rect = bounds
	picture.scale = Vector2.ONE*factor
	picture.position = Vector2(center-bounds.size.x*factor/2,320-(pivot.y-bounds.position.y)*factor)
	picture.position.y = maxf(32,picture.position.y)
	show()
