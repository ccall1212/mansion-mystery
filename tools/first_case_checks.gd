extends SceneTree
## Focused integration checks and actual rendered previews, without touching saves.
var checks := 0
var failures: Array[String] = []
var room: Node2D
var capture := false

func _initialize() -> void:
	capture = "--capture" in OS.get_cmdline_user_args()
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures.append(message)
		push_error(message)

func picture(name: String) -> void:
	if not capture: return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://test-results/first-case/"+name+".png")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://test-results/first-case")
	room = load("res://src/mansion/playable_mansion.tscn").instantiate()
	root.add_child(room)
	await process_frame
	var controller: CanvasLayer = room.case_controller
	controller.open_board()
	await picture("briefing")
	controller.close()
	# Review each chair without unrelated guests covering the contact.
	var session = preload("res://src/characters/char_pose_session.gd").new(room.house,7)
	room.char_pose_session = session
	for pose in ["seated_idle_east","seated_idle_south","seated_idle_west"]:
		check(session.select(room.house,pose),"Chair pose selected: "+pose)
		var char_record: Dictionary = session.assignment.duplicate(true)
		room.house.npc_assignments = [char_record]
		room.find_char()
		room.player.visible = false
		room.guest.visible = false
		await process_frame
		check(room.npc_actors.size() == 1,"Chair preview has one Char and no crowding")
		check(is_instance_valid(room.chair_foreground),"Chair foreground installed")
		await picture(pose)
	room.player.visible = true
	session.stop(room.house)
	room.char_pose_session = null
	room.char_focus_locked = false
	controller.start()
	check(controller.state.active and room.house.npc_assignments.size() == 3,"Case starts with three unique suspects")
	var ids := {}
	for actor in room.house.npc_assignments:
		check(not ids.has(actor.id),"No duplicate case identity")
		ids[actor.id] = true
		check(room.house.feet_free(actor.room,Vector2(actor.position[0],actor.position[1]),false),"Suspect feet remain in navigable geometry")
	var state: RefCounted = controller.state
	check(state.accuse("likeness-user","foyer-knife","g_library","g_foyer",room.evidence.state).result == "blocked","Insufficient evidence cannot solve case")
	for person in state.data.suspects:
		room.house.current_room = person.room
		room.load_room()
		var actor: Node2D = room.npc_actors[0]
		room.player.position = actor.position+Vector2(0,22)
		room.interact()
		check(controller.panel.visible and state.questioned.has(person.id),"E interaction records suspect account")
		if person.name == "Char": await picture("questioning_char")
		controller.close()
	room.house.current_room = "g_library"
	room.load_room()
	room.player.position = Vector2(175,190)
	room.interact()
	check(state.floor_examined,"Library rug can be examined through actual interaction")
	await picture("floor_clue")
	controller.close()
	var evidence: RefCounted = room.evidence.state
	evidence.inspect("foyer-lens")
	evidence.collect("foyer-lens")
	evidence.inspect("foyer-knife")
	evidence.inspect("foyer-knife","tool")
	evidence.collect("foyer-knife")
	check(state.requirements(evidence).is_empty(),"All required leads are obtainable")
	room.evidence.show_notebook()
	check(room.evidence.notebook_ids.has("@case:likeness-photo01") and room.evidence.notebook_ids.has("@case:floor"),"Clue book includes statements and floor observation")
	room.evidence.notebook_index = room.evidence.notebook_ids.find("@case:likeness-photo01")
	room.evidence.draw_notebook()
	await picture("clue_book")
	room.evidence.close()
	check(state.accuse("likeness-user","foyer-knife","g_library","g_library",evidence).result == "blocked","Accusation requires foyer")
	room.house.current_room = "g_foyer"
	room.house.position = Vector2(240,294)
	room.house.arrival_portal = ""
	room.load_room()
	controller.accusation_page()
	await picture("accusation")
	check(state.accuse("likeness-photo01","foyer-knife","g_library","g_foyer",evidence).result == "wrong" and state.outcome == "investigating","Wrong suspect allows prototype retry")
	check(state.accuse("likeness-user","review-bust","g_library","g_foyer",evidence).result == "wrong","Wrong weapon rejected")
	check(state.accuse("likeness-user","foyer-knife","g_kitchen","g_foyer",evidence).result == "wrong","Wrong room rejected")
	controller.suspect_choice = 2
	controller.weapon_choice = 0
	controller.room_choice = 1
	controller.submit()
	check(state.outcome == "solved","Correct reconstruction reaches ending through UI")
	await picture("ending")
	controller.close()
	room.prepare_save()
	var saved: Dictionary = room.house.snapshot()
	var restored = preload("res://src/mansion/fixed_session.gd").new()
	check(restored.restore(saved),"Case roster, progress and ending restore from session snapshot")
	var restored_case = preload("res://src/mystery/case_state.gd").new()
	check(restored_case.restore(restored.room_memory.g_foyer.case) and restored_case.outcome == "solved" and restored_case.questioned.size() == 3,"Case notes and outcome survive round trip")
	var malformed: Dictionary = saved.duplicate(true)
	malformed.room_memory.g_foyer.case.questioned.append("unknown_person")
	check(not restored.restore(malformed),"Invalid case record rejected")
	# Reset to the briefing, not a spoiler, for the review capture collection.
	var report := {"ok":failures.is_empty(),"checks":checks,"failures":failures,"artwork_changed":false,"chair_fit":"pending_user_review"}
	var file := FileAccess.open("res://test-results/first-case/checks.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"  "))
	print("FIRST_CASE_CHECKS ",JSON.stringify(report))
	quit(0 if failures.is_empty() else 1)
