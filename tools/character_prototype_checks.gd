extends "res://tools/fixed_mansion_checks.gd"
const Appearance = preload("res://src/characters/character_render.gd")

func snap(name: String) -> void:
	if capture:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://test-results/character-prototype/"+name+".png")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://test-results/character-prototype")
	room = load("res://src/mansion/playable_mansion.tscn").instantiate()
	root.add_child(room)
	await process_frame
	await physics_frame
	house = room.house
	room.close_view = false
	room.update_camera()
	room.camera.reset_smoothing()
	var layouts: Dictionary = {}
	# Reuse geometry candidates, but exercise many independent deterministic seeds.
	for seed_value in 64:
		var assignments: Array = house.roster.generate(house,seed_value)
		check(assignments.size() == 7,"seven occupants seed %d" % seed_value)
		var occupied_rooms: Dictionary = {}
		var lines: Dictionary = {}
		for assignment in assignments:
			check(not occupied_rooms.has(assignment.room),"spread rooms")
			occupied_rooms[assignment.room] = true
			var at := Vector2(assignment.position[0],assignment.position[1])
			check(house.feet_free(assignment.room,at,false),"NPC on accessible floor")
			check(house.npc_candidates[assignment.room].has(assignment.position),"reachable clear NPC candidate")
			lines[house.roster.statement(assignment)] = true
		check(lines.size() == 7,"distinct room-appropriate statements")
		layouts[JSON.stringify(assignments)] = true
	check(layouts.size() == 64,"fresh seeds vary rooms positions and statements")
	var expected: Array = house.npc_assignments.duplicate(true)
	check(expected == house.roster.generate(house,house.npc_seed),"session seed reproduces roster")
	check(Appearance.height() == 80 and Appearance.height(0.85) < Appearance.height(),"shared adult scale and intentional short adult")
	check(room.guest.texture.resource_path.ends_with("eleanor-revised.png"),"revised Eleanor active")
	await snap("foyer-revised-eleanor")
	# Real physics: all four directions cycle all four available frames; phase
	# advances by actual distance, then stops immediately when movement stops.
	for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.DOWN,Vector2.UP]:
		room.player.position = Vector2(220,251)
		room.player.walk_time = 0
		room.player.automated_direction = direction
		var seen: Dictionary = {}
		var before: float = room.player.distance_walked
		for frame in 28:
			await physics_frame
			seen[room.player.current_frame] = true
		check(seen.size() == 4,"four walking frames direction "+str(direction))
		check(room.player.facing == direction,"directional animation row")
		var distance: float = room.player.distance_walked-before
		check(distance > 45 and distance < 60,"112 pixel/sec responsive movement")
		check(absf(room.player.walk_time-fmod(distance/room.player.stride_distance,1.0)) < 0.01,"distance-synchronized animation")
		await snap("walk-%d-%d" % [int(direction.x),int(direction.y)])
		room.player.automated_direction = Vector2.ZERO
		await physics_frame
		await physics_frame
		check(not room.player.is_walking and room.player.current_frame == 1,"stable idle frame")
	room.player.position = Vector2(240,294)
	# Visit every assigned room, question its actual actor twice and revisit.
	for assignment in expected:
		check(await travel_to(assignment.room),"walk to NPC room "+assignment.room)
		check(room.npc_actors.size() == 1,"one actor without duplicates")
		var actor: Node2D = room.npc_actors[0]
		var at := actor.position
		check(await walk_to(at+Vector2(0,25),assignment.room),"walk to guest")
		await press(KEY_E)
		var statement: String = room.dialogue
		check(room.dialogue_heading.contains(actor.identity.name.to_upper()) and room.player.locked,"guest statement opens and pauses")
		check(statement.replace("\n"," ") == house.roster.statement(assignment),"assigned statement displayed")
		await snap("guest-"+actor.identity.name.to_lower().replace(" ","-"))
		await press(KEY_ESCAPE)
		await press(KEY_E)
		check(room.dialogue == statement,"repeat statement stable")
		await press(KEY_ESCAPE)
		var neighbor: String = house.rooms[assignment.room].portals[0].target
		check(await travel_to(neighbor) and await travel_to(assignment.room),"leave and revisit guest")
		check(room.npc_actors.size() == 1 and room.npc_actors[0].assignment == assignment,"same guest and position on revisit")
	check(house.npc_assignments == expected,"all occupants survive all transitions")
	for target in ["g_library","u_master","g_foyer"]:
		check(await travel_to(target),"scale comparison room "+target)
		await snap("scale-"+target)
	room.prepare_save()
	var snapshot: Dictionary = JSON.parse_string(JSON.stringify(house.snapshot()))
	var other := Fixed.new()
	check(other.restore(snapshot),"roster restored into a fresh session")
	check(other.npc_seed == house.npc_seed and other.npc_assignments == expected,"loaded identities positions and alibis stable")
	var corrupt: Dictionary = snapshot.duplicate(true)
	corrupt.npc_assignments[0].position = [0,0]
	check(not other.restore(corrupt) and JSON.parse_string(JSON.stringify(other.snapshot())) == snapshot,"corrupt occupant rejected atomically")
	var legacy: Dictionary = snapshot.duplicate(true)
	legacy.erase("npc_assignments")
	legacy.erase("npc_seed")
	check(other.restore(legacy) and other.npc_seed == 0 and other.npc_assignments.size() == 7,"legacy fixed save migration")
	var report := {"ok":failures.is_empty(),"checks":checks,"failures":failures,"seed":house.npc_seed,"occupants":expected,"tested_seeds":64}
	FileAccess.open("res://test-results/character-prototype-tests.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("CHARACTER_PROTOTYPE_CHECKS ",checks," ",failures)
	quit(0 if failures.is_empty() else 1)
