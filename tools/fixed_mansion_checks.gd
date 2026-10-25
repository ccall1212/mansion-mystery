extends SceneTree
## Actual physics walking through every directed door/stair endpoint.
const Fixed = preload("res://src/mansion/fixed_session.gd")
var house: RefCounted
var room: Node2D
var checks := 0
var failures: Array[String] = []
var grids: Dictionary = {}
var capture := false
var traversed: Dictionary = {}

func _initialize() -> void:
	capture = "--capture" in OS.get_cmdline_user_args()
	Engine.physics_ticks_per_second = 960
	Engine.max_physics_steps_per_frame = 64
	Engine.time_scale = 16
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		push_error(message)

func press(key: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = InputEventKey.new()
	event.keycode = key
	Input.parse_input_event(event)
	await process_frame

func grid(id: String) -> AStarGrid2D:
	if grids.has(id):
		return grids[id]
	var result := AStarGrid2D.new()
	result.region = Rect2i(0,0,120,90)
	result.cell_size = Vector2(4,4)
	result.offset = Vector2(2,2)
	result.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	result.update()
	for y in 90:
		for x in 120:
			result.set_point_solid(Vector2i(x,y),not house.feet_free(id,Vector2(x*4+2,y*4+2)))
	grids[id] = result
	return result

func nearest_cell(nav: AStarGrid2D, at: Vector2) -> Vector2i:
	var closest := Vector2i(-1,-1)
	var distance := INF
	for y in range(maxi(0,int(at.y/4)-10),mini(90,int(at.y/4)+11)):
		for x in range(maxi(0,int(at.x/4)-10),mini(120,int(at.x/4)+11)):
			var cell := Vector2i(x,y)
			if not nav.is_point_solid(cell):
				var d := at.distance_to(Vector2(x*4+2,y*4+2))
				if d < distance:
					distance = d
					closest = cell
	return closest

func walk_to(at: Vector2, expected_room: String) -> bool:
	var nav := grid(expected_room)
	var start := nearest_cell(nav,room.player.position)
	var target := nearest_cell(nav,at)
	if start.x < 0 or target.x < 0:
		return false
	var path := nav.get_point_path(start,target)
	if path.is_empty():
		return false
	for waypoint in path:
		var frames := 0
		while room.player.position.distance_to(waypoint) > 1.5 and house.current_room == expected_room:
			room.player.automated_direction = (waypoint-room.player.position).normalized()
			await physics_frame
			frames += 1
			if frames > 30:
				room.player.automated_direction = Vector2.ZERO
				return false
		if house.current_room != expected_room:
			break
	room.player.automated_direction = Vector2.ZERO
	await process_frame
	return house.current_room != expected_room or room.player.position.distance_to(at) < 15

func snap(name: String) -> void:
	if not capture:
		return
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://test-results/fixed-mansion/"+name+".png")

func travel_to(target: String) -> bool:
	var path: Array = house.route_to(target)
	for portal_id in path:
		var origin: String = house.current_room
		var portal: Dictionary = {}
		for candidate in house.rooms[origin].portals:
			if candidate.id == portal_id:
				portal = candidate
		while room.transition_cooldown > 0:
			await process_frame
		if not await walk_to(Vector2(portal.at[0],portal.at[1]),origin):
			return false
		if house.current_room != portal.target:
			return false
	return house.current_room == target

func explore(id: String, through := "") -> void:
	if capture:
		await snap(id)
	var portals: Array = house.rooms[id].portals.duplicate(true)
	for portal in portals:
		var directed: String = id+">"+portal.target
		if traversed.has(directed):
			continue
		traversed[directed] = true
		# Wait out arrival protection without changing position or bypassing physics.
		while room.transition_cooldown > 0:
			await process_frame
		var moved: bool = await walk_to(Vector2(portal.at[0],portal.at[1]),id)
		if house.current_room == id:
			check(false,"automatic crossing failed "+directed)
		check(moved and house.current_room == portal.target,"walked passage "+directed+" at "+str(room.player.position))
		if house.current_room != portal.target:
			return
		check(house.feet_free(house.current_room,room.player.position),"safe arrival "+directed)
		check(room.player.facing == Vector2(portal.facing[0],portal.facing[1]),"arrival facing "+directed)
		var already := false
		for key in traversed:
			if key.begins_with(portal.target+">"):
				already = true
		if not already:
			await explore(portal.target,portal.id)
		if house.current_room != portal.target:
			return
		var reverse: Dictionary = {}
		for candidate in house.rooms[portal.target].portals:
			if candidate.id == portal.id:
				reverse = candidate
		while room.transition_cooldown > 0:
			await process_frame
		var back: bool = await walk_to(Vector2(reverse.at[0],reverse.at[1]),portal.target)
		if house.current_room == portal.target:
			check(false,"automatic return failed "+directed)
		check(back and house.current_room == id,"walked return "+portal.target+">"+id)
		traversed[portal.target+">"+id] = true
		if house.current_room != id:
			return

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://test-results/fixed-mansion")
	room = load("res://src/mansion/playable_mansion.tscn").instantiate()
	root.add_child(room)
	await process_frame
	await physics_frame
	house = room.house
	room.close_view = false
	room.update_camera()
	room.camera.reset_smoothing()
	check(house.current_room == "g_foyer" and house.rooms.size() == 9,"compact house startup")
	for id in house.rooms:
		for portal in house.rooms[id].portals:
			check(house.feet_free(portal.target,Vector2(portal.arrival[0],portal.arrival[1])),"authored arrival is free "+id+">"+portal.target)
	# Collect the lens via the ordinary controls before leaving the foyer.
	check(await walk_to(Vector2(120,207),"g_foyer"),"walk to lens")
	await press(KEY_E)
	await press(KEY_C)
	check(room.evidence.state.has_lens(),"collected lens in foyer")
	await press(KEY_ESCAPE)
	if "--save-only" not in OS.get_cmdline_user_args():
		await explore("g_foyer")
		check(house.visited.size() == house.rooms.size(),"all compact spaces reached")
		check(traversed.size() == 18,"all compact directed endpoints covered")
	check(room.evidence.state.has_lens(),"inventory survives all room transitions")
	check(await travel_to("g_library"),"return to library through doors")
	check(await walk_to(Vector2(244,271),"g_library"),"walk to library knife")
	await press(KEY_E)
	check(room.evidence.selected == "foyer-knife" and room.evidence.is_open(),"knife now inspected in library")
	check(not room.evidence.inset.visible,"carried magnifier does not auto-reveal library clue")
	await snap("library-inspection")
	await press(KEY_M)
	check(room.evidence.state.record("foyer-knife").discovered and room.evidence.inset.visible,"magnify clue in another room")
	await snap("library-magnified")
	await press(KEY_C)
	check(not room.evidence.props["foyer-knife"].visible,"collected library knife disappears")
	await press(KEY_ESCAPE)
	var world = root.get_node("MansionWorld")
	var save_path := "user://mansion-blueprint-walking-test-%d.json" % Time.get_ticks_usec()
	room.prepare_save()
	var expected: Dictionary = house.snapshot()
	check(world.save_session(save_path),"save from library")
	check(await travel_to("u_master"),"walk upstairs after saving")
	check(world.load_session(save_path),"load fixed-house save from another floor")
	room.evidence.restore_memory()
	room.restore_room()
	# JSON normalizes typed arrays and numeric variants during serialization.
	var normalized: Dictionary = JSON.parse_string(JSON.stringify(expected))
	check(JSON.parse_string(JSON.stringify(house.snapshot())) == normalized and house.current_room == "g_library","load restores room floor position and visited memory")
	check(room.evidence.state.has_lens() and room.evidence.state.record("foyer-knife").discovered,"load restores carried tool and discovery")
	check(not room.evidence.props["foyer-knife"].visible,"loaded collected prop stays absent")
	var invalid: Dictionary = expected.duplicate(true)
	invalid.position = [-50,0]
	check(not house.restore(invalid) and JSON.parse_string(JSON.stringify(house.snapshot())) == normalized,"colliding save position rejected atomically")
	DirAccess.remove_absolute(save_path)
	await press(KEY_N)
	check(room.evidence.notebook,"notebook opens outside foyer")
	await snap("library-notebook")
	await press(KEY_ESCAPE)
	await press(KEY_TAB)
	check(room.map_open and room.player.locked,"directory opens and pauses movement")
	await snap("house-directory")
	await press(KEY_ESCAPE)
	check(not room.map_open and not room.player.locked,"directory closes")
	var report := FileAccess.open("res://test-results/fixed-mansion-tests.json",FileAccess.WRITE)
	report.store_string(JSON.stringify({"ok":failures.is_empty(),"checks":checks,"failures":failures,"visited":house.visited,"directed_passages":traversed.size()},"  "))
	report.close()
	print("FIXED_MANSION_CHECKS ",checks," ",failures)
	quit(0 if failures.is_empty() else 1)
