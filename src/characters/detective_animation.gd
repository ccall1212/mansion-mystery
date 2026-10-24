extends RefCounted
## User-corrected horizontal cycle; independent of the preserved up/down sheet.
const Appearance = preload("res://src/characters/character_render.gd")
const MANIFEST := "res://assets/characters/detective-walk-v1/manifest.json"
var definition: Dictionary
var texture: Texture2D
var appearance: Dictionary

func _init() -> void:
	definition = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
	texture = load(definition.sheet)
	appearance = Appearance.sheet(texture,4,2)
	appearance.reference_height = float(definition.source_height)
	# Explicit stable pivots, never estimated from a swinging arm or coat edge.
	for row in 2:
		for col in 4:
			appearance.pivots[row*4+col] = Vector2(col*400+200,row*600+540)

func draw_frame(canvas: CanvasItem, facing: Vector2, frame: int) -> void:
	var row := 0 if facing.x < 0 else 1
	Appearance.draw_frame(canvas,texture,appearance,row*4+frame,float(definition.standing_height_ratio))
