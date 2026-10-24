extends SceneTree
## Verify single-identity ownership across every room, pose and repeated reroll.
const Session = preload("res://src/characters/char_pose_session.gd")
var checks := 0
var failures: Array[String] = []
var capture := false

func _initialize() -> void:
	capture = "--capture" in OS.get_cmdline_user_args()
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures.append(message)
		push_error(message)

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://test-results/char-live-test")
	var room: Node2D = load("res://src/mansion/playable_mansion.tscn").instantiate()
	root.add_child(room)
	await process_frame
	var house: RefCounted = room.house
	check(room.get_viewport_rect().size == Vector2(960,720),"HD internal viewport uses 960 by 720")
	check(room.ui.get_parent().scale == Vector2(2,2) and room.evidence.scale == Vector2(2,2),"HUD and inspection panels scale with the HD viewport")
	var original: Array = house.npc_assignments.duplicate(true)
	var controller := Session.new(house,20261023)
	room.char_pose_session = controller
	check(controller.assets.size() == 7,"seven approved samples available")
	var samples: Array = []
	for asset in controller.assets:
		check(controller.select(house,asset.pose_id),"requested pose has a placement: "+str(asset.pose_id))
		check(controller.count(house) == 1,"one global Char assignment")
		room.find_char()
		await process_frame
		check(room.char_test_status().visible_identity_count == 1,"one visible Char in her assigned room")
		var actor: Node2D
		for npc in room.npc_actors:
			if npc.identity.id == Session.ID:
				actor = npc
		check(actor != null,"approved pose actor instantiated")
		check(actor.appearance.reference_height == 1673,"all postures retain standing reference scale")
		check(is_equal_approx(room.camera.zoom.x,3.0),"detail camera uses 1.5x world zoom and 2x HD coordinate mapping")
		var record: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://"+str(asset.landmark_record)))
		var contact := Vector2(record.export_contact[0],record.export_contact[1])
		var painted_contact: Vector2 = actor.position+(contact-actor.appearance.pivots[0])*preload("res://src/characters/character_render.gd").height()/1673.0
		var target: Array = controller.assignment.contact_position
		check(painted_contact.distance_to(Vector2(target[0],target[1])) < 0.01,"pose contact lands on its exact anchor")
		if capture:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://test-results/char-live-test/"+str(asset.pose_id)+".png")
		samples.append({"pose_id":asset.pose_id,"room":house.current_room,"contact":controller.assignment.contact_key,"source":asset.export})
		var fixed_assignment := JSON.stringify(controller.assignment)
		for id in house.rooms:
			house.current_room = id
			room.load_room()
			var visible := 0
			for npc in room.npc_actors:
				if npc.identity.id == Session.ID:
					visible += 1
			check(visible == (1 if id == controller.assignment.room else 0),"no duplicate in "+str(id))
			check(controller.count(house) == 1 and JSON.stringify(controller.assignment) == fixed_assignment,"room visit never rerolls Char")
			check(get_nodes_in_group("character_identity::"+Session.ID).size() <= 1,"old pose nodes removed synchronously")
			await process_frame
	var rooms_seen: Dictionary = {}
	var poses_seen: Dictionary = {}
	for roll in 100:
		check(controller.select(house),"random placement succeeds")
		check(controller.count(house) == 1 and house.npc_assignments.size() == original.size(),"reroll replaces rather than appends")
		rooms_seen[controller.assignment.room] = true
		poses_seen[controller.assignment.pose_id] = true
	check(rooms_seen.size() >= 6 and poses_seen.size() == 7,"random test covers rooms and all seven poses")
	controller.stop(house)
	room.char_pose_session = null
	check(house.npc_assignments == original,"exit restores the original seeded roster exactly")
	room.load_room()
	await process_frame
	var memory_before: bool = room.evidence.memory_enabled
	var start := InputEventKey.new()
	start.keycode = KEY_F7
	start.pressed = true
	room._unhandled_key_input(start)
	await process_frame
	check(room.char_pose_session != null and not room.evidence.memory_enabled,"real F7 path disables disk persistence")
	var save_path := "user://mansion-blueprint-fixed-session.json"
	var saved_hash := FileAccess.get_sha256(save_path) if FileAccess.file_exists(save_path) else ""
	var current_assignment: String = JSON.stringify(room.char_pose_session.assignment)
	for key in [KEY_F5,KEY_F9]:
		var event := InputEventKey.new()
		event.keycode = key
		event.pressed = true
		room.evidence._input(event)
		room._unhandled_key_input(event)
	check((FileAccess.get_sha256(save_path) if FileAccess.file_exists(save_path) else "") == saved_hash,"test save cannot overwrite normal save")
	check(JSON.stringify(room.char_pose_session.assignment) == current_assignment,"test load cannot replace unique assignment")
	var stop := InputEventKey.new()
	stop.keycode = KEY_F10
	stop.pressed = true
	room._unhandled_key_input(stop)
	check(room.char_pose_session == null and room.evidence.memory_enabled == memory_before,"F10 restores normal mode and persistence")
	var report := {"ok":failures.is_empty(),"checks":checks,"failures":failures,"samples":samples,"room_visit_checks":house.rooms.size()*7,"rerolls":100,"random_rooms_seen":rooms_seen.keys(),"random_poses_seen":poses_seen.keys(),"furniture_fit":"three chair foreground previews; pending visual review"}
	var file := FileAccess.open("res://test-results/char-live-test/checks.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"  "))
	file.close()
	print("CHAR_POSE_CHECKS ",JSON.stringify(report))
	quit(0 if failures.is_empty() else 1)
