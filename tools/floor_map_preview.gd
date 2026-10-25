extends SceneTree
const Map = preload("res://src/mansion/floor_map.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://test-results/floor-map")
	var game = load("res://src/mansion/playable_mansion.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process_unhandled_key_input(false)
	game.close_view = false
	for entry in [["g_library",4],["u_master",2],["b_store",1]]:
		game.house.current_room = entry[0]
		game.house.visited = ["g_foyer","g_main_stair","g_library",entry[0]]
		game.house.position = Vector2(240,295)
		game.load_room()
		game.arrival_time = 0
		game.player.locked = true
		var model: Dictionary = Map.model(game.house)
		assert(model.main_rooms == entry[1])
		var highlighted := 0
		for node in model.nodes:
			assert(game.house.rooms[node.id].floor == model.floor)
			if node.current: highlighted += 1
		assert(highlighted == 1)
		for edge in model.edges:
			assert(edge[0] >= 0 and edge[1] < model.nodes.size())
		game.update_camera()
		game.camera.reset_smoothing()
		game.ui.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://test-results/floor-map/"+entry[0]+".png")
	print("FLOOR_MAP_PREVIEW_OK all three floors / 4-2-1 main room counts / one highlighted current room")
	quit()
