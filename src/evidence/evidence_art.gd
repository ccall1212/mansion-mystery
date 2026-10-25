extends RefCounted
## Preserve source detail without changing evidence IDs, world size or foot anchors.
var textures: Dictionary = {}
var cells: Dictionary = {}

func _init(catalog: Dictionary) -> void:
	for definition in catalog.definitions.values():
		var variants: Array = definition.conditions.values()
		for i in variants.size():
			for key in ["asset", "closeup"]:
				cells[variants[i][key]] = [definition.master, i, variants.size()]

func texture(path: String) -> Texture2D:
	if textures.has(path):
		return textures[path]
	if not cells.has(path):
		return load(path)
	var cell: Array = cells[path]
	var source := Image.load_from_file(cell[0])
	if source == null:
		return load(path)
	var width := source.get_width() / int(cell[2])
	var image := source.get_region(Rect2i(int(cell[1])*width, 0, width, source.get_height()))
	var bounds := image.get_used_rect()
	if not bounds.has_area():
		return load(path)
	textures[path] = ImageTexture.create_from_image(image.get_region(bounds))
	return textures[path]

func configure_prop(prop: Sprite2D, path: String) -> void:
	var original: Texture2D = load(path)
	var bounds := Rect2(original.get_image().get_used_rect())
	var local := Rect2(bounds.position - original.get_size()/2.0 - Vector2(0,20), bounds.size)
	prop.texture = texture(path)
	var ratio := minf(bounds.size.x/prop.texture.get_width(), bounds.size.y/prop.texture.get_height())
	prop.scale = Vector2.ONE*ratio
	prop.offset = Vector2(local.get_center().x/ratio, local.end.y/ratio-prop.texture.get_height()/2.0)
	prop.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
