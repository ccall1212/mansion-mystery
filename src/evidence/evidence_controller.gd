extends CanvasLayer
## Shared inspection UI used by the foyer and the production review room.
const State = preload("res://src/evidence/evidence_state.gd")
signal modal_changed(open: bool)
var state = State.new()
var artwork = preload("res://src/evidence/evidence_art.gd").new(state.catalog)
var owner_room: Node2D
var root_panel: Panel
var heading: Label
var description: Label
var status: Label
var art: TextureRect
var inset: TextureRect
var inset_label: Label
var selected := ""
var notebook := false
var notebook_ids: Array = []
var notebook_index := 0
var props: Dictionary = {}
var inspect_button: Button
var collect_button: Button
var lens_button: Button
var clock_note := ""
var memory_enabled := true

func _ready() -> void:
	layer = 30
	scale = Vector2.ONE*preload("res://src/presentation.gd").scale_for(get_viewport())
	root_panel = Panel.new()
	root_panel.position = Vector2(16, 30)
	root_panel.size = Vector2(448, 306)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#101d28")
	style.border_color = Color("#ad905b")
	style.set_border_width_all(1)
	root_panel.add_theme_stylebox_override("panel", style)
	add_child(root_panel)
	heading = make_label(Vector2(12, 8), Vector2(424, 25), 14)
	heading.modulate = Color("#e7cd99")
	art = TextureRect.new()
	art.position = Vector2(8, 38)
	art.size = Vector2(160, 160)
	art.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	root_panel.add_child(art)
	description = make_label(Vector2(180, 40), Vector2(252, 176), 12)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inset = TextureRect.new()
	inset.position = Vector2(49, 125)
	inset.size = Vector2(112, 112)
	inset.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	inset.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	inset.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	root_panel.add_child(inset)
	inset_label = make_label(Vector2(8, 236), Vector2(168, 20), 10)
	inset_label.text = "MAGNIFIED DETAIL"
	inset_label.modulate = Color("#e7cd99")
	status = make_label(Vector2(12, 258), Vector2(424, 20), 10)
	inspect_button = button("D  Detail", 12, show_detail)
	lens_button = button("M  Use lens", 112, use_lens)
	collect_button = button("C  Collect", 230, collect_selected)
	button("ESC  Close", 342, close)
	root_panel.hide()
	if memory_enabled:
		restore_memory()

func make_label(at: Vector2, bounds: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.position = at
	label.size = bounds
	label.add_theme_font_size_override("font_size", font_size)
	root_panel.add_child(label)
	return label

func button(title: String, x: int, action: Callable) -> Button:
	var control := Button.new()
	control.text = title
	control.position = Vector2(x, 278)
	control.size = Vector2(92, 22)
	control.add_theme_font_size_override("font_size", 11)
	control.focus_mode = Control.FOCUS_NONE
	control.pressed.connect(action)
	root_panel.add_child(control)
	return control

func place_objects(world: Node2D, room_id: String) -> void:
	for prop in props.values():
		if is_instance_valid(prop):
			prop.get_parent().remove_child(prop)
			prop.queue_free()
	props.clear()
	for id in state.catalog.instances:
		var item: Dictionary = state.item(id)
		if item.room != room_id:
			continue
		var prop := Sprite2D.new()
		artwork.configure_prop(prop, state.visible_asset(id))
		prop.position = Vector2(item.position[0], item.position[1])
		world.add_child(prop)
		props[id] = prop
	refresh_props()

func refresh_props() -> void:
	for id in props:
		props[id].visible = not state.records.get(id, {}).get("collected", false)

func nearby(position: Vector2) -> String:
	var result := ""
	var distance := 25.0
	for id in props:
		if props[id].visible and position.distance_to(props[id].position) < distance:
			distance = position.distance_to(props[id].position)
			result = id
	return result

func open_object(id: String) -> void:
	if state.item(id).is_empty():
		return
	notebook = false
	description.position = Vector2(180,40)
	description.size = Vector2(252,176)
	selected = id
	heading.text = state.definition(id).name
	art.texture = artwork.texture(state.visible_asset(id, true))
	art.modulate.a = 1.0
	root_panel.show()
	modal_changed.emit(true)
	apply_response(state.inspect(id))

func apply_response(response: Dictionary) -> void:
	description.text = response.text
	inset.texture = load(response.inset) if not response.get("inset", "").is_empty() else null
	inset.visible = inset.texture != null
	inset_label.visible = inset.visible
	# Close-up detail replaces the lower portion only after explicit tool use.
	art.modulate.a = 0.3 if inset.visible else 1.0
	status.text = "New observation recorded." if response.get("new_discovery", false) else ""
	inspect_button.visible = not notebook
	collect_button.visible = not notebook and state.definition(selected).collectible
	lens_button.visible = not notebook and state.item(selected).definition != "magnifier"
	lens_button.disabled = not state.has_lens()
	lens_button.tooltip_text = "Collect a magnifying glass first." if not state.has_lens() else "Examine this object with your lens."
	persist_memory()

func show_detail() -> void:
	if not selected.is_empty() and not notebook:
		apply_response(state.inspect(selected, "detailed"))

func use_lens() -> void:
	if not selected.is_empty() and not notebook:
		apply_response(state.inspect(selected, "tool"))

func collect_selected() -> void:
	if not selected.is_empty() and not notebook:
		apply_response(state.collect(selected))
		refresh_props()

func show_notebook() -> void:
	notebook = true
	notebook_ids = []
	for id in state.records:
		if state.records[id].seen:
			notebook_ids.append(id)
	if not clock_note.is_empty():
		notebook_ids.append("@clock")
	if owner_room.has_method("case_journal_entries"):
		for id in owner_room.case_journal_entries():
			notebook_ids.append("@case:"+str(id))
	notebook_index = clampi(notebook_index, 0, maxi(0, notebook_ids.size() - 1))
	root_panel.show()
	modal_changed.emit(true)
	draw_notebook()

func draw_notebook() -> void:
	description.position = Vector2(180,40)
	description.size = Vector2(252,176)
	inspect_button.hide()
	collect_button.hide()
	lens_button.hide()
	inset.hide()
	inset_label.hide()
	art.modulate.a = 1.0
	if notebook_ids.is_empty():
		heading.text = "CLUE BOOK"
		description.text = "No objects examined yet.\n\n" + clock_note
		art.texture = null
		status.text = "ESC Close  |  F5 Save  |  F9 Load"
		return
	selected = notebook_ids[notebook_index]
	if selected.begins_with("@case:"):
		description.position = Vector2(12,40)
		description.size = Vector2(424,210)
		var entry: Dictionary = owner_room.case_journal_entries()[selected.trim_prefix("@case:")]
		heading.text = "CLUE BOOK — "+entry.title
		heading.add_theme_font_size_override("font_size",12)
		art.texture = null
		description.text = entry.text
		status.text = "LEFT/RIGHT Browse  |  ESC Close"
		return
	if selected == "@clock":
		heading.text = "CLUE BOOK — GRANDFATHER CLOCK"
		art.texture = null
		description.text = clock_note
		status.text = "EXAMINED IN PLACE  |  LEFT/RIGHT Browse"
		return
	heading.text = "CLUE BOOK  %d/%d — %s" % [notebook_index + 1, notebook_ids.size(), state.definition(selected).name]
	heading.add_theme_font_size_override("font_size", 12)
	art.texture = artwork.texture(state.visible_asset(selected, true))
	description.text = state.journal_entry(selected)
	status.text = ("IN INVENTORY  |  " if state.records[selected].collected else "EXAMINED IN PLACE  |  ") + "LEFT/RIGHT Browse  |  ENTER Reopen"

func close() -> void:
	root_panel.hide()
	modal_changed.emit(false)

func is_open() -> bool:
	return root_panel != null and root_panel.visible

func persist_memory() -> void:
	if memory_enabled:
		var session = get_node("/root/MansionWorld").session
		if not session.room_memory.has("g_foyer"):
			session.room_memory.g_foyer = {}
		session.room_memory.g_foyer.evidence = state.snapshot()
		session.room_memory.g_foyer.clock_note = clock_note

func restore_memory() -> bool:
	var memory: Dictionary = get_node("/root/MansionWorld").session.room_memory.get("g_foyer", {})
	if memory.has("evidence") and not state.restore(memory.evidence):
		return false
	clock_note = memory.get("clock_note", "")
	refresh_props()
	return true

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_N and (is_open() or owner_room.dialogue.is_empty()):
		close() if is_open() else show_notebook()
	elif event.keycode == KEY_F5:
		if not memory_enabled:
			return
		persist_memory()
		if owner_room.has_method("prepare_save"):
			owner_room.prepare_save()
		var world = get_node("/root/MansionWorld")
		var saved: bool = world.save_session(world.FIXED_SAVE_PATH if owner_room.has_method("prepare_save") else world.SAVE_PATH)
		show_notebook()
		status.text = "Investigation saved." if saved else "Save failed."
	elif event.keycode == KEY_F9:
		if not memory_enabled:
			return
		var world = get_node("/root/MansionWorld")
		var loaded: bool = world.load_session(world.FIXED_SAVE_PATH if owner_room.has_method("restore_room") else world.SAVE_PATH, "" if owner_room.has_method("restore_room") else "g_foyer")
		if loaded:
			state = State.new()
			loaded = restore_memory()
			owner_room.clue_found = not clock_note.is_empty()
			if owner_room.has_method("restore_room"):
				owner_room.restore_room()
		show_notebook()
		status.text = "Investigation loaded." if loaded else "No valid saved investigation."
	elif is_open():
		match event.keycode:
			KEY_ESCAPE: close()
			KEY_D: show_detail()
			KEY_M: use_lens()
			KEY_C: collect_selected()
			KEY_LEFT, KEY_RIGHT:
				if notebook and not notebook_ids.is_empty():
					notebook_index = posmod(notebook_index + (1 if event.keycode == KEY_RIGHT else -1), notebook_ids.size())
					draw_notebook()
			KEY_ENTER:
				if notebook and not notebook_ids.is_empty():
					if not selected.begins_with("@"):
						open_object(selected)
	else:
		return
	get_viewport().set_input_as_handled()
