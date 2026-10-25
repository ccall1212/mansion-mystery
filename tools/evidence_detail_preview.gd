extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://test-results/evidence-detail/"+name+".png")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://test-results/evidence-detail")
	var game = load("res://src/mansion/playable_mansion.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process_unhandled_key_input(false)
	game.evidence.set_process_input(false)
	game.case_controller.set_process_input(false)
	game.evidence.memory_enabled = false
	for kind in ["bust","knife","decanter","bottle"]:
		var found := ""
		for id in game.evidence.state.catalog.instances:
			if game.evidence.state.item(id).definition == kind:
				found = id
				break
		assert(not found.is_empty())
		game.evidence.open_object(found)
		await capture(kind+"-after")
		game.evidence.art.texture = load(game.evidence.state.visible_asset(found,true))
		game.evidence.art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		await capture(kind+"-before")
		game.evidence.art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	game.evidence.close()
	game.house.current_room = "g_foyer"
	game.load_room()
	await capture("room-after")
	for id in game.evidence.props:
		var prop: Sprite2D = game.evidence.props[id]
		prop.texture = load(game.evidence.state.visible_asset(id))
		prop.scale = Vector2.ONE
		prop.offset = Vector2(0,-20)
		prop.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	await capture("room-before")
	# Compare all conditions at their original world footprint and anchor.
	var checked := 0
	for definition in game.evidence.state.catalog.definitions.values():
		for variant in definition.conditions.values():
			var prop := Sprite2D.new()
			game.evidence.artwork.configure_prop(prop,variant.asset)
			var old: Texture2D = load(variant.asset)
			var rect := Rect2(old.get_image().get_used_rect())
			var actual := prop.get_rect()
			assert(absf((actual.end.y*prop.scale.y)-(rect.end.y-40)) < 0.01)
			assert(prop.texture.get_width() > rect.size.x)
			checked += 1
			prop.free()
	print("EVIDENCE_DETAIL_PREVIEW_OK ",checked," variants; bottom anchors preserved")
	quit()
