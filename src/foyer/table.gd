extends Node2D
## Original foreground furniture placeholder, sorted at its footprint.

func _draw() -> void:
	# Carved reading stand; narrow legs leave room for the actor's foot collider.
	draw_rect(Rect2(-12, -7, 24, 8), Color("#10171c"))
	for x in [-10, 8]:
		draw_rect(Rect2(x, -12, 3, 12), Color("#352e27"))
		draw_rect(Rect2(x, -11, 1, 8), Color("#7c6341"))
		draw_rect(Rect2(x - 1, -2, 5, 2), Color("#483c2b"))
	draw_rect(Rect2(-14, -21, 28, 10), Color("#181e20"))
	draw_rect(Rect2(-13, -22, 26, 9), Color("#725237"))
	draw_rect(Rect2(-11, -21, 22, 6), Color("#9d7849"))
	draw_rect(Rect2(-10, -20, 20, 4), Color("#806340"))
	for x in [-9, -3, 4, 9]:
		draw_rect(Rect2(x, -20, 1, 3), Color("#6c5034"))
	draw_rect(Rect2(-12, -13, 24, 2), Color("#ad854c"))
	for x in [-8, 0, 8]:
		draw_rect(Rect2(x, -12, 1, 2), Color("#a78b55"))
	# Closed notebook and letter, each with a contrasting edge.
	draw_rect(Rect2(-8, -24, 10, 6), Color("#182c30"))
	draw_rect(Rect2(-7, -24, 8, 1), Color("#627a6b"))
	draw_rect(Rect2(-7, -19, 8, 1), Color("#b2a986"))
	draw_rect(Rect2(3, -21, 6, 3), Color("#b3a380"))
	draw_rect(Rect2(4, -20, 4, 1), Color("#6d6b59"))
