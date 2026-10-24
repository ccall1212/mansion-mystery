extends RefCounted
## Seeded logical mansion. Door endpoints are identities/ports, never guessed pixels.

const DATA_PATH := "res://assets/mansion/blueprints.json"
var catalog: Dictionary
var blueprint: Dictionary = {}
var rooms: Dictionary = {}
var seed_id := 0
var current_room := ""
var entry_port := ""
var visited: Array = []
var known_links: Array = []
var history: Array = []
var assets: Dictionary = {}
var room_memory: Dictionary = {}

func _init() -> void:
	catalog = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))

func new_game(requested_seed := -1, forced_template := "") -> bool:
	var rng := RandomNumberGenerator.new()
	if requested_seed < 0:
		rng.randomize()
		requested_seed = rng.randi()
	rng.seed = requested_seed
	var chosen: Dictionary = catalog.blueprints[posmod(requested_seed, catalog.blueprints.size())]
	if not forced_template.is_empty():
		var found := false
		for candidate in catalog.blueprints:
			if candidate.id == forced_template:
				chosen = candidate
				found = true
				break
		if not found:
			return false
	blueprint = chosen
	seed_id = requested_seed
	rooms.clear()
	assets.clear()
	for room in blueprint.rooms:
		rooms[room.id] = room
		var best: Array = []
		var score := 999
		for candidate in room.asset_candidates:
			var value: int = candidate.missing_ports.size() + 100 * int(candidate.stair_direction_gap)
			if value < score:
				best = [candidate]
				score = value
			elif value == score:
				best.append(candidate)
		assets[room.id] = best[rng.randi_range(0, best.size() - 1)].id if not best.is_empty() else ""
	current_room = blueprint.start_room
	entry_port = blueprint.start_entry_port
	visited = [current_room]
	known_links = []
	history = []
	room_memory = {}
	return true

func floor_id() -> int:
	return int(rooms[current_room].floor)

func exits(room_id := "") -> Array:
	var result: Array = []
	var origin := current_room if room_id.is_empty() else room_id
	for link in blueprint.links:
		if link.a.room == origin or link.b.room == origin:
			var source: Dictionary = link.a if link.a.room == origin else link.b
			var target: Dictionary = link.b if link.a.room == origin else link.a
			result.append({"id": link.id, "from": origin, "to": target.room, "departure_port": source.port, "arrival_port": target.port, "kind": link.kind, "shaft": link.get("shaft", "")})
	return result

func traverse(link_id: String) -> Dictionary:
	for exit in exits():
		if exit.id != link_id:
			continue
		current_room = exit.to
		entry_port = exit.arrival_port
		if not visited.has(current_room):
			visited.append(current_room)
		if not known_links.has(link_id):
			known_links.append(link_id)
		history.append(exit.duplicate(true))
		if history.size() > 64:
			history.pop_front()
		return exit
	return {}

func route_to(target: String) -> Array:
	if not rooms.has(target):
		return []
	var frontier := [current_room]
	var paths := {current_room: []}
	while not frontier.is_empty():
		var at: String = frontier.pop_front()
		if at == target:
			return paths[at]
		for exit in exits(at):
			if not paths.has(exit.to):
				var path: Array = paths[at].duplicate()
				path.append(exit.id)
				paths[exit.to] = path
				frontier.append(exit.to)
	return []

func selected_asset(room_id: String) -> Dictionary:
	if not rooms.has(room_id):
		return {}
	for candidate in rooms[room_id].asset_candidates:
		if candidate.id == assets.get(room_id, ""):
			return candidate
	return {}

func snapshot() -> Dictionary:
	return {"schema_version": 2, "blueprint_id": blueprint.id, "seed": seed_id,
		"current_room": current_room, "floor": floor_id(), "entry_port": entry_port,
		"assets": assets.duplicate(true), "visited": visited.duplicate(),
		"known_links": known_links.duplicate(), "history": history.duplicate(true),
		"room_memory": room_memory.duplicate(true)}

func restore(data: Variant) -> bool:
	# Validate into a separate session; a damaged save cannot partly mutate this one.
	if not data is Dictionary or data.get("schema_version") != 2:
		return false
	if not data.get("seed") is float and not data.get("seed") is int:
		return false
	if float(data.seed) < 0 or float(data.seed) != floorf(float(data.seed)):
		return false
	var staged = get_script().new()
	if not staged.new_game(int(data.seed), str(data.get("blueprint_id", ""))):
		return false
	if not data.has("blueprint_id") or not staged.rooms.has(data.get("current_room", "")):
		return false
	if staged.blueprint.id != data.blueprint_id:
		return false
	if not data.get("assets") is Dictionary or data.assets != staged.assets:
		return false
	if data.get("floor") != staged.rooms[data.current_room].floor:
		return false
	if not data.get("visited") is Array or not data.get("known_links") is Array or not data.get("history") is Array or not data.get("room_memory") is Dictionary:
		return false
	if data.history.size() > 64 or not data.visited.has(data.current_room):
		return false
	for id in data.visited:
		if not staged.rooms.has(id):
			return false
	var link_ids: Dictionary = {}
	for link in staged.blueprint.links:
		link_ids[link.id] = link
	for id in data.known_links:
		if not link_ids.has(id):
			return false
	for id in data.room_memory:
		if not staged.rooms.has(id) or not data.room_memory[id] is Dictionary:
			return false
	var prior := ""
	for item in data.history:
		if not item is Dictionary or not link_ids.has(item.get("id", "")):
			return false
		var matched := false
		for exit in staged.exits(str(item.get("from", ""))):
			if exit == item:
				matched = true
				break
		if not matched or (not prior.is_empty() and item.from != prior):
			return false
		prior = item.to
	if not prior.is_empty() and prior != data.current_room:
		return false
	var port := str(data.get("entry_port", ""))
	if port not in ["north", "south", "east", "west", "up", "down"]:
		return false
	if not staged.rooms[data.current_room].ports.has(port):
		return false
	if not data.history.is_empty() and port != data.history.back().arrival_port:
		return false
	blueprint = staged.blueprint
	rooms = staged.rooms
	seed_id = staged.seed_id
	assets = staged.assets
	current_room = data.current_room
	entry_port = port
	visited = data.visited.duplicate()
	known_links = data.known_links.duplicate()
	history = data.history.duplicate(true)
	room_memory = data.room_memory.duplicate(true)
	return true
