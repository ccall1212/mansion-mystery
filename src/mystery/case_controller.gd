extends CanvasLayer
## Briefing, accusation and ending UI; evidence and statements share the clue book.
const CaseState = preload("res://src/mystery/case_state.gd")
var state = CaseState.new()
var mansion: Node2D
var panel: Panel
var title: Label
var body: Label
var actions: VBoxContainer
var suspect_choice := 0
var weapon_choice := 0
var room_choice := 0

func _ready() -> void:
	layer = 40
	scale = Vector2.ONE*preload("res://src/presentation.gd").scale_for(get_viewport())
	panel = Panel.new()
	panel.position = Vector2(20,30)
	panel.size = Vector2(440,308)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#101d28")
	style.border_color = Color("#ad905b")
	style.set_border_width_all(2)
	panel.add_theme_stylebox_override("panel",style)
	add_child(panel)
	title = Label.new()
	title.position = Vector2(16,10)
	title.add_theme_font_size_override("font_size",17)
	title.modulate = Color("#e7cd99")
	panel.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(16,40)
	scroll.size = Vector2(408,150)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	body = Label.new()
	body.custom_minimum_size = Vector2(390,0)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_font_size_override("font_size",12)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scroll.add_child(body)
	actions = VBoxContainer.new()
	actions.position = Vector2(16,196)
	actions.size = Vector2(408,104)
	panel.add_child(actions)
	panel.hide()
	restore()

func clear_actions() -> void:
	for button in actions.get_children():
		actions.remove_child(button)
		button.queue_free()

func button(label: String, callback: Callable) -> void:
	var control := Button.new()
	control.text = label
	control.add_theme_font_size_override("font_size",12)
	control.pressed.connect(callback)
	actions.add_child(control)
	if actions.get_child_count() == 1:
		control.grab_focus()

func show_page(heading: String, content: String) -> void:
	mansion.close_dialogue()
	mansion.map_open = false
	mansion.evidence.close()
	panel.show()
	panel.position = Vector2(20,30)
	panel.size = Vector2(440,308)
	title.add_theme_font_size_override("font_size",17)
	body.add_theme_font_size_override("font_size",12)
	body.get_parent().position = Vector2(16,40)
	body.get_parent().size = Vector2(408,150)
	actions.position = Vector2(16,196)
	actions.size = Vector2(408,104)
	mansion.player.locked = true
	title.text = heading
	body.text = content
	body.get_parent().scroll_vertical = 0
	clear_actions()

func open_board() -> void:
	if mansion.char_pose_session != null:
		show_page("EXIT CHAR TEST FIRST","Press Escape, then F10 to leave the placement test. F4 will open the case board.")
		button("Close",close)
		return
	if not state.active:
		show_page(state.data.title.to_upper(),state.data.briefing)
		button("Begin the first case",start)
		button("Return to exploration",close)
		return
	if state.outcome == "solved":
		show_page("CASE SOLVED",state.data.ending)
		button("Explore the house",close)
		button("Restart this prototype case",start)
		return
	var remaining := state.requirements(mansion.evidence.state)
	show_page(state.data.title.to_upper(),"Investigate the ground floor. N keeps evidence and statements together.\n\n"+("Ready to present your reconstruction in the foyer." if remaining.is_empty() else "Next leads:\n"+"\n".join(remaining)))
	button("Present accusation",accusation_page)
	button("Read case briefing",briefing)
	button("Return to investigation",close)

func briefing() -> void:
	show_page(state.data.title.to_upper(),state.data.briefing)
	button("Back to case board",open_board)

func start() -> void:
	state = CaseState.new()
	state.active = true
	mansion.evidence.state = preload("res://src/evidence/evidence_state.gd").new()
	for id in mansion.house.catalog.object_placements:
		var p: Array = mansion.house.catalog.object_placements[id]
		mansion.evidence.state.catalog.instances[id].room = p[0]
		mansion.evidence.state.catalog.instances[id].position = [p[1],p[2]]
	mansion.evidence.clock_note = ""
	mansion.clue_found = false
	mansion.guest_questioned = false
	mansion.answers_heard.clear()
	mansion.house.room_memory.clear()
	mansion.house.npc_assignments = CaseState.placements(mansion.house)
	mansion.house.current_room = "g_foyer"
	mansion.house.position = Vector2(240,294)
	mansion.house.arrival_portal = ""
	mansion.house.visited = ["g_foyer"]
	persist()
	mansion.evidence.persist_memory()
	close()
	mansion.load_room()
	mansion.arrival_message = "Case begun / F4 Leads / N Notes"
	mansion.arrival_time = 5

func accusation_page() -> void:
	show_page("BUILD YOUR ACCUSATION","Select a suspect, weapon and murder room. Each button cycles the choices. Submit when you are ready.\n\nThe accusation is presented in the foyer and requires the evidence and all three accounts. Wrong answers allow another attempt in this prototype.")
	button("Suspect: "+state.data.suspects[suspect_choice].name,func(): suspect_choice = (suspect_choice+1)%state.data.suspects.size(); accusation_page())
	button("Weapon: "+state.data.weapon_options[weapon_choice].name,func(): weapon_choice = (weapon_choice+1)%state.data.weapon_options.size(); accusation_page())
	button("Room: "+mansion.house.rooms[state.data.room_options[room_choice]].name,func(): room_choice = (room_choice+1)%state.data.room_options.size(); accusation_page())
	# Four compact rows fit the panel; keyboard focus also supports Enter/arrows.
	button("Submit accusation",submit)

func submit() -> void:
	var result: Dictionary = state.accuse(state.data.suspects[suspect_choice].id,state.data.weapon_options[weapon_choice].id,state.data.room_options[room_choice],mansion.house.current_room,mansion.evidence.state)
	persist()
	show_page("CASE SOLVED" if result.result == "solved" else ("MORE INVESTIGATION NEEDED" if result.result == "blocked" else "ACCUSATION WITHDRAWN"),result.text)
	button("Return to case board",open_board)
	button("Return to the house",close)

func talk(id: String) -> void:
	var person: Dictionary = state.suspect(id)
	show_page(person.name.to_upper()+" / ACCOUNT",state.question(id))
	panel.position = Vector2(20,210)
	panel.size = Vector2(440,128)
	title.add_theme_font_size_override("font_size",14)
	body.add_theme_font_size_override("font_size",11)
	body.get_parent().position = Vector2(16,32)
	body.get_parent().size = Vector2(408,58)
	actions.position = Vector2(16,96)
	actions.size = Vector2(408,24)
	for actor in mansion.npc_actors:
		if actor.identity.id == id:
			mansion.dialogue_portrait.show_actor(actor)
			break
	persist()
	button("Recorded in clue book — return",close)

func nearby_floor() -> bool:
	var clue: Dictionary = state.data.floor_clue
	return state.active and mansion.house.current_room == clue.room and mansion.player.position.distance_to(Vector2(clue.position[0],clue.position[1])) < float(clue.radius)

func examine_floor() -> void:
	state.floor_examined = true
	persist()
	show_page(state.data.floor_clue.title.to_upper(),state.data.floor_clue.text)
	button("Observation recorded — return",close)

func journal_entries() -> Dictionary:
	if not state.active: return {}
	var entries := {"briefing":{"title":state.data.title,"text":state.data.briefing}}
	for id in state.questioned:
		var person: Dictionary = state.suspect(id)
		entries[id] = {"title":person.name+" / account","text":person.statement}
	if state.floor_examined:
		entries["floor"] = {"title":state.data.floor_clue.title,"text":state.data.floor_clue.text}
	if state.outcome == "solved": entries["resolution"] = {"title":"Case solved","text":state.data.ending}
	return entries

func persist() -> void:
	if not mansion.house.room_memory.has("g_foyer"): mansion.house.room_memory.g_foyer = {}
	mansion.house.room_memory.g_foyer.case = state.snapshot()

func restore() -> void:
	state = CaseState.new()
	var saved: Variant = mansion.house.room_memory.get("g_foyer",{}).get("case",{})
	if not saved.is_empty(): state.restore(saved)

func close() -> void:
	mansion.dialogue_portrait.hide()
	panel.hide()
	mansion.player.locked = false

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	if event.keycode == KEY_F4:
		close() if panel.visible else open_board()
	elif panel.visible and event.keycode == KEY_ESCAPE:
		close()
	elif panel.visible and event.keycode not in [KEY_TAB,KEY_ENTER,KEY_SPACE,KEY_UP,KEY_DOWN,KEY_LEFT,KEY_RIGHT]:
		get_viewport().set_input_as_handled()
		return
	else: return
	get_viewport().set_input_as_handled()
