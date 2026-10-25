extends SceneTree
const Travel = preload("res://src/mansion/door_travel.gd")

func _initialize() -> void:
	var plan: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/mansion/opposite-door-plan.json"))
	var directed := 0
	for id in plan.rooms:
		for side in plan.rooms[id].doors:
			var target: String = plan.rooms[id].doors[side]
			if target == "locked_front_door": continue
			assert(plan.rooms[target].doors.get(Travel.OPPOSITE[side]) == id,"Wrong-side return: "+id+" "+side)
			var outward: Vector2 = Travel.VECTORS[side]
			var portal := {"side":side,"at":[240,200]}
			assert(Travel.should_enter(Vector2(240,200),outward*112,portal,0))
			assert(not Travel.should_enter(Vector2(240,200),Vector2.ZERO,portal,0))
			assert(not Travel.should_enter(Vector2(240,200),-outward*112,portal,0))
			assert(not Travel.should_enter(Vector2(240,200),outward*112,portal,0.5))
			# Holding the same travel direction after arrival moves into the room,
			# not outward through the receiving door: no automatic bounce-back.
			assert(not Travel.should_enter(Vector2(240,200),outward*112,{"side":Travel.OPPOSITE[side],"at":[240,200]},0))
			directed += 1
	assert(directed == 18)
	assert(plan.rooms.g_foyer.doors.north == "locked_front_door")
	assert(plan.runtime_integrated)
	print("OPPOSITE_DOOR_CHECKS_OK 18 reciprocal directions; automatic trigger/movement/cooldown/no-bounce checks; compact-3 integrated")
	quit()
