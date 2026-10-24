extends Node2D
## Revised Eleanor concept; one existing standing pose, anchored at her feet.

var addressed := false
var texture: Texture2D
const Appearance = preload("res://src/characters/character_render.gd")
var appearance: Dictionary

func _ready() -> void:
	texture = load("res://assets/characters/prototype/eleanor-revised.png")
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	appearance = Appearance.single(texture)
	queue_redraw()

func _draw() -> void:
	Appearance.draw_shadow(self)
	if texture:
		Appearance.draw_frame(self,texture,appearance,0)
