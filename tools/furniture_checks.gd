extends SceneTree
const Library = preload("res://src/furniture/furniture_library.gd")
const Fixed = preload("res://src/mansion/fixed_session.gd")
var checks := 0
var failures: Array[String] = []
var capture := false
var editor: Control

func _initialize() -> void:
	capture = "--capture" in OS.get_cmdline_user_args()
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		push_error(message)

func snapshot(name: String) -> void:
	if capture:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://test-results/furniture/"+name+".png")

func mouse(at: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = at
	event.global_position = at
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	event.pressed = pressed
	Input.parse_input_event(event)
	await process_frame
	await process_frame

func click(at: Vector2) -> void:
	await mouse(at,true)
	await mouse(at,false)

func drag(from: Vector2, to: Vector2) -> void:
	await mouse(from,true)
	var motion := InputEventMouseMotion.new()
	motion.position = to
	motion.global_position = to
	motion.relative = to-from
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(motion)
	await process_frame
	await mouse(to,false)

func screen_point(at: Vector2) -> Vector2:
	return editor.stage.global_position+editor.canvas_point(at)

func select_preset(type: String, variant: String) -> void:
	for i in editor.type_picker.item_count:
		if editor.type_picker.get_item_metadata(i) == type:
			editor.type_picker.select(i)
			editor.type_picker.item_selected.emit(i)
	for i in editor.variant_picker.item_count:
		if editor.variant_picker.get_item_metadata(i) == variant:
			editor.variant_picker.select(i)

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://test-results/furniture")
	var production := Library.new()
	var registry_before := FileAccess.get_file_as_bytes(Library.BINDINGS)
	check(production.catalog.variants.size() == 84 and production.catalog.types.size() == 21,"84 orientation IDs / 21 types")
	var beds := 0
	for id in production.catalog.variants:
		var variant: Dictionary = production.catalog.variants[id]
		check(Library.valid_id(id) and variant.id == id,"canonical orientation ID "+id)
		if variant.type == "bed":
			beds += 1
			check(variant.facing == null and variant.axis in ["east_west","north_south"],"bed is axis-based")
			var lying: Dictionary = variant.anchors[0]
			check(Library.pose_ids(lying)[0] == "lying_idle_"+str(variant.axis)+"_head_"+str(variant.headboard),"lying pose preserves headboard alignment")
		else:
			check(variant.facing in production.catalog.directions,"canonical furniture facing")
		for anchor in variant.anchors:
			check(not Library.pose_ids(anchor).is_empty(),"pose requirements supplied")
	check(beds == 4,"four headboard variants")
	for background in production.bindings.backgrounds:
		var layout: Dictionary = production.for_background(background)
		check(not layout.is_empty() and production.validate(layout).is_empty(),"valid traced background "+background)
		for item in layout.instances:
			check(not item.ready_for_staging,"example contacts explicitly unverified")
	var foyer: Dictionary = production.for_background("res://assets/foyer/foyer-background.png")
	var window: Dictionary = production.create_instance("window_south","side_window",Rect2(100,60,100,200))
	check(window.anchors[1].id == "view_from_west" and window.anchors[1].actor_facing == "east","west side actor faces east independently of window south")
	check(window.anchors[2].id == "view_from_east" and window.anchors[2].actor_facing == "west","east side actor faces west")
	check("standing_look_up_east" in Library.pose_ids(window.anchors[1]),"side look-up supplies exact pose requirement")
	var side_layout: Dictionary = production.new_layout("res://assets/rooms/room-library.png","side_test",Vector2(480,320))
	side_layout.instances.append(window)
	var side_resolved: Dictionary = production.resolve(side_layout,Rect2(0,24,480,320))
	check(side_resolved.instances[0].anchors[1].gaze_target == Vector2(150,184),"gaze target scales with furniture and resolves header offset")
	var invalid_side := side_layout.duplicate(true)
	invalid_side.instances[0].anchors[1].gaze_target = [NAN,0]
	check(not production.validate(invalid_side).is_empty(),"nonfinite gaze target rejected")
	var resolved: Dictionary = production.resolve(foyer,Rect2(0,24,480,320))
	check(resolved.instances[1].anchors[0].contact == Vector2(346,190),"background-to-world header offset matches Eleanor window")
	var fit: Dictionary = production.resolve(foyer,Rect2(10,20,1000,500))
	check(fit.background_rect == Rect2(135,20,750,500),"aspect-preserving letterbox transform")
	var library_layout: Dictionary = production.for_background("res://assets/rooms/room-library.png")
	check(library_layout.instances[0].variant_id == "desk_south" and library_layout.instances[0].anchors[0].actor_facing == "south" and library_layout.instances[0].anchors[1].actor_facing == "north","desk orientation independent of seated/standing actor facing")
	var guest_layout: Dictionary = production.for_background("res://assets/rooms/room-guest-bedroom.png")
	check(Library.pose_ids(guest_layout.instances[0].anchors[1]).is_empty(),"blocked bed side does not request a pose")
	var nonce := str(Time.get_ticks_usec())
	var directory := "user://furniture_test_"+nonce
	var test_registry := directory+"/backgrounds.json"
	var sandbox := Library.new(test_registry,directory+"/layouts")
	var draft: Dictionary = sandbox.new_layout("res://assets/rooms/room-grand-hall.png","test_hall",Vector2(960,640))
	draft.instances.append(sandbox.create_instance("chair_west","chair_01",Rect2(100,200,80,100)))
	check(sandbox.validate(draft).is_empty(),"new higher-resolution coordinate space supported")
	check(sandbox.save_layout(draft).is_empty(),"save and register new background")
	var reopened := Library.new(test_registry,directory+"/layouts")
	check(reopened.for_background(draft.background) == JSON.parse_string(JSON.stringify(draft)),"fresh loader recovers IDs and calibrated anchors")
	var malformed: Dictionary = draft.duplicate(true)
	malformed.instances.append(malformed.instances[0].duplicate(true))
	check(not sandbox.save_layout(malformed).is_empty() and reopened.for_background(draft.background) == JSON.parse_string(JSON.stringify(draft)),"duplicate-ID save rejected without modifying saved layout")
	malformed = draft.duplicate(true)
	malformed.instances[0].variant_id = "chair_left"
	check(not sandbox.validate(malformed).is_empty(),"conflicting left/right aliases rejected")
	malformed = draft.duplicate(true)
	malformed.instances[0].position = [NAN,20]
	check(not sandbox.validate(malformed).is_empty(),"nonfinite coordinates rejected")
	malformed = draft.duplicate(true)
	malformed.instances[0] = sandbox.create_instance("bed_east_west_head_west","bed_01",Rect2(150,150,120,70))
	malformed.instances[0].anchors[0].head_toward = "north"
	check(not sandbox.validate(malformed).is_empty(),"incompatible bed headboard rejected")
	malformed = draft.duplicate(true)
	malformed.instances[0] = sandbox.create_instance("bar_stool_north","stool_01",Rect2(200,200,25,40))
	malformed.instances[0].ready_for_staging = true
	check(not sandbox.validate(malformed).is_empty(),"stool needs its counter relationship before staging approval")
	malformed.instances.append(sandbox.create_instance("bar_counter_south","counter_01",Rect2(140,100,130,60)))
	malformed.instances[0].target_instance_id = "counter_01"
	check(sandbox.validate(malformed).is_empty(),"stool target counter accepted")
	malformed = draft.duplicate(true)
	malformed.background = "res://assets/rooms/room-library.png"
	check(not sandbox.save_layout(malformed).is_empty(),"existing layout ID cannot overwrite another background")
	# Exercise actual editor widgets and mouse drags, with saves isolated in user://.
	editor = load("res://src/furniture/furniture_editor.tscn").instantiate()
	editor.library = production
	root.add_child(editor)
	await process_frame
	editor.select_item(0)
	await snapshot("foyer-mapper")
	editor.library = sandbox
	editor.open_background("res://assets/rooms/room-grand-hall-alternate.png")
	select_preset("armchair","armchair_east")
	await click(Vector2(280,94))
	await drag(screen_point(Vector2(100,170)),screen_point(Vector2(155,235)))
	check(editor.layout.instances.size() == 1,"mouse drag creates furniture")
	if editor.layout.instances.size() != 1:
		finish(directory,registry_before)
		return
	check(editor.layout.instances[0].variant_id == "armchair_east","orientation preset applied")
	await click(Vector2(990,534))
	await click(screen_point(Vector2(131,207)))
	var item: Dictionary = editor.layout.instances[0]
	check((Library.vector(item.position)+Library.vector(item.anchors[0].contact)).distance_to(Vector2(131,207)) < 0.8,"click calibrates seat contact")
	await click(Vector2(1050,645))
	check(not editor.layout.instances[0].anchors[0].enabled and Library.pose_ids(editor.layout.instances[0].anchors[0]).is_empty(),"editor disables unusable contact")
	await click(Vector2(1050,645))
	check(editor.layout.instances[0].anchors[0].enabled,"editor re-enables usable contact")
	var previous_contact := Library.vector(item.anchors[0].contact)
	await drag(screen_point(Vector2(125,195)),screen_point(Vector2(145,215)))
	item = editor.layout.instances[0]
	check(Library.vector(item.position).distance_to(Vector2(147.5,255)) < 1 and Library.vector(item.anchors[0].contact) == previous_contact,"move preserves relative seat calibration")
	var old_bounds: Rect2 = editor.selected_bounds()
	await drag(screen_point(old_bounds.end),screen_point(old_bounds.end+Vector2(25,20)))
	check(editor.selected_bounds().size.x > old_bounds.size.x+20,"resize handle changes footprint rectangle")
	await click(Vector2(565,94))
	check(editor.selected_bounds().is_equal_approx(old_bounds),"undo restores previous furniture geometry")
	await click(Vector2(665,94))
	check(not editor.dirty and editor.status.text.begins_with("Saved"),"Save button writes and registers layout")
	var saved: Dictionary = sandbox.for_background(editor.layout.background)
	check(saved.instances.size() == 1 and saved.instances[0].anchors == JSON.parse_string(JSON.stringify(editor.layout.instances[0].anchors)),"calibration survives save/reload")
	await snapshot("new-background-mapper")
	await click(Vector2(770,94))
	var pose_text := ""
	for child in editor.pose_dialog.get_children():
		if child is TextEdit:
			pose_text = child.text
	check(pose_text.contains("armchair_east") and pose_text.contains("seated_idle_east"),"Pose list exposes copyable production requirements")
	editor.pose_dialog.hide()
	await process_frame
	await click(Vector2(1205,392))
	check(editor.layout.instances.is_empty(),"Delete button removes selected instance")
	await click(Vector2(565,94))
	check(editor.layout.instances.size() == 1,"Undo restores deleted furniture")
	# A newly copied, unimported 16:9 PNG can be opened without a Godot import pass.
	var temporary_image := "res://assets/furniture/test_background_"+nonce+".png"
	var image := Image.create(800,450,false,Image.FORMAT_RGB8)
	image.fill(Color("#263b42"))
	image.save_png(temporary_image)
	editor.open_background(temporary_image)
	check(editor.layout.coordinate_size == [480.0,270.0] and editor.layout.instances.is_empty(),"new unimported aspect ratio opens at proportional background coordinates")
	check(sandbox.validate(editor.layout).is_empty(),"new background metadata is valid without registration or import")
	DirAccess.remove_absolute(temporary_image)
	editor.library = production
	editor.open_background("res://assets/rooms/room-library.png")
	editor.select_item(0)
	await snapshot("library-mapper")
	editor.open_background("res://assets/rooms/room-guest-bedroom.png")
	editor.select_item(0)
	await snapshot("bedroom-mapper")
	root.remove_child(editor)
	editor.queue_free()
	await process_frame
	root.content_scale_size = Vector2i(480,360)
	root.size = Vector2i(960,720)
	var room: Node2D = load("res://src/mansion/playable_mansion.tscn").instantiate()
	root.add_child(room)
	await process_frame
	check(room.furniture_annotations.instances.size() == foyer.instances.size(),"game loads all background furniture IDs")
	var room_keys: Dictionary = {}
	check(room.house.rooms.size() == 18,"all 18 prototype rooms audited")
	check(production.bindings.backgrounds.size() == 14,"all 14 unique backgrounds registered")
	for room_id in room.house.rooms:
		var tagged: Dictionary = room.house.furniture_for_room(room_id)
		check(not tagged.is_empty() and not tagged.instances.is_empty(),"furniture coverage for "+room_id)
		for scoped_item in tagged.instances:
			check(not room_keys.has(scoped_item.room_instance_id),"unique room furniture key "+scoped_item.room_instance_id)
			room_keys[scoped_item.room_instance_id] = true
	check(room.furniture_annotations.instances[0].room_instance_id == "g_foyer::foyer_armchair_01","room identity scopes reusable background instance IDs")
	var event := InputEventKey.new()
	event.keycode = KEY_F6
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	check(room.furniture_debug,"F6 toggles in-game ID overlay")
	await snapshot("game-furniture-overlay")
	finish(directory,registry_before)

func finish(directory: String, registry_before: PackedByteArray) -> void:
	check(FileAccess.get_file_as_bytes(Library.BINDINGS) == registry_before,"editor tests preserve project background registry")
	var folder := DirAccess.open(directory+"/layouts")
	if folder:
		for file in folder.get_files():
			DirAccess.remove_absolute(directory+"/layouts/"+file)
		DirAccess.remove_absolute(directory+"/layouts")
	DirAccess.remove_absolute(directory+"/backgrounds.json")
	DirAccess.remove_absolute(directory)
	var report := {"ok":failures.is_empty(),"checks":checks,"failures":failures}
	FileAccess.open("res://test-results/furniture-tests.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("FURNITURE_CHECKS ",checks," ",failures)
	quit(0 if failures.is_empty() else 1)
