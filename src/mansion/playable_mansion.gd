extends "res://src/foyer/foyer.gd"
## Fixed walking prototype. Existing foyer remains independently runnable/testable.
const FixedSession = preload("res://src/mansion/fixed_session.gd")
var house: RefCounted
var connected := false
var transition_cooldown := 0.0
var portals_layer: Node2D
var map_open := false
var arrival_message := ""
var arrival_time := 0.0
var npc_actors: Array[Node2D] = []
const PrototypeNPC = preload("res://src/characters/prototype_npc.gd")
const PoseNPC = preload("res://src/characters/pose_npc.gd")
const CharPoseSession = preload("res://src/characters/char_pose_session.gd")
var char_pose_session: RefCounted
var char_test_memory_enabled := true
var char_focus_locked := false
var furniture_annotations: Dictionary = {}
var furniture_debug := false
var chair_foreground: Node2D
var case_controller: CanvasLayer

func _ready() -> void:
	super._ready()
	# Preserve the original scene acceptance harness, not a second gameplay mode.
	if test_mode:
		return
	house = FixedSession.new()
	furniture_debug = "--furniture-debug" in OS.get_cmdline_user_args()
	get_node("/root/MansionWorld").session = house
	for id in house.catalog.object_placements:
		var placement: Array = house.catalog.object_placements[id]
		evidence.state.catalog.instances[id].room = placement[0]
		evidence.state.catalog.instances[id].position = [placement[1],placement[2]]
	portals_layer = Node2D.new()
	portals_layer.draw.connect(draw_portals)
	add_child(portals_layer)
	connected = true
	case_controller = preload("res://src/mystery/case_controller.gd").new()
	case_controller.mansion = self
	add_child(case_controller)
	load_room()

func definition() -> Dictionary:
	return house.rooms[house.current_room]

func _process(delta: float) -> void:
	super._process(delta)
	if not connected:
		return
	transition_cooldown = maxf(0.0,transition_cooldown - delta)
	arrival_time = maxf(0.0,arrival_time - delta)
	if house.current_room != "g_foyer":
		prompt = ""
	if dialogue.is_empty() and not evidence.is_open():
		var nearby_id: String = evidence.nearby(player.position)
		var portal := nearest_portal(42)
		var npc := nearby_npc()
		if not nearby_id.is_empty():
			prompt = "[ E ]  " + evidence.state.definition(nearby_id).name
		elif npc:
			prompt = "[ E ]  Question " + npc.identity.name
		elif not portal.is_empty():
			prompt = "[ E ]  Enter " + house.rooms[portal.target].name
		elif case_controller != null and case_controller.nearby_floor():
			prompt = "[ E ]  Examine disturbed rug"
	portals_layer.queue_redraw()

func nearest_portal(radius: float) -> Dictionary:
	var found: Dictionary = {}
	for portal in definition().portals:
		var distance := player.position.distance_to(Vector2(portal.at[0],portal.at[1]))
		if distance < radius:
			radius = distance
			found = portal
	return found

func use_portal(id: String) -> bool:
	if not dialogue.is_empty() or evidence.is_open() or transition_cooldown > 0:
		return false
	var eligible := nearest_portal(34)
	if eligible.is_empty() or eligible.id != id:
		return false
	prepare_save()
	if house.traverse(id).is_empty():
		return false
	load_room()
	return true

func load_room() -> void:
	dialogue_portrait.hide()
	if is_instance_valid(chair_foreground):
		remove_child(chair_foreground)
		chair_foreground.queue_free()
		chair_foreground = null
	for actor in npc_actors:
		world.remove_child(actor)
		actor.queue_free()
	npc_actors.clear()
	# Remove old physics bodies synchronously, before the next physics step.
	for child in get_children():
		if child is StaticBody2D:
			remove_child(child)
			child.queue_free()
	var room := definition()
	furniture_annotations = house.furniture_for_room(house.current_room)
	scene_id = house.current_room
	var background: Sprite2D = $Background
	background.texture = load(room.asset)
	background.scale = Vector2(480.0/background.texture.get_width(),320.0/background.texture.get_height())
	guest.visible = house.current_room == "g_foyer" and (case_controller == null or not case_controller.state.active)
	world.get_node("ReadingStand").visible = house.current_room == "g_foyer"
	build_boundaries(room)
	for obstacle in room.obstacles:
		add_obstacle(FixedSession.rect(obstacle))
	evidence.place_objects(world,house.current_room)
	var spawned: Dictionary = {}
	for assignment in house.npc_assignments:
		if assignment.room == house.current_room:
			if spawned.has(assignment.id):
				push_error("Duplicate character assignment blocked: "+str(assignment.id))
				continue
			spawned[assignment.id] = true
			var actor: StaticBody2D = PoseNPC.new() if assignment.has("pose_asset") else PrototypeNPC.new()
			actor.identity = house.roster.identity(assignment.id)
			actor.assignment = assignment
			world.add_child(actor)
			npc_actors.append(actor)
			if assignment.has("pose_asset") and not str(assignment.get("contact_key","")).is_empty():
				chair_foreground = Node2D.new()
				chair_foreground.z_index = 1
				add_child(chair_foreground)
				preload("res://src/furniture/chair_foreground.gd").install(chair_foreground,background.texture,assignment.contact_key)
	player.position = house.position
	player.facing = house.facing
	player.velocity = Vector2.ZERO
	player.automated_direction = Vector2.ZERO
	player.locked = false
	room_label = "%s / %s" % [floor_name(house.floor_id()).to_upper(),room.name.to_upper()]
	transition_cooldown = 0.75
	arrival_message = room.name + "  /  " + floor_name(house.floor_id())
	arrival_time = 2.0
	update_camera()
	camera.reset_smoothing()
	player.queue_redraw()
	ui.queue_redraw()

func build_boundaries(room: Dictionary) -> void:
	# Rasterize only the walk-region perimeter at four-pixel precision; merge
	# identical horizontal spans vertically to keep the physics body count small.
	var active: Dictionary = {}
	for y in range(0,360,4):
		var spans: Dictionary = {}
		var begin := -1
		for x in range(0,484,4):
			var open := false
			if x < 480:
				for region in room.walk_regions:
					if FixedSession.rect(region).has_point(Vector2(x+2,y+2)):
						open = true
						break
			if x < 480 and not open and begin < 0:
				begin = x
			if (open or x == 480) and begin >= 0:
				var key := "%d:%d" % [begin,x-begin]
				spans[key] = true
				if active.has(key):
					active[key].size.y += 4
				else:
					active[key] = Rect2(begin,y,x-begin,4)
				begin = -1
		for key in active.keys():
			if not spans.has(key):
				add_obstacle(active[key])
				active.erase(key)
	for bounds in active.values():
		add_obstacle(bounds)

func interact() -> void:
	if not connected:
		super.interact()
		return
	if not dialogue.is_empty() or evidence.is_open():
		super.interact()
		return
	var object_id: String = evidence.nearby(player.position)
	if not object_id.is_empty():
		evidence.open_object(object_id)
		return
	var npc := nearby_npc()
	if npc:
		if case_controller != null and case_controller.state.active:
			case_controller.talk(npc.identity.id)
			return
		dialogue_heading = npc.identity.name.to_upper() + " / PROTOTYPE STATEMENT"
		# Wrap the temporary statements for the existing three-line dialogue panel.
		var lines := PackedStringArray()
		var line := ""
		var statement: String = "Char pose placement test. Furniture contact, skirt clearance and foreground masks still need visual review." if npc.assignment.get("test_only",false) else house.roster.statement(npc.assignment)
		for word in statement.split(" "):
			if line.length()+word.length()+1 > 59:
				lines.append(line)
				line = ""
			line += (" " if not line.is_empty() else "") + word
		lines.append(line)
		dialogue = "\n".join(lines)
		dialogue_portrait.show_actor(npc)
		questioning = false
		guest_answer = false
		player.locked = true
		ui.queue_redraw()
		return
	if case_controller != null and case_controller.nearby_floor():
		case_controller.examine_floor()
		return
	var portal := nearest_portal(34)
	if not portal.is_empty():
		use_portal(portal.id)
	elif house.current_room == "g_foyer":
		super.interact()

func nearby_npc() -> Node2D:
	var found: Node2D
	var distance := 38.0
	for actor in npc_actors:
		var next := player.position.distance_to(actor.position)
		if next < distance:
			distance = next
			found = actor
	return found

func _unhandled_key_input(event: InputEvent) -> void:
	if connected and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11:
			Presentation.toggle_fullscreen()
			get_viewport().set_input_as_handled()
			return
		if event.keycode in [KEY_W,KEY_A,KEY_S,KEY_D,KEY_UP,KEY_DOWN,KEY_LEFT,KEY_RIGHT]:
			char_focus_locked = false
		if event.keycode in [KEY_F7,KEY_F8,KEY_F10]:
			if case_controller != null and case_controller.state.active:
				arrival_message = "Char test is separate / restart exploration to use it"
				arrival_time = 3
				return
			if event.keycode == KEY_F10:
				if char_pose_session != null:
					char_pose_session.stop(house)
					char_pose_session = null
					char_focus_locked = false
					evidence.memory_enabled = char_test_memory_enabled
					load_room()
			else:
				if char_pose_session == null:
					char_pose_session = CharPoseSession.new(house,house.npc_seed ^ 7919)
					char_test_memory_enabled = evidence.memory_enabled
					evidence.memory_enabled = false
				if event.keycode == KEY_F8 or char_pose_session.assignment.is_empty():
					char_pose_session.select(house)
				find_char()
			get_viewport().set_input_as_handled()
			return
		if char_pose_session != null and event.keycode in [KEY_F5,KEY_F9]:
			arrival_message = "Test placement is session-only / F10 exits test"
			arrival_time = 3
			get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_F6:
			furniture_debug = not furniture_debug
			portals_layer.queue_redraw()
			get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_TAB or (map_open and event.keycode == KEY_ESCAPE):
			if not evidence.is_open() and (dialogue.is_empty() or map_open):
				map_open = not map_open
				dialogue = "map" if map_open else ""
				player.locked = map_open
				ui.queue_redraw()
			get_viewport().set_input_as_handled()
			return
		if map_open:
			return
		if event.keycode == KEY_R:
			close_dialogue()
			player.position = safe_reset_position()
			update_camera()
			camera.reset_smoothing()
			return
	super._unhandled_key_input(event)

func find_char() -> void:
	if char_pose_session == null or char_pose_session.assignment.is_empty():
		return
	close_dialogue()
	evidence.close()
	map_open = false
	house.current_room = char_pose_session.assignment.room
	house.arrival_portal = ""
	if not house.visited.has(house.current_room):
		house.visited.append(house.current_room)
	var at: Array = char_pose_session.assignment.position
	var positions: Array = house.roster.candidates(house,house.current_room)
	positions.sort_custom(func(a: Array,b: Array): return Vector2(a[0],a[1]).distance_squared_to(Vector2(at[0],at[1])) < Vector2(b[0],b[1]).distance_squared_to(Vector2(at[0],at[1])))
	for point in positions:
		var p := Vector2(point[0],point[1])
		if house.feet_free(house.current_room,p) and p.distance_to(Vector2(at[0],at[1])) > 44:
			house.position = p
			break
	close_view = true
	char_focus_locked = true
	load_room()

func camera_focus() -> Vector2:
	if char_focus_locked and char_pose_session != null and char_pose_session.assignment.get("room","") == house.current_room:
		var at: Array = char_pose_session.assignment.position
		return Vector2(at[0],at[1]-16)
	return player.position

func char_test_status() -> Dictionary:
	if char_pose_session == null:
		return {"active":false}
	var visible_count := 0
	for actor in npc_actors:
		if actor.identity.id == CharPoseSession.ID:
			visible_count += 1
	return {"active":true,"assignment":char_pose_session.assignment,"global_identity_count":char_pose_session.count(house),"visible_identity_count":visible_count,"generation":char_pose_session.generation}

func safe_reset_position() -> Vector2:
	return Vector2(240,294) if house.current_room == "g_foyer" else house.position

func prepare_save() -> void:
	if case_controller != null and case_controller.state.active:
		case_controller.persist()
	house.position = player.position
	house.facing = player.facing
	evidence.persist_memory()
	if not house.room_memory.has("g_foyer"):
		house.room_memory.g_foyer = {}
	house.room_memory.g_foyer.conversation = {"questioned":guest_questioned,"answers":answers_heard.duplicate()}

func restore_room() -> void:
	map_open = false
	close_dialogue()
	var conversation: Dictionary = house.room_memory.get("g_foyer",{}).get("conversation",{})
	guest_questioned = conversation.get("questioned",false)
	answers_heard.assign(conversation.get("answers",[]))
	if case_controller != null:
		case_controller.restore()
	load_room()
	# Reapply fixed-house locations after EvidenceController recreates its catalog.
	for id in house.catalog.object_placements:
		var p: Array = house.catalog.object_placements[id]
		evidence.state.catalog.instances[id].room = p[0]
		evidence.state.catalog.instances[id].position = [p[1],p[2]]
	evidence.place_objects(world,house.current_room)

func case_journal_entries() -> Dictionary:
	return case_controller.journal_entries() if case_controller != null else {}

func floor_name(floor_id: int) -> String:
	return "Basement" if floor_id < 0 else ("Upper Floor" if floor_id > 0 else "Ground Floor")

func draw_portals() -> void:
	if case_controller != null and case_controller.state.active and house.current_room == case_controller.state.data.floor_clue.room:
		var clue: Dictionary = case_controller.state.data.floor_clue
		var point := Vector2(clue.position[0],clue.position[1])
		if player.position.distance_to(point) < 90:
			portals_layer.draw_arc(point,5,0,TAU,16,Color("#ddbd7a"),1)
			portals_layer.draw_string(font,point+Vector2(-8,14),"RUG",HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("#ddbd7a"))
	if furniture_debug:
		for instance in furniture_annotations.get("instances",[]):
			portals_layer.draw_rect(instance.bounds,Color("#7cc7ca"),false)
			portals_layer.draw_string(font,instance.bounds.position+Vector2(0,8),instance.id,HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("#f2c979"))
			for anchor in instance.anchors:
				if not anchor.get("enabled",true):
					continue
				portals_layer.draw_line(anchor.contact,anchor.approach,Color("#64b9c2"))
				portals_layer.draw_circle(anchor.contact,2,Color("#f7ac61"))
				portals_layer.draw_circle(anchor.approach,2,Color("#64b9c2"))
	for portal in definition().portals:
		var at := Vector2(portal.at[0],portal.at[1])
		var stairs: bool = portal.kind == "stairs"
		var color := Color("#ddbd7a") if stairs else Color("#8ab4b5")
		portals_layer.draw_rect(Rect2(at-Vector2(9,3),Vector2(18,5)),Color("#101c24"))
		portals_layer.draw_line(at-Vector2(9,0),at+Vector2(9,0),color,1)
		if player.position.distance_to(at) < 85:
			var label: String = ("UP" if house.rooms[portal.target].floor > house.floor_id() else "DOWN") if stairs else "EXIT"
			portals_layer.draw_string(font,at-Vector2(11,7),label,HORIZONTAL_ALIGNMENT_LEFT,-1,8,color)

func draw_ui() -> void:
	super.draw_ui()
	if not connected:
		return
	ui.draw_rect(Rect2(0,344,480,16),Color("#0b141d"))
	text(Vector2(12,355), "WASD Move  E Use  N Notes  F4 Case  TAB House  Z View  F11 Fullscreen",8,Color("#a3b6ba"))
	if arrival_time > 0 and dialogue.is_empty() and not evidence.is_open():
		ui.draw_rect(Rect2(120,29,240,22),Color("#101c24"))
		text(Vector2(132,44),arrival_message,11,Color("#e0c58d"))
	if char_pose_session != null and not map_open and dialogue.is_empty() and not evidence.is_open():
		var status := char_test_status()
		ui.draw_rect(Rect2(0,25,480,52),Color("#101d28"))
		text(Vector2(9,40),"CHAR TEST / "+str(char_pose_session.assignment.get("pose_id","")),10,Color("#e0c58d"))
		text(Vector2(9,54),"Global Char records: %d / Visible in this room: %d" % [status.global_identity_count,status.visible_identity_count],9)
		text(Vector2(9,69),"F7 Find Char   F8 Random room + pose   F10 Exit test",9)
	if map_open:
		ui.draw_rect(Rect2(10,28,460,310),Color("#101d28"))
		text(Vector2(24,48),"THE HOUSE / ROOM DIRECTORY",14,Color("#e0c58d"))
		for floor_id in [-1,0,1]:
			var x: int = 24 + (floor_id+1)*148
			text(Vector2(x,73),floor_name(floor_id),12,Color("#e0c58d"))
			var row := 0
			for id in house.rooms:
				var room: Dictionary = house.rooms[id]
				if int(room.floor) != floor_id:
					continue
				var current: bool = id == house.current_room
				var marker := "> " if current else ("* " if house.visited.has(id) else "  ")
				text(Vector2(x,96+row*20),marker+room.name,10,Color("#e8d5aa") if current else Color("#9eb3b9"))
				row += 1
		text(Vector2(24,225),"FROM HERE: " + definition().name,11,Color("#e0c58d"))
		var row := 0
		for portal in definition().portals:
			text(Vector2(26,242+row*14),"- " + house.rooms[portal.target].name + (" / stairs" if portal.kind == "stairs" else ""),10)
			row += 1
		text(Vector2(24,324),"> Current room   * Visited   |   Schematic connections; TAB / ESC close",10)
