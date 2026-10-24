extends SceneTree
## Real renderer/input-dispatch test. Only its own scene and unique save are touched.
var failures: Array[String] = []
var checks := 0
var room: Node2D

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)

func press(key: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = InputEventKey.new()
	event.keycode = key
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame

func capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://test-results/evidence/" + name + ".png")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://test-results/evidence")
	room = load("res://src/foyer/foyer.tscn").instantiate()
	root.add_child(room)
	await process_frame
	await physics_frame
	room.close_view = false
	room.update_camera()
	room.camera.reset_smoothing()
	await capture("foyer-native")
	room.player.position = Vector2(152, 272)
	await press(KEY_E)
	check(room.evidence.selected == "foyer-knife" and room.evidence.is_open() and room.player.locked, "E opens nearest object and locks movement")
	await press(KEY_M)
	check(not room.evidence.state.record("foyer-knife").discovered and not room.evidence.inset.visible, "M cannot reveal without tool")
	await press(KEY_D)
	check(room.evidence.state.record("foyer-knife").detailed, "D selects detailed stage")
	await capture("knife-normal")
	await press(KEY_ESCAPE)
	check(not room.player.locked, "closing inspection releases player")
	room.player.position = Vector2(366, 258)
	await press(KEY_E)
	check(room.evidence.selected == "foyer-lens", "lens discoverable on reading stand")
	await press(KEY_C)
	check(room.evidence.state.has_lens() and not room.evidence.props["foyer-lens"].visible, "C collects tool and removes world prop")
	await press(KEY_ESCAPE)
	room.player.position = Vector2(152, 272)
	await press(KEY_E)
	check(not room.evidence.inset.visible, "ownership alone hides inset")
	await press(KEY_M)
	check(room.evidence.state.record("foyer-knife").discovered and room.evidence.inset.visible, "explicit M reveals configured detail")
	await capture("knife-magnified")
	await press(KEY_C)
	check(not room.evidence.props["foyer-knife"].visible, "collected knife removed from room")
	await press(KEY_ESCAPE)
	room.player.position = Vector2(313, 299)
	await press(KEY_E)
	await press(KEY_M)
	check(room.evidence.selected == "foyer-mirror" and not room.evidence.state.record("foyer-mirror").discovered and not room.evidence.inset.visible, "broken innocent mirror yields no invented clue")
	await capture("mirror-innocent")
	await press(KEY_ESCAPE)
	await press(KEY_N)
	check(room.evidence.notebook and room.player.locked, "N opens clue book")
	room.evidence.notebook_index = room.evidence.notebook_ids.find("foyer-knife")
	room.evidence.draw_notebook()
	await capture("clue-book")
	var world = root.get_node("MansionWorld")
	var path := "user://mansion-blueprint-evidence-test-%d.json" % Time.get_ticks_usec()
	room.evidence.persist_memory()
	var expected: Dictionary = room.evidence.state.snapshot()
	check(world.save_session(path), "save writes investigation")
	room.evidence.state.records.clear()
	check(world.load_session(path) and room.evidence.restore_memory() and room.evidence.state.snapshot() == expected, "load restores inventory discoveries and notebook")
	var before: Dictionary = world.session.snapshot()
	check(not world.load_session(path, "u_bath") and world.session.snapshot() == before, "foyer loader cannot import another physical room")
	var damaged: Dictionary = before.duplicate(true)
	damaged.room_memory.g_foyer.evidence.records["foyer-mirror"].discovered = true
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(damaged))
	file.close()
	check(not world.load_session(path) and world.session.snapshot() == before, "corrupt investigation rejected without mutating mansion")
	DirAccess.remove_absolute(path)
	await press(KEY_ESCAPE)
	room.player.position = Vector2(240, 294)
	await press(KEY_Z)
	await capture("foyer-zoom")
	# Review every produced identity and its alternate in the actual renderer.
	room.queue_free()
	await process_frame
	var review = load("res://src/evidence/evidence_review.tscn").instantiate()
	root.add_child(review)
	await process_frame
	for i in review.ids.size():
		review.index = i
		review.show_current()
		check(review.evidence.art.texture != null, "review imports " + str(review.ids[i]))
		review.variant()
		check(review.evidence.state.valid_instance(review.evidence.state.item(review.ids[i])), "review alternate stays valid " + str(review.ids[i]))
		await process_frame
	review.index = review.ids.find("review-bust")
	review.show_current()
	await capture("object-review")
	var report := FileAccess.open("res://test-results/evidence-playtest.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"ok":failures.is_empty(), "checks":checks, "failures":failures, "input":"Godot Input.parse_input_event", "renderer":RenderingServer.get_current_rendering_method()}, "  "))
	report.close()
	print("EVIDENCE_PLAYTEST ", checks, " ", failures)
	quit(0 if failures.is_empty() else 1)
