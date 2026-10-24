extends SceneTree

const Session = preload("res://src/mansion/mansion_session.gd")
var failures: Array[String] = []
var checks := 0

func verify(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var world := get_root().get_node("MansionWorld")
	verify(not world.session.blueprint.is_empty() and world.session.floor_id() == 0, "Startup did not select a ground-floor mansion")
	var seen: Dictionary = {}
	for seed_value in range(4):
		var a = Session.new()
		var b = Session.new()
		a.new_game(seed_value)
		b.new_game(seed_value)
		seen[a.blueprint.id] = true
		verify(a.snapshot() == b.snapshot(), "Seed did not reproduce template/assets")
		var locked_before: Dictionary = a.snapshot()
		verify(a.entry_port == "north" and a.route_to("g_grounds").is_empty(), "Front-door orientation/exterior boundary incorrect")
		verify(a.traverse("locked-front-door").is_empty() and a.snapshot() == locked_before, "Locked front door allowed escape")
		var old_save := locked_before.duplicate(true)
		old_save.schema_version = 1
		verify(not a.restore(old_save) and a.snapshot() == locked_before, "Old oversized-layout save was accepted")
		var original_assets: Dictionary = a.assets.duplicate(true)
		for destination in ["u_main_stair", "g_service_stair", "b_service_stair", "g_foyer"]:
			var path: Array = a.route_to(destination)
			verify(not path.is_empty() or a.current_room == destination, "Destination unreachable")
			for link_id in path:
				var from: String = a.current_room
				var before_floor: int = a.floor_id()
				var result: Dictionary = a.traverse(link_id)
				verify(not result.is_empty() and result.from == from, "Invalid traversal result")
				verify(a.floor_id() == int(a.rooms[a.current_room].floor), "Floor memory drift")
				if result.kind == "stairs":
					verify(absi(a.floor_id() - before_floor) == 1, "Stairs skipped a level")
		verify(a.current_room == "g_foyer" and a.floor_id() == 0, "Return to foyer failed")
		verify(a.assets == original_assets, "Art rerolled on returning")
		a.room_memory["g_foyer"] = {"clock_found": true, "last_position": [240, 245]}
		var before: Dictionary = a.snapshot()
		var text := JSON.stringify(before)
		verify(b.restore(JSON.parse_string(text)), "JSON save/load round trip failed")
		verify(JSON.parse_string(JSON.stringify(b.snapshot())) == JSON.parse_string(JSON.stringify(before)), "Restored state differs")
		# JSON represents untyped numeric room memory as floats on read.
		before = b.snapshot()
		verify(b.room_memory["g_foyer"].clock_found, "Room memory lost")
		verify(b.traverse("not-a-real-door").is_empty() and b.snapshot() == before, "Unrelated door changed state")
		var corrupted := before.duplicate(true)
		corrupted["floor"] = 99
		verify(not b.restore(corrupted) and b.snapshot() == before, "Invalid floor was accepted or mutated state")
		corrupted = before.duplicate(true)
		corrupted.assets["g_foyer"] = "invented-asset"
		verify(not b.restore(corrupted) and b.snapshot() == before, "Invalid art assignment accepted")
		corrupted = before.duplicate(true)
		corrupted["blueprint_id"] = "missing"
		verify(not b.restore(corrupted), "Unknown template accepted")
		# Each stair endpoint must return through the SAME link to the original room/port.
		for link in a.blueprint.links:
			if link.kind != "stairs":
				continue
			for link_id in a.route_to(link.a.room):
				a.traverse(link_id)
			a.traverse(link.id)
			var back: Dictionary = a.traverse(link.id)
			verify(back.to == link.a.room and back.arrival_port == link.a.port, "Stair reverse endpoint changed")
	verify(seen.size() == 4, "Seeds 0-3 did not exercise all templates")
	var test_path := "user://mansion-blueprint-test-%d-%d.json" % [Time.get_ticks_usec(), randi()]
	world.session.new_game(12345)
	world.session.room_memory["g_foyer"] = {"clock_found": true}
	var disk_before: Dictionary = world.session.snapshot()
	verify(world.save_session(test_path), "Session file could not be saved")
	verify(world.save_session(test_path) and not FileAccess.file_exists(test_path + ".tmp"), "Existing save could not be replaced atomically")
	var wrong_port := disk_before.duplicate(true)
	wrong_port["entry_port"] = "down"
	verify(not world.session.restore(wrong_port), "Nonexistent arrival port accepted")
	world.session.new_game(999)
	verify(world.load_session(test_path) and JSON.parse_string(JSON.stringify(world.session.snapshot())) == JSON.parse_string(JSON.stringify(disk_before)), "Saved file did not restore session")
	disk_before = world.session.snapshot()
	var corrupt := FileAccess.open(test_path, FileAccess.WRITE)
	corrupt.store_string("{broken JSON")
	corrupt.close()
	verify(not world.load_session(test_path) and world.session.snapshot() == disk_before, "Corrupted disk save changed session")
	verify(not world.save_session("user://../escape.json"), "Unsafe save path accepted")
	DirAccess.remove_absolute(test_path)
	var review = preload("res://src/mansion/blueprint_review.tscn").instantiate()
	get_root().add_child(review)
	review.change_plan(2)
	review.selected = "u_main_stair"
	review.follow_selected()
	verify(review.floor_view == 1 and world.session.floor_id() == 1, "Review ascent lost floor identity")
	review.selected = "b_service_stair"
	review.follow_selected()
	verify(review.floor_view == -1 and world.session.floor_id() == -1, "Review basement route lost floor identity")
	var browse := InputEventKey.new()
	browse.keycode = KEY_F2
	browse.pressed = true
	review._unhandled_input(browse)
	verify(review.floor_view == 0 and world.session.floor_id() == -1, "Browsing map changed actual logical floor")
	review.selected = "g_foyer"
	review.follow_selected()
	verify(review.floor_view == 0 and world.session.current_room == "g_foyer", "Review return route failed")
	review.queue_free()
	var report := {"ok": failures.is_empty(), "checks": checks, "failures": failures}
	DirAccess.make_dir_recursive_absolute("res://test-results")
	var file := FileAccess.open("res://test-results/mansion-engine-tests.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	print("MANSION_TEST_RESULT ", JSON.stringify(report))
	quit(0 if failures.is_empty() else 1)
