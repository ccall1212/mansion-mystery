extends "res://tools/fixed_mansion_checks.gd"
const Appearance = preload("res://src/characters/character_render.gd")

func snap(name: String) -> void:
	if capture:
		# Freeze physics during capture, so renderer latency cannot advance the gait.
		paused = true
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://test-results/detective-walk/"+name+".png")
		paused = false

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://test-results/detective-walk")
	room = load("res://src/mansion/playable_mansion.tscn").instantiate()
	root.add_child(room)
	await process_frame
	await physics_frame
	house = room.house
	var player: CharacterBody2D = room.player
	room.close_view = true
	room.update_camera()
	room.camera.reset_smoothing()
	check(player.horizontal_animation != null,"user horizontal cycle active")
	check(player.speed == 112 and player.stride_distance == 56,"speed/cadence unchanged")
	var animation: RefCounted = player.horizontal_animation
	check(animation.definition.source.ends_with("user-corrected-horizontal.png"),"user art authoritative")
	for i in 8:
		var bounds: Rect2 = animation.appearance.regions[i]
		var pivot: Vector2 = animation.appearance.pivots[i]
		check(bounds.end.y == pivot.y,"sole ground aligned frame "+str(i))
		var origin := Vector2((i%4)*400,(i/4)*600)
		check(bounds.position.x > origin.x and bounds.end.x < origin.x+400,"no horizontal clipping")
		check(bounds.position.y > origin.y and bounds.end.y < origin.y+600,"transparent border intact")
		var height: float = bounds.size.y/float(animation.appearance.reference_height)*64.0*float(animation.definition.standing_height_ratio)
		check(height > 61 and height < 63,"existing sideways stature preserved")
	for direction in [Vector2.LEFT,Vector2.RIGHT]:
		player.position = Vector2(240,275)
		player.walk_time = 0
		player.automated_direction = direction
		var seen: Dictionary = {}
		for i in 36:
			await physics_frame
			if not seen.has(player.current_frame):
				seen[player.current_frame] = true
				check(player.is_walking and player.facing == direction,"walking row selected")
				await snap(("left" if direction.x < 0 else "right")+"-"+str(player.current_frame))
		check(seen.size() == 4,"full horizontal loop")
		player.automated_direction = Vector2.ZERO
		await physics_frame
		await physics_frame
		check(not player.is_walking,"release returns to original planted idle")
	# Repeated reversals retain phase rather than resetting every key change.
	player.position = Vector2(240,275)
	for i in 8:
		player.automated_direction = Vector2.LEFT if i%2 == 0 else Vector2.RIGHT
		for frame in 5:
			await physics_frame
		check(player.is_walking and player.facing == player.automated_direction,"rapid reversal "+str(i))
	player.automated_direction = Vector2.ZERO
	for direction in [Vector2.UP,Vector2.DOWN]:
		player.position = Vector2(240,275)
		player.automated_direction = direction
		for frame in 12:
			await physics_frame
		check(player.facing == direction and player.appearance.reference_height == 254,"original vertical animation retained")
		await snap("preserved-"+("up" if direction.y < 0 else "down"))
		player.automated_direction = Vector2.ZERO
	player.locked = true
	player.automated_direction = Vector2.RIGHT
	var before := player.position
	for frame in 12:
		await physics_frame
	check(not player.is_walking and player.position.distance_to(before) < 0.1,"dialogue lock stops movement and cycle")
	player.locked = false
	player.automated_direction = Vector2.ZERO
	player.position = Vector2(240,294)
	check(await travel_to("g_library"),"walk into doorway with new horizontal animation")
	check(await walk_to(Vector2(244,271),"g_library"),"walk near furniture and evidence")
	await snap("library-context")
	check(await travel_to("g_foyer"),"walk back out through doorway")
	var report := {"ok":failures.is_empty(),"checks":checks,"failures":failures,"source":animation.definition.source}
	FileAccess.open("res://test-results/detective-walk-tests.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("DETECTIVE_WALK_CHECKS ",checks," ",failures)
	quit(0 if failures.is_empty() else 1)
