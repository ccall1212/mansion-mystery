extends Node2D
## First playable room. Art, colliders, clue data and UI are independent.

const PlayerScript = preload("res://src/foyer/player.gd")
const Presentation = preload("res://src/presentation.gd")
const CLOCK := Vector2(82, 184)
const DOOR := Vector2(240, 180)
const CHAIR := Rect2(396, 174, 57, 23)
const GUEST_POSITION := Vector2(346, 190)
const TEST_CHECKS := 14
const QUESTION_TOPICS := ["Where were you at 11:47?", "Did you hear anything unusual?", "What about the stopped clock?", "Leave conversation"]
var player: CharacterBody2D
var guest: Node2D
var questioning := false
var question_index := 0
var guest_questioned := false
var answers_heard: Array[int] = []
var guest_answer := false
var dialogue := ""
var dialogue_heading := ""
var clue_found := false
var elapsed := 0.0
var test_mode := false
var failures: Array[String] = []
var font: Font = ThemeDB.fallback_font
var ui: Node2D
var dialogue_portrait: CanvasLayer
var prompt := ""
var dev_directory := ""
var state_elapsed := 0.0
var camera: Camera2D
var close_view := true
var evidence: CanvasLayer
var world: Node2D
var room_label := "THE UNQUIET HOUSE  /  FOYER"
var scene_id := "foyer"

func _ready() -> void:
	DisplayServer.window_set_title("Sleuth — The Unquiet House")
	Presentation.fit_window_to_screen()
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--dev-session="):
			var requested := argument.trim_prefix("--dev-session=")
			if RegEx.create_from_string("^res://test-results/remake-[a-f0-9]{32}$").search(requested):
				dev_directory = requested
	RenderingServer.set_default_clear_color(Color("#080e15"))
	var background: Sprite2D = $Background
	background.scale = Vector2(480.0 / background.texture.get_width(), 320.0 / background.texture.get_height())
	world = Node2D.new()
	world.y_sort_enabled = true
	add_child(world)
	for bounds in [Rect2(0, 0, 480, 160), Rect2(0, 0, 16, 360), Rect2(464, 0, 16, 360), Rect2(0, 331, 480, 29), Rect2(0, 316, 209, 44), Rect2(273, 316, 207, 44), Rect2(166, 155, 148, 24), Rect2(68, 162, 28, 20), Rect2(17, 160, 49, 18), CHAIR]:
		add_obstacle(bounds)
	player = PlayerScript.new()
	player.name = "Investigator"
	player.position = Vector2(240, 294)
	world.add_child(player)
	guest = preload("res://src/foyer/guest.gd").new()
	guest.name = "EleanorVale"
	guest.position = GUEST_POSITION
	world.add_child(guest)
	add_obstacle(Rect2(GUEST_POSITION - Vector2(7, 6), Vector2(14, 8)))
	# Foreground side-table: separate draw-sorted object demonstrates correct occlusion.
	var table := Node2D.new()
	table.name = "ReadingStand"
	table.position = Vector2(366, 246)
	table.set_script(load("res://src/foyer/table.gd"))
	world.add_child(table)
	add_obstacle(Rect2(354, 237, 24, 10))
	evidence = preload("res://src/evidence/evidence_controller.gd").new()
	evidence.owner_room = self
	add_child(evidence)
	evidence.place_objects(world, "g_foyer")
	evidence.modal_changed.connect(func(open: bool): player.locked = open or not dialogue.is_empty())
	clue_found = not evidence.clock_note.is_empty()
	camera = Camera2D.new()
	camera.name = "FollowCamera"
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 9.0
	add_child(camera)
	update_camera()
	camera.reset_smoothing()
	# UI stays in screen space while the room and investigator zoom together.
	var hud := CanvasLayer.new()
	hud.layer = 20
	hud.scale = Vector2.ONE*Presentation.scale_for(get_viewport())
	add_child(hud)
	ui = Node2D.new()
	ui.draw.connect(draw_ui)
	hud.add_child(ui)
	dialogue_portrait = preload("res://src/characters/dialogue_portrait.gd").new()
	add_child(dialogue_portrait)
	test_mode = "--foyer-test" in OS.get_cmdline_user_args()
	if test_mode:
		call_deferred("run_checks")
	if "--foyer-capture" in OS.get_cmdline_user_args():
		call_deferred("save_capture")

func add_obstacle(bounds: Rect2) -> void:
	var body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = bounds.size
	shape.shape = rect
	body.position = bounds.get_center()
	body.add_child(shape)
	add_child(body)

func _process(delta: float) -> void:
	elapsed += delta
	state_elapsed += delta
	update_camera()
	prompt = ""
	if dialogue.is_empty() and not evidence.is_open():
		var object_id: String = evidence.nearby(player.position)
		if not object_id.is_empty():
			prompt = "[ E ]  " + evidence.state.definition(object_id).name
		elif player.position.distance_to(GUEST_POSITION) < 42:
			prompt = "[ E / ENTER ]  Question Eleanor Vale"
		elif player.position.distance_to(CLOCK) < 37:
			prompt = "[ E / ENTER ]  Examine the grandfather clock"
		elif player.position.distance_to(DOOR) < 34:
			prompt = "[ E / ENTER ]  Examine the locked front doors"
	ui.queue_redraw()
	if not dev_directory.is_empty() and state_elapsed > 0.1:
		state_elapsed = 0.0
		write_dev_state()
		if FileAccess.file_exists(dev_directory + "/capture.request"):
			DirAccess.remove_absolute(dev_directory + "/capture.request")
			capture_for_tools()

func update_camera() -> void:
	var output_scale := Presentation.scale_for(get_viewport())
	if close_view:
		camera.zoom = Vector2.ONE*Presentation.DETAIL_ZOOM*output_scale
		var focus := camera_focus()
		var half_view := Presentation.REFERENCE/(2*Presentation.DETAIL_ZOOM)
		camera.position = Vector2(clampf(focus.x,half_view.x,480-half_view.x),clampf(focus.y-18,24+half_view.y,344-half_view.y))
	else:
		camera.zoom = Vector2.ONE*output_scale
		camera.position = Vector2(240, 180)
	camera.force_update_scroll()

func camera_focus() -> Vector2:
	return player.position

func write_dev_state() -> void:
	var state := {"scene": scene_id, "position": {"x": player.position.x, "y": player.position.y}, "clue_found": clue_found, "dialogue_open": not dialogue.is_empty(), "movement_locked": player.locked, "camera_zoom": camera.zoom.x/Presentation.scale_for(get_viewport()), "questioning": questioning, "question_index": question_index, "guest_questioned": guest_questioned, "answers_heard": answers_heard, "dialogue_heading": dialogue_heading, "dialogue_text": dialogue}
	var view_size := get_viewport_rect().size
	var window_size := DisplayServer.window_get_size()
	state["presentation"] = {"viewport":[view_size.x,view_size.y],"reference_canvas":[480,360],"render_zoom":camera.zoom.x,"adult_height":preload("res://src/characters/character_render.gd").height(),"window_size":[window_size.x,window_size.y],"fullscreen":DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN,DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]}
	var mansion = get_node("/root/MansionWorld").session
	state["mansion"] = {"blueprint_id": mansion.blueprint.id, "seed": mansion.seed_id, "room_id": mansion.current_room, "floor": mansion.floor_id()}
	state["animation"] = {"frame":player.current_frame,"phase":player.walk_time,"walking":player.is_walking,"speed":player.speed,"distance":player.distance_walked,"source":("user-horizontal-v1" if player.horizontal_animation and player.is_walking and absf(player.facing.x)>0.4 else "original-detective")}
	if mansion.get("npc_assignments") != null:
		state["npc_seed"] = mansion.npc_seed
		state["npc_assignments"] = mansion.npc_assignments
	state["evidence"] = evidence.state.snapshot()
	var furniture: Variant = get("furniture_annotations")
	if furniture is Dictionary:
		var ids: Array = []
		for item in furniture.get("instances",[]):
			ids.append(item.id)
		state["furniture"] = {"ids":ids,"overlay":get("furniture_debug")}
	state["evidence_open"] = evidence.is_open()
	state["evidence_selected"] = evidence.selected
	if has_method("char_test_status"):
		state["char_pose_test"] = call("char_test_status")
	var file := FileAccess.open(dev_directory + "/state.tmp", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(state))
		file.close()
		DirAccess.rename_absolute(dev_directory + "/state.tmp", dev_directory + "/state.json")

func capture_for_tools() -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(dev_directory + "/capture.tmp.png")
	DirAccess.rename_absolute(dev_directory + "/capture.tmp.png", dev_directory + "/capture.png")

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ESCAPE:
		close_dialogue()
	elif questioning:
		if event.keycode in [KEY_UP, KEY_W]:
			question_index = posmod(question_index - 1, QUESTION_TOPICS.size())
		elif event.keycode in [KEY_DOWN, KEY_S]:
			question_index = (question_index + 1) % QUESTION_TOPICS.size()
		elif event.keycode in [KEY_E, KEY_ENTER, KEY_SPACE]:
			answer_question()
		ui.queue_redraw()
	elif event.keycode in [KEY_E, KEY_ENTER, KEY_SPACE]:
		interact()
	elif event.keycode == KEY_R:
		player.position = Vector2(240, 294)
		close_dialogue()
		update_camera()
		camera.reset_smoothing()
	elif event.keycode == KEY_Z:
		close_view = not close_view
		update_camera()
		camera.reset_smoothing()

func interact() -> void:
	if evidence.is_open():
		return
	if guest_answer:
		open_questions()
		return
	if not dialogue.is_empty():
		close_dialogue()
		return
	var object_id: String = evidence.nearby(player.position)
	if not object_id.is_empty():
		evidence.open_object(object_id)
		return
	if player.position.distance_to(GUEST_POSITION) < 42:
		question_index = 0
		open_questions()
		return
	elif player.position.distance_to(CLOCK) < 37:
		dialogue_heading = "THE GRANDFATHER CLOCK"
		dialogue = "The hands stopped at 11:47. A fresh scratch marks the brass latch.\nSomeone opened this case long after the house fell silent."
		clue_found = true
		evidence.clock_note = "Clock: stopped at 11:47; fresh scratch on the brass latch."
		evidence.persist_memory()
	elif player.position.distance_to(DOOR) < 34:
		dialogue_heading = "THE LOCKED FRONT DOORS"
		dialogue = "The front doors are locked. No one is leaving until\nwe understand what happened in this house."
	player.locked = not dialogue.is_empty()
	ui.queue_redraw()

func close_dialogue() -> void:
	if dialogue_portrait != null:
		dialogue_portrait.hide()
	dialogue = ""
	questioning = false
	guest_answer = false
	guest.addressed = false
	guest.queue_redraw()
	player.locked = false

func open_questions() -> void:
	dialogue_portrait.show_actor(guest)
	player.facing = (GUEST_POSITION - player.position).normalized()
	player.queue_redraw()
	dialogue_heading = "ELEANOR VALE  /  HOUSE GUEST"
	dialogue = "question_menu"
	questioning = true
	guest_answer = false
	guest.addressed = true
	guest.queue_redraw()
	player.locked = true
	ui.queue_redraw()

func answer_question() -> void:
	if question_index == 3:
		close_dialogue()
		return
	var answers := [
		"I was here by the window. I watched the last carriage leave.\nI never went upstairs. You may ask the driver, if he returns.",
		"Footsteps, above us. Then a door shut, very softly.\nWhoever it was did not want the house to hear them.",
		"It was still ticking when I came down. Then someone\nopened the case. I thought they were winding it."]
	if question_index == 2 and not clue_found:
		dialogue = "The old clock? I haven't looked at it closely tonight.\nYou should examine it before drawing conclusions."
	else:
		dialogue = answers[question_index]
	if not answers_heard.has(question_index):
		answers_heard.append(question_index)
	guest_questioned = true
	questioning = false
	guest_answer = true
	ui.queue_redraw()

func text(at: Vector2, value: String, size := 10, color := Color("#c4c5bd")) -> void:
	ui.draw_string(font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func draw_ui() -> void:
	ui.draw_rect(Rect2(0, 0, 480, 24), Color("#0b141d"))
	ui.draw_line(Vector2(16, 23), Vector2(464, 23), Color("#5b5747"))
	text(Vector2(16, 16), "S L E U T H", 12, Color("#dcc99c"))
	text(Vector2(123, 15), room_label, 9, Color("#859b9e"))
	var observation_count := int(clue_found)
	for record in evidence.state.records.values():
		observation_count += int(record.discovered)
	text(Vector2(365, 15), "CLUES  %d" % observation_count, 10, Color("#c1b28c"))
	ui.draw_rect(Rect2(0, 344, 480, 16), Color("#0b141d"))
	text(Vector2(12, 355), "WASD Move  E Inspect  N Clue book  Z Zoom  R Reset  F5 Save / F9 Load", 9, Color("#95a8ab"))
	if not prompt.is_empty() and dialogue.is_empty():
		ui.draw_rect(Rect2(78, 320, 324, 18), Color(0.025, 0.05, 0.07, 0.94))
		text(Vector2(90, 332), prompt, 10, Color("#e0cfa6"))
	if not dialogue.is_empty():
		var top := 222 if questioning else 254
		ui.draw_rect(Rect2(15, top, 450, 338 - top), Color("#080e14"))
		ui.draw_rect(Rect2(17, top + 2, 446, 334 - top), Color("#8b7952"), false, 1)
		ui.draw_rect(Rect2(20, top + 5, 440, 328 - top), Color("#14232d"))
		text(Vector2(30, top + 20), dialogue_heading, 10, Color("#dfc48d"))
		if questioning:
			for index in QUESTION_TOPICS.size():
				var selected := index == question_index
				if selected:
					ui.draw_rect(Rect2(27, top + 27 + index * 17, 422, 17), Color("#28434a"))
				text(Vector2(33, top + 39 + index * 17), (">  " if selected else "   ") + QUESTION_TOPICS[index], 11, Color("#e0d3ac") if selected else Color("#b7c5c5"))
			text(Vector2(30, 325), "UP / DOWN  Choose     ENTER  Ask     ESC  Leave", 9, Color("#91a6a9"))
		else:
			var lines := dialogue.split("\n")
			for index in lines.size():
				text(Vector2(30, 291 + index * 14), lines[index], 11, Color("#d3d8d2"))
			text(Vector2(255 if guest_answer else 316, 325), "ENTER  More questions    ESC  Leave" if guest_answer else "ENTER / ESC   Close", 9, Color("#91a6a9"))
	# Fine drifting dust; tiny and deliberately low contrast.
	for i in 12:
		var x := fmod(float(i * 43) + elapsed * 1.2, 430.0) + 25.0
		var y := fmod(float(i * 29) + elapsed * 2.0, 170.0) + 152.0
		if dialogue.is_empty() or y < 250:
			ui.draw_rect(Rect2(floorf(x), floorf(y), 1, 1), Color(0.6, 0.7, 0.7, 0.16))

func verify(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)

func drive(direction: Vector2, frames: int) -> void:
	player.automated_direction = direction
	for frame in frames:
		await get_tree().physics_frame
	player.automated_direction = Vector2.ZERO
	await get_tree().physics_frame

func run_checks() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	var start := player.position
	await drive(Vector2.LEFT, 30)
	verify(player.position.x < start.x - 20, "Player did not move left")
	await drive(Vector2.LEFT, 240)
	verify(player.position.x >= 20, "Player crossed west wall")
	player.position = Vector2(82, 210)
	await drive(Vector2.UP, 40)
	verify(player.position.y >= 184, "Player crossed clock collision")
	interact()
	verify(clue_found and player.locked and not dialogue.is_empty(), "Clock clue did not open")
	start = player.position
	await drive(Vector2.RIGHT, 10)
	verify(player.position.distance_to(start) < 0.1, "Dialogue did not pause movement")
	close_dialogue()
	verify(not player.locked and dialogue.is_empty(), "Dialogue did not close")
	interact()
	verify(clue_found and not dialogue.is_empty(), "Clock inspection could not be repeated")
	close_dialogue()
	player.position = Vector2(366, 266)
	await drive(Vector2.UP, 40)
	verify(player.position.y >= 249, "Player crossed side table")
	player.position = GUEST_POSITION + Vector2(0, 27)
	interact()
	verify(questioning and player.locked and guest.addressed, "Guest questioning did not start")
	question_index = 0
	answer_question()
	verify(guest_questioned and answers_heard.has(0) and dialogue.contains("carriage"), "Guest alibi not recorded")
	interact()
	verify(questioning and player.locked, "Could not return to question menu")
	question_index = 2
	answer_question()
	verify(dialogue.contains("ticking") and answers_heard.has(2), "Clock evidence did not unlock contextual response")
	close_dialogue()
	verify(not player.locked and not questioning and not guest.addressed, "Guest conversation did not release player")
	player.position = DOOR + Vector2(0, 25)
	var before_door := player.position
	interact()
	verify(dialogue_heading == "THE LOCKED FRONT DOORS" and dialogue.contains("No one is leaving") and player.locked and player.position == before_door, "Front door did not remain a locked exterior boundary")
	close_dialogue()
	var report := {"ok": failures.is_empty(), "failures": failures, "checks": TEST_CHECKS, "scene": "foyer"}
	DirAccess.make_dir_recursive_absolute("res://test-results")
	var file := FileAccess.open("res://test-results/foyer-engine-tests.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	print("FOYER_TEST_RESULT ", JSON.stringify(report))
	get_tree().quit(0 if failures.is_empty() else 1)

func save_capture() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://test-results/screenshots")
	get_viewport().get_texture().get_image().save_png("res://test-results/screenshots/foyer-native.png")
