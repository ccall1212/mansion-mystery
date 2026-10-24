extends RefCounted
## Seeded temporary occupants. Identity, statements and staging rules are separate data.
const ROSTER := "res://assets/characters/prototype/roster.json"
const STATEMENTS := "res://assets/characters/prototype/statements.json"
const SPAWNING := "res://assets/characters/prototype/spawning.json"
var cast: Array
var statements: Dictionary
var rules: Dictionary

func _init() -> void:
	cast = JSON.parse_string(FileAccess.get_file_as_string(ROSTER)).characters
	statements = JSON.parse_string(FileAccess.get_file_as_string(STATEMENTS))
	rules = JSON.parse_string(FileAccess.get_file_as_string(SPAWNING))

func shuffled(values: Array, rng: RandomNumberGenerator) -> Array:
	var result := values.duplicate()
	for i in range(result.size()-1,0,-1):
		var j := rng.randi_range(0,i)
		var temp: Variant = result[i]
		result[i] = result[j]
		result[j] = temp
	return result

func occupied(at: Vector2, assignment: Dictionary) -> bool:
	var feet := Vector2(assignment.position[0],assignment.position[1])
	return Rect2(feet-Vector2(7,8),Vector2(14,8)).intersects(Rect2(at-Vector2(5,5),Vector2(10,6)))

func candidates(house: RefCounted, id: String) -> Array:
	var room: Dictionary = house.rooms[id]
	# Flood fill the existing feet navigation geometry from an arrival point.
	var nav := AStarGrid2D.new()
	nav.region = Rect2i(0,0,60,45)
	nav.cell_size = Vector2(8,8)
	nav.offset = Vector2(4,4)
	nav.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	nav.update()
	for y in 45:
		for x in 60:
			nav.set_point_solid(Vector2i(x,y),not house.feet_free(id,Vector2(x*8+4,y*8+4),false))
	var arrival := Vector2(240,280)
	for other in house.rooms.values():
		for portal in other.portals:
			if portal.target == id:
				arrival = Vector2(portal.arrival[0],portal.arrival[1])
	var start := Vector2i(arrival/8)
	var closest := INF
	for y in 45:
		for x in 60:
			var cell := Vector2i(x,y)
			var distance := arrival.distance_squared_to(Vector2(x*8+4,y*8+4))
			if not nav.is_point_solid(cell) and distance < closest:
				closest = distance
				start = cell
	var result: Array = []
	for y in range(176,313,int(rules.grid)):
		for x in range(48,433,int(rules.grid)):
			var at := Vector2(x,y)
			var valid := true
			for offset in [Vector2.ZERO,Vector2(-rules.clearance,0),Vector2(rules.clearance,0),Vector2(0,-rules.clearance),Vector2(0,rules.clearance)]:
				valid = valid and house.feet_free(id,at+offset,false)
			for portal in room.portals:
				valid = valid and at.distance_to(Vector2(portal.at[0],portal.at[1])) >= float(rules.portal_clearance)
			# All inbound spawn points, not just the room's first entrance.
			for other in house.rooms.values():
				for portal in other.portals:
					if portal.target == id:
						valid = valid and at.distance_to(Vector2(portal.arrival[0],portal.arrival[1])) >= float(rules.arrival_clearance)
			for placement in house.catalog.object_placements.values():
				if placement[0] == id:
					valid = valid and at.distance_to(Vector2(placement[1],placement[2])) >= float(rules.object_clearance)
			valid = valid and at.distance_to(Vector2(240,280)) >= float(rules.start_clearance)
			if valid and not nav.is_point_solid(Vector2i(at/8)) and not nav.get_id_path(start,Vector2i(at/8)).is_empty():
				result.append([x,y])
	return result

func generate(house: RefCounted, seed_value: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var available: Array = []
	for id in statements:
		if house.rooms.has(id) and house.rooms[id].role == "room":
			available.append(id)
	available = shuffled(available,rng)
	var result: Array = []
	for character in cast:
		while not available.is_empty():
			var id: String = available.pop_back()
			if not house.npc_candidates.has(id):
				house.npc_candidates[id] = candidates(house,id)
			var positions: Array = house.npc_candidates[id]
			if positions.is_empty():
				continue
			var statement: int = rng.randi_range(0,statements[id].size()-1)
			result.append({"id":character.id,"room":id,"position":positions[rng.randi_range(0,positions.size()-1)].duplicate(),"statement_index":statement})
			break
	return result

func identity(id: String) -> Dictionary:
	for character in cast:
		if character.id == id:
			return character
	return {}

func statement(assignment: Dictionary) -> String:
	return statements[assignment.room][int(assignment.statement_index)]
