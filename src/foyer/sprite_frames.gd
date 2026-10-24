extends RefCounted
## Ignore almost-transparent generation fringes so the visible soles anchor to the floor.

static func opaque_regions(texture: Texture2D, columns: int, rows: int) -> Array[Rect2]:
	var image := texture.get_image()
	var result: Array[Rect2] = []
	var cell := Vector2i(image.get_width() / columns, image.get_height() / rows)
	for row in rows:
		for column in columns:
			var origin := Vector2i(column, row) * cell
			var rough := image.get_region(Rect2i(origin, cell)).get_used_rect()
			var minimum := cell
			var maximum := Vector2i(-1, -1)
			for y in range(rough.position.y, rough.end.y):
				for x in range(rough.position.x, rough.end.x):
					if image.get_pixel(origin.x + x, origin.y + y).a >= 0.5:
						minimum = minimum.min(Vector2i(x, y))
						maximum = maximum.max(Vector2i(x, y))
			if maximum.x < 0:
				result.append(Rect2(Vector2(origin), Vector2(cell)))
			else:
				result.append(Rect2(Vector2(origin + minimum), Vector2(maximum - minimum + Vector2i.ONE)))
	return result
