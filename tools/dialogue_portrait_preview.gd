extends SceneTree
## Quick native preview of the existing idle artwork for all current speakers.
var game: Node2D

func _initialize() -> void:
	call_deferred("run")

func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://test-results/dialogue-portraits/"+name+".png")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://test-results/dialogue-portraits")
	game = load("res://src/mansion/playable_mansion.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_process_unhandled_key_input(false)
	game.evidence.set_process_input(false)
	game.case_controller.set_process_input(false)
	var normal: Array = game.house.npc_assignments.duplicate(true)
	game.case_controller.start()
	for person in game.case_controller.state.data.suspects:
		game.house.current_room = person.room
		game.load_room()
		game.case_controller.talk(person.id)
		assert(game.dialogue_portrait.visible)
		await capture(person.name.to_lower().replace(" ","_"))
		game.case_controller.close()
		assert(not game.dialogue_portrait.visible)
	game.case_controller.state.active = false
	game.house.npc_assignments = normal
	for person in game.house.roster.cast:
		if person.name in ["Char","Justin","Chris"]: continue
		var assignment: Dictionary = {}
		for candidate in normal:
			if candidate.id == person.id:
				assignment = candidate
		if assignment.is_empty():
			# A compact random house may have fewer eligible guest positions.
			# Review the missing roster member in a temporary fixture, not a save.
			assignment = {"id":person.id,"room":"g_library","position":[240,280],"statement_index":0}
		game.house.npc_assignments = [assignment]
		game.house.current_room = assignment.room
		game.load_room()
		var actor: Node2D = game.npc_actors[0]
		game.player.position = actor.position+Vector2(0,22)
		game.interact()
		assert(game.dialogue_portrait.visible)
		await capture(person.name.to_lower().replace(" ","_"))
		game.close_dialogue()
	game.house.current_room = "g_foyer"
	game.load_room()
	game.open_questions()
	assert(game.dialogue_portrait.visible)
	await capture("eleanor")
	game.close_dialogue()
	print("DIALOGUE_PORTRAITS_READY 8 existing speakers; no source images changed")
	quit()
