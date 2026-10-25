extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://test-results/char-library-live")
	var game = load("res://src/characters/char_library_live.tscn").instantiate()
	root.add_child(game)
	await process_frame
	assert(game.house.feet_free("g_library",Vector2(245,280)))
	assert(not game.house.feet_free("g_library",Vector2(370,180)))
	assert(not game.evidence.memory_enabled)
	assert(game.definition().portals.is_empty())
	for i in 4:
		if i > 0: game.select_seat()
		var status: Dictionary = game.char_test_status()
		assert(status.global_identity_count == 1 and status.visible_identity_count == 1)
		assert(game.npc_actors.size()==1)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://test-results/char-library-live/"+str(game.fit.samples[i].id)+".png")
	for i in 20:
		game.select_seat()
		assert(game.npc_actors.size()==1)
		assert(game.char_test_status().global_identity_count==1)
	# Exercise the actual physics collider against the desk, not just metadata.
	game.char_focus_locked = false
	game.player.position = Vector2(370,235)
	game.player.automated_direction = Vector2.UP
	for i in 30: await physics_frame
	game.player.automated_direction = Vector2.ZERO
	assert(game.player.position.y > 198, "Player crossed desk collision")
	assert(game.player.position.y < 228, "Player did not move toward desk")
	print("CHAR_LIBRARY_LIVE_OK 4 seats / 20 rerolls / one global and visible Char / desk collision / save disabled")
	quit()
