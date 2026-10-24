extends RefCounted
## One authored playable house, independent of the randomized blueprint review.
const DATA := "res://assets/mansion/fixed-mansion.json"
var catalog: Dictionary
var blueprint := {"id":"fixed-manor-compact-1"}
var rooms: Dictionary
var seed_id := 0
var current_room := "g_foyer"
var visited: Array = ["g_foyer"]
var room_memory: Dictionary = {}
var position := Vector2(240,294)
var facing := Vector2.DOWN
var arrival_portal := ""
const FurnitureLibrary = preload("res://src/furniture/furniture_library.gd")
var furniture_library := FurnitureLibrary.new()
const Roster = preload("res://src/characters/prototype_roster.gd")
var roster := Roster.new()
var npc_seed := 0
var npc_assignments: Array = []
var npc_candidates: Dictionary = {}

func _init() -> void:
	catalog = JSON.parse_string(FileAccess.get_file_as_string(DATA))
	rooms = catalog.rooms
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	npc_seed = rng.randi()
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--npc-seed=") and argument.trim_prefix("--npc-seed=").is_valid_int():
			npc_seed = clampi(int(argument.trim_prefix("--npc-seed=")),0,4294967295)
	npc_assignments = roster.generate(self,npc_seed)

func floor_id() -> int:
	return int(rooms[current_room].floor)

func furniture_for_room(id: String) -> Dictionary:
	if not rooms.has(id):
		return {}
	var room: Dictionary = rooms[id]
	var layout: Dictionary = furniture_library.for_background(room.asset,room.get("furniture_layout",""))
	if layout.is_empty():
		return {}
	var result: Dictionary = furniture_library.resolve(layout,Rect2(0,24,480,320))
	result.room_id = id
	for instance in result.instances:
		instance.room_instance_id = id+"::"+instance.id
	return result

static func rect(values: Array) -> Rect2:
	return Rect2(values[0], values[1], values[2], values[3])

func feet_free(id: String, feet: Vector2, include_npcs := true) -> bool:
	if not rooms.has(id):
		return false
	var definition: Dictionary = rooms[id]
	for offset in [Vector2(-5,-5), Vector2(5,-5), Vector2(-5,0.5), Vector2(5,0.5)]:
		var inside := false
		for region in definition.walk_regions:
			if rect(region).has_point(feet + offset):
				inside = true
				break
		if not inside:
			return false
	var foot := Rect2(feet - Vector2(5,5), Vector2(10,6))
	for obstacle in definition.obstacles:
		if rect(obstacle).intersects(foot):
			return false
	if include_npcs:
		for assignment in npc_assignments:
			if assignment.room == id and roster.occupied(feet,assignment):
				return false
	return true

func traverse(portal_id: String) -> Dictionary:
	for portal in rooms[current_room].portals:
		if portal.id == portal_id:
			current_room = portal.target
			position = Vector2(portal.arrival[0],portal.arrival[1])
			facing = Vector2(portal.facing[0],portal.facing[1])
			arrival_portal = portal_id
			if not visited.has(current_room):
				visited.append(current_room)
			return portal
	return {}

func route_to(target: String) -> Array:
	var frontier := [current_room]
	var routes := {current_room:[]}
	while not frontier.is_empty():
		var at: String = frontier.pop_front()
		if at == target:
			return routes[at]
		for portal in rooms[at].portals:
			if not routes.has(portal.target):
				var path: Array = routes[at].duplicate()
				path.append(portal.id)
				routes[portal.target] = path
				frontier.append(portal.target)
	return []

func snapshot() -> Dictionary:
	return {"schema_version":3,"blueprint_id":blueprint.id,"current_room":current_room,
		"floor":floor_id(),"position":[position.x,position.y],"facing":[facing.x,facing.y],
		"arrival_portal":arrival_portal,"visited":visited.duplicate(),"room_memory":room_memory.duplicate(true),
		"npc_seed":npc_seed,"npc_assignments":npc_assignments.duplicate(true)}

func restore(data: Variant) -> bool:
	if not data is Dictionary or data.get("schema_version") != 3 or data.get("blueprint_id") != blueprint.id:
		return false
	if not rooms.has(data.get("current_room","")) or data.get("floor") != rooms[data.current_room].floor:
		return false
	for field in ["position","facing"]:
		if not data.get(field) is Array or data[field].size() != 2:
			return false
		for number in data[field]:
			if not (number is float or number is int) or not is_finite(float(number)):
				return false
	var at := Vector2(data.position[0],data.position[1])
	var direction := Vector2(data.facing[0],data.facing[1])
	if not feet_free(data.current_room,at,false) or direction.length() < 0.9 or direction.length() > 1.1:
		return false
	if not data.get("visited") is Array or not data.visited.has(data.current_room) or not data.get("room_memory") is Dictionary:
		return false
	for id in data.visited:
		if not rooms.has(id):
			return false
	for id in data.room_memory:
		if not rooms.has(id) or not data.room_memory[id] is Dictionary:
			return false
	var conversation: Variant = data.room_memory.get("g_foyer",{}).get("conversation",{})
	if not conversation is Dictionary:
		return false
	if not conversation.is_empty():
		if not conversation.get("questioned") is bool or not conversation.get("answers") is Array:
			return false
		for answer in conversation.answers:
			if answer not in [0,1,2]:
				return false
	var entry: Variant = data.get("arrival_portal", "")
	if not entry is String:
		return false
	if not entry.is_empty():
		var found := false
		for portal in rooms[data.current_room].portals:
			found = found or portal.id == entry
		if not found:
			return false
	# Legacy schema-3 saves get a deterministic roster, without changing their room state.
	var saved_seed: Variant = data.get("npc_seed",0)
	if not (saved_seed is int or saved_seed is float) or not is_finite(float(saved_seed)) or float(saved_seed) != floorf(float(saved_seed)) or saved_seed < 0 or saved_seed > 4294967295:
		return false
	var occupants: Array = roster.generate(self,int(saved_seed))
	var saved_case: Variant = data.room_memory.get("g_foyer",{}).get("case",{})
	if not saved_case is Dictionary:
		return false
	if not saved_case.is_empty():
		var case_state = preload("res://src/mystery/case_state.gd").new()
		if not case_state.restore(saved_case):
			return false
		if case_state.active:
			occupants = case_state.placements(self)
	if data.has("npc_assignments") and JSON.parse_string(JSON.stringify(data.npc_assignments)) != JSON.parse_string(JSON.stringify(occupants)):
		return false
	for assignment in occupants:
		if assignment.room == data.current_room and roster.occupied(at,assignment):
			return false
	npc_seed = int(saved_seed)
	npc_assignments = occupants
	current_room = data.current_room
	position = at
	facing = direction
	arrival_portal = entry
	visited = data.visited.duplicate()
	room_memory = data.room_memory.duplicate(true)
	return true
