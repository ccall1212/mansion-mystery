extends RefCounted
## Opt-in live fit test. One authoritative roster record, not per-room random rolls.
const ID := "likeness-photo01"
const INDEX := "res://assets/characters/poses/char/directional-index.json"
const Appearance = preload("res://src/characters/character_render.gd")
var assets: Array = []
var rng := RandomNumberGenerator.new()
var original_assignments: Array = []
var assignment: Dictionary = {}
var generation := 0

func _init(house: RefCounted, seed_value: int) -> void:
	rng.seed = seed_value
	original_assignments = house.npc_assignments.duplicate(true)
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(INDEX))
	for asset in catalog.assets:
		if asset.approval == "approved":
			assets.append(asset)

func select(house: RefCounted, requested_pose := "") -> bool:
	var choices: Array = []
	for asset in assets:
		if requested_pose.is_empty() or asset.pose_id == requested_pose:
			if requested_pose.is_empty() and asset.pose_id == assignment.get("pose_id",""):
				continue
			choices.append(asset)
	choices = house.roster.shuffled(choices,rng)
	for asset in choices:
		var candidates: Array = []
		if asset.posture == "seated":
			var key: PackedStringArray = str(asset.fit_contact).split("::")
			var room_id: String = key[0]
			for item in house.furniture_for_room(room_id).get("instances",[]):
				if item.id != key[1]:
					continue
				for contact in item.anchors:
					if contact.id != key[2] or not contact.get("enabled",true) or not asset.pose_id in contact.pose_ids:
						continue
					var record: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://"+str(asset.landmark_record)))
					var feet: Array = record.source_landmarks.feet
					var padding: Array = record.export_padding
					var seat: Vector2 = contact.contact+preload("res://src/furniture/chair_foreground.gd").seat_offset(asset.fit_contact)
					var floor := Appearance.floor_from_contact(seat,Vector2(record.export_contact[0],record.export_contact[1]),Vector2(feet[0]+padding[0],feet[1]+padding[1]),float(asset.standing_reference_height))
					candidates.append({"room":room_id,"position":[floor.x,floor.y],"contact_key":asset.fit_contact,"contact_position":[seat.x,seat.y]})
		else:
			for room_id in house.rooms:
				if house.rooms[room_id].role != "room":
					continue
				if not house.npc_candidates.has(room_id):
					house.npc_candidates[room_id] = house.roster.candidates(house,room_id)
				for point in house.npc_candidates[room_id]:
					if room_id != assignment.get("room",""):
						candidates.append({"room":room_id,"position":point.duplicate(),"contact_key":"","contact_position":point.duplicate()})
		candidates = house.roster.shuffled(candidates,rng)
		for candidate in candidates:
			var at := Vector2(candidate.position[0],candidate.position[1])
			var occupied := false
			for other in house.npc_assignments:
				if other.id != ID and other.room == candidate.room:
					occupied = occupied or at.distance_to(Vector2(other.position[0],other.position[1])) < 30
			if occupied:
				continue
			var next: Dictionary = candidate.duplicate(true)
			next.merge({"id":ID,"pose_id":asset.pose_id,"pose_asset":asset,"statement_index":0,"test_only":true},true)
			# Build and replace the roster atomically. No old-room record survives.
			var roster: Array = []
			for other in house.npc_assignments:
				if other.id != ID:
					roster.append(other)
			roster.append(next)
			house.npc_assignments = roster
			assignment = next
			generation += 1
			return true
	return false

func stop(house: RefCounted) -> void:
	house.npc_assignments = original_assignments.duplicate(true)

func count(house: RefCounted) -> int:
	var total := 0
	for occupant in house.npc_assignments:
		if occupant.id == ID:
			total += 1
	return total
