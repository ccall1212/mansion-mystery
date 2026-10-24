extends Node2D
## Interactive blueprint rehearsal; does not pretend to move between room paintings.

const ORIGIN := Vector2(28, 180)
const CELL := Vector2(230, 110)
var world: Node
var session
var floor_view := 0
var selected := "g_foyer"
var font: Font = ThemeDB.fallback_font
var message := "Blueprint review — room connections are logical; collision/door art is pending."
var capture_mode := false
var texture_cache: Dictionary = {}

func _ready() -> void:
	get_window().content_scale_size = Vector2i(1120, 700)
	get_window().size = Vector2i(1120, 700)
	DisplayServer.window_set_title("Sleuth — Mansion Blueprint Review")
	world = get_node("/root/MansionWorld")
	session = world.session
	selected = session.current_room
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	capture_mode = "--blueprint-capture" in OS.get_cmdline_user_args()
	if capture_mode:
		call_deferred("capture_blueprints")
	queue_redraw()

func label(at: Vector2, value: String, size := 14, color := Color("#c9d8de")) -> void:
	draw_string(font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func button(rect: Rect2, value: String, active := false) -> void:
	draw_rect(rect, Color("#31556d") if active else Color("#193344"))
	draw_rect(rect, Color("#63869a"), false, 1)
	label(rect.position + Vector2(10, 22), value, 14)

func room_rect(room: Dictionary) -> Rect2:
	return Rect2(ORIGIN + Vector2(room.grid[0], room.grid[1]) * CELL, CELL)

func _draw() -> void:
	if session == null or session.blueprint.is_empty():
		return
	draw_rect(Rect2(0, 0, 1120, 700), Color("#0b1c29"))
	label(Vector2(20, 31), "SLEUTH / MANSION BLUEPRINTS", 25, Color("#dfc895"))
	label(Vector2(690, 29), "Seed %d / %s" % [session.seed_id, session.blueprint.id], 16)
	for i in 4:
		button(Rect2(20 + i * 274, 54, 262, 34), "%d  %s" % [i + 1, session.catalog.blueprints[i].name], session.blueprint.id == session.catalog.blueprints[i].id)
	for i in 3:
		button(Rect2(20 + i * 153, 104, 144, 34), ["Basement", "Ground floor", "Upper floor"][i], floor_view == i - 1)
	button(Rect2(500, 104, 155, 34), "R  New seed")
	button(Rect2(670, 104, 120, 34), "S  Save")
	button(Rect2(804, 104, 120, 34), "L  Load")
	label(Vector2(28, 164), "NORTH ↑     Solid walls / brass door openings / M main stairs / S service stairs", 13)
	for room in session.blueprint.rooms:
		if int(room.floor) != floor_view:
			continue
		var rect := room_rect(room)
		var fill := Color("#213c4c") if room.role == "passage" else Color("#142d3e")
		if room.get("contains_stairs", false):
			fill = Color("#3c3b31")
		if room.id == selected:
			fill = Color("#294d63")
		draw_rect(rect, fill)
		draw_rect(rect, Color("#8aadb9"), false, 2)
		for port in room.ports:
			var center := rect.get_center()
			if room.get("locked_ports", []).has(port):
				draw_line(Vector2(center.x - 18, rect.position.y), Vector2(center.x + 18, rect.position.y), Color("#db8b79"), 5)
				label(rect.position + Vector2(10, 20), "LOCKED FRONT DOOR", 12, Color("#edb2a2"))
				continue
			if port == "north" or port == "south":
				var y := rect.position.y if port == "north" else rect.end.y
				draw_line(Vector2(center.x - 14, y), Vector2(center.x + 14, y), fill, 5)
				draw_line(Vector2(center.x - 12, y), Vector2(center.x + 12, y), Color("#c7a76c"), 2)
			elif port == "west" or port == "east":
				var x := rect.position.x if port == "west" else rect.end.x
				draw_line(Vector2(x, center.y - 14), Vector2(x, center.y + 14), fill, 5)
				draw_line(Vector2(x, center.y - 12), Vector2(x, center.y + 12), Color("#c7a76c"), 2)
		var words := str(room.name).split(" ")
		var line := ""
		var row := 0
		for word in words:
			if (line + word).length() > 16:
				label(rect.position + Vector2(10, 42 + row * 17), line.strip_edges(), 14)
				row += 1
				line = ""
			line += word + " "
		label(rect.position + Vector2(10, 42 + row * 17), line.strip_edges(), 14)
		if room.get("contains_stairs", false):
			var shaft := "M" if str(room.id).contains("main") else "S"
			var flights := (" ↑" if room.ports.has("up") else "") + (" ↓" if room.ports.has("down") else "")
			label(rect.position + Vector2(10, 20), shaft + flights, 13, Color("#e5c68c"))
		if session.visited.has(room.id):
			draw_circle(rect.position + Vector2(CELL.x - 14, 15), 4, Color("#70b6b6"))
		if room.id == session.current_room:
			label(rect.position + Vector2(10, 94), "YOU ARE HERE", 11, Color("#9cdddd"))
		elif session.visited.has(room.id):
			label(rect.position + Vector2(10, 94), "Visited", 11, Color("#90afb8"))
	draw_inspector()
	label(Vector2(28, 548), "Current: %s / %s   ·   Return via: %s" % [session.rooms[session.current_room].name, ["Basement", "Ground", "Upper"][session.floor_id() + 1], session.entry_port], 14, Color("#a5d0d1"))
	var exits: Array = session.exits()
	for i in exits.size():
		var exit: Dictionary = exits[i]
		var name: String = session.rooms[exit.to].name
		var text := name + (" ↑" if exit.departure_port == "up" else " ↓" if exit.departure_port == "down" else "")
		button(Rect2(28 + (i % 3) * 235, 570 + (i / 3) * 38, 225, 32), text)
	label(Vector2(20, 674), message, 13, Color("#b6c6ca"))
	label(Vector2(20, 694), "1-4  Plan    F1/F2/F3  Floor    Click a room to inspect    ENTER  Rehearse route    R  New seed    S/L  Save/load", 12)

func draw_inspector() -> void:
	var room: Dictionary = session.rooms[selected]
	draw_rect(Rect2(750, 170, 350, 480), Color("#122c3c"))
	label(Vector2(767, 194), room.name, 19, Color("#dfc895"))
	label(Vector2(767, 217), str(room.id) + " / " + ["Basement", "Ground", "Upper"][int(room.floor) + 1], 13)
	var candidate: Dictionary = session.selected_asset(selected)
	if not candidate.is_empty():
		if not texture_cache.has(candidate.asset):
			texture_cache[candidate.asset] = load(str(candidate.asset)) as Texture2D
		var texture: Texture2D = texture_cache[candidate.asset]
		draw_texture_rect(texture, Rect2(765, 232, 320, 213.3333), false)
		label(Vector2(767, 468), "Art: " + str(candidate.id), 12)
		var gaps: Array = candidate.missing_ports.duplicate()
		if candidate.stair_direction_gap:
			gaps.append("matching stair flight")
		label(Vector2(767, 491), "Needs: " + (", ".join(gaps) if not gaps.is_empty() else "collision / scale review"), 12, Color("#e3bd88"))
	else:
		label(Vector2(775, 300), "NEW ROOM ART REQUIRED", 17, Color("#e3bd88"))
		label(Vector2(775, 330), "Blueprint first; art follows review.", 14)
	label(Vector2(767, 520), "Ports: " + ", ".join(room.ports), 13)
	label(Vector2(767, 547), "4 rooms + 2 halls per floor / %d visited" % session.visited.size(), 13)
	button(Rect2(766, 576, 318, 34), "ENTER  Rehearse route here")
	label(Vector2(767, 636), "Graph rehearsal, not room walking.", 12)

func change_plan(index: int) -> void:
	session.new_game(session.seed_id, session.catalog.blueprints[index].id)
	selected = session.current_room
	floor_view = 0
	message = "Plan selected. Asset references stay fixed until a new game."
	queue_redraw()

func follow_selected() -> void:
	for edge in session.route_to(selected):
		session.traverse(edge)
	selected = session.current_room
	floor_view = session.floor_id()
	message = "Route recorded. Floor and paired return port remembered."
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if capture_mode:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_4:
			change_plan(event.keycode - KEY_1)
		elif event.keycode in [KEY_F1, KEY_F2, KEY_F3]:
			floor_view = event.keycode - KEY_F1 - 1
		elif event.keycode == KEY_ENTER:
			follow_selected()
		elif event.keycode == KEY_R:
			session.new_game()
			selected = session.current_room
			floor_view = 0
		elif event.keycode == KEY_S:
			message = "Blueprint session saved." if world.save_session() else "Save failed."
		elif event.keycode == KEY_L:
			message = "Blueprint session loaded." if world.load_session() else "No valid saved blueprint session."
			selected = session.current_room
			floor_view = session.floor_id()
		queue_redraw()
	if not event is InputEventMouseButton or not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
		return
	var at: Vector2 = event.position
	for i in 4:
		if Rect2(20 + i * 274, 54, 262, 34).has_point(at):
			change_plan(i)
			return
	for i in 3:
		if Rect2(20 + i * 153, 104, 144, 34).has_point(at):
			floor_view = i - 1
			queue_redraw()
			return
	for room in session.blueprint.rooms:
		if int(room.floor) == floor_view and room_rect(room).has_point(at):
			selected = room.id
			queue_redraw()
			return
	if Rect2(766, 576, 318, 34).has_point(at):
		follow_selected()
	var exits: Array = session.exits()
	for i in exits.size():
		if Rect2(28 + (i % 3) * 235, 570 + (i / 3) * 38, 225, 32).has_point(at):
			session.traverse(exits[i].id)
			selected = session.current_room
			floor_view = session.floor_id()
			queue_redraw()
	for pair in [[Rect2(500, 104, 155, 34), KEY_R], [Rect2(670, 104, 120, 34), KEY_S], [Rect2(804, 104, 120, 34), KEY_L]]:
		if pair[0].has_point(at):
			var key := InputEventKey.new()
			key.keycode = pair[1]
			key.pressed = true
			_unhandled_input(key)

func capture_blueprints() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/mansion/review")
	for plan_index in 4:
		session.new_game(1000 + plan_index, session.catalog.blueprints[plan_index].id)
		for floor_number in [-1, 0, 1]:
			floor_view = floor_number
			selected = session.current_room
			for room in session.blueprint.rooms:
				if int(room.floor) == floor_number and room.get("contains_stairs", false):
					selected = room.id
					break
			queue_redraw()
			await get_tree().process_frame
			await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var path := "res://assets/mansion/review/%s-floor-%d.png" % [session.blueprint.id, floor_number]
			var image := get_viewport().get_texture().get_image()
			if image.get_size() != Vector2i(1120, 700) or image.save_png(path) != OK:
				push_error("Blueprint capture failed: " + path)
				get_tree().quit(1)
				return
			print("BLUEPRINT_CAPTURED ", path)
	get_tree().quit()
