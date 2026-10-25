extends "res://src/mansion/playable_mansion.gd"
## Isolated approved library seating test; never writes the real mansion/save.
var fit: Dictionary
var seat_index := -1
var fit_assets: Dictionary = {}

func _ready() -> void:
	super._ready()
	fit = JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/poses/char/library-fit-review.json"))
	for sample in fit.samples:
		assert(sample.approval == "approved", "Library fit needs explicit user approval")
	var index: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(CharPoseSession.INDEX))
	for asset in index.assets:
		fit_assets[asset.pose_id] = asset
	var room: Dictionary = house.rooms.g_library
	room.asset = fit.background
	room.furniture_layout = fit.layout
	room.walk_regions = [[16,137,448,201]]
	room.obstacles = [[0,24,54,202],[120,164,112,48],[64,246,59,30],[124,254,59,29],[48,254,34,22],[322,165,112,34],[277,143,40,22],[0,316,244,28],[311,316,169,28]]
	# Visible doors await reciprocal layout integration; no misleading teleports.
	room.portals = []
	room.spawn = [245,280]
	house.current_room = "g_library"
	house.position = Vector2(245,280)
	house.npc_assignments = []
	evidence.memory_enabled = false
	for item in evidence.state.catalog.instances.values():
		item.room = "@disabled_library_review"
	case_controller.set_process_input(false)
	case_controller.set_process_unhandled_input(false)
	char_pose_session = CharPoseSession.new(house,7919)
	select_seat()

func select_seat() -> void:
	close_dialogue()
	evidence.close()
	seat_index = (seat_index+1)%fit.samples.size()
	var sample: Dictionary = fit.samples[seat_index]
	var asset: Dictionary = fit_assets[sample.pose_id]
	var record: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://"+asset.landmark_record))
	var feet := Vector2(record.source_landmarks.feet[0]+record.export_padding[0],record.source_landmarks.feet[1]+record.export_padding[1])
	var contact := Vector2(sample.contact[0],sample.contact[1])+Vector2(0,24)
	var floor := preload("res://src/characters/character_render.gd").floor_from_contact(contact,Vector2(record.export_contact[0],record.export_contact[1]),feet,1673)
	var assignment := {"id":CharPoseSession.ID,"room":"g_library","pose_id":sample.pose_id,"pose_asset":asset,"position":[floor.x,floor.y],"contact_key":sample.contact_id,"contact_position":[contact.x,contact.y],"statement_index":0,"test_only":true}
	house.npc_assignments = [assignment]
	char_pose_session.assignment = assignment
	char_pose_session.generation += 1
	char_focus_locked = true
	close_view = true
	load_room()
	arrival_time = 0
	assert(char_test_status().global_identity_count == 1)
	assert(char_test_status().visible_identity_count == 1)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F8:
			select_seat()
			get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_F7:
			char_focus_locked = true
			close_view = true
			update_camera()
			return
		if event.keycode == KEY_F10:
			get_tree().change_scene_to_file("res://src/mansion/playable_mansion.tscn")
			return
		if event.keycode in [KEY_F4,KEY_F5,KEY_F9,KEY_TAB]:
			return
	super._unhandled_key_input(event)

func draw_ui() -> void:
	super.draw_ui()
	if fit.is_empty(): return
	ui.draw_rect(Rect2(0,25,480,52),Color("#101d28"))
	text(Vector2(9,40),"LIBRARY LIVE / "+str(fit.samples[seat_index].label),10,Color("#edce98"))
	text(Vector2(9,54),"One Char / approved seat %d of 4 / saves disabled" % [seat_index+1],9)
	text(Vector2(9,69),"F8 Next seat   F7 Focus   Z Overview   F10 Main game",9)
	ui.draw_rect(Rect2(0,344,480,16),Color("#0b141d"))
	text(Vector2(9,355),"WASD Move / E Talk / F6 IDs / Doors await mansion connection work",8)
