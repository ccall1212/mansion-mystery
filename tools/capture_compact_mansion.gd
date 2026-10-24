extends SceneTree
## One current full-room capture per active space. Does not modify source art.
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://test-results/compact-mansion")
	var game: Node2D = load("res://src/mansion/playable_mansion.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process_unhandled_key_input(false)
	game.evidence.set_process_input(false)
	game.case_controller.set_process_input(false)
	game.close_view = false
	for id in game.house.rooms:
		game.close_dialogue()
		game.evidence.close()
		game.house.current_room = id
		var places: Array = game.house.roster.candidates(game.house,id)
		if not places.is_empty():
			game.house.position = Vector2(places[0][0],places[0][1])
		game.load_room()
		game.player.locked = true
		game.arrival_time = 0
		game.update_camera()
		game.camera.reset_smoothing()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://test-results/compact-mansion/"+id+".png")
	print("COMPACT_REVIEW_CAPTURED ",game.house.rooms.size())
	quit()
