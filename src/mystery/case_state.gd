extends RefCounted
## A fixed, logically authored first case. Guilt is a case role, never an identity trait.
const DATA := "res://assets/mysteries/first-case.json"
var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DATA))
var active := false
var questioned: Array = []
var floor_examined := false
var outcome := "investigating"
var attempts: Array = []

func snapshot() -> Dictionary:
	return {"id":data.id,"active":active,"questioned":questioned.duplicate(),"floor_examined":floor_examined,"outcome":outcome,"attempts":attempts.duplicate(true)}

func restore(saved: Variant) -> bool:
	if not saved is Dictionary or saved.get("id") != data.id or not saved.get("active") is bool or not saved.get("floor_examined") is bool or not saved.get("questioned") is Array or not saved.get("attempts") is Array or saved.get("outcome") not in ["investigating","solved"]:
		return false
	for id in saved.questioned:
		if suspect(id).is_empty():
			return false
	for attempt in saved.attempts:
		if not attempt is Dictionary or suspect(attempt.get("suspect","")).is_empty() or attempt.get("room") not in data.room_options or not weapon_valid(attempt.get("weapon","")) or attempt.get("result") not in ["wrong","solved"]:
			return false
	active = saved.active
	questioned = saved.questioned.duplicate()
	floor_examined = saved.floor_examined
	outcome = saved.outcome
	attempts = saved.attempts.duplicate(true)
	return true

func suspect(id: String) -> Dictionary:
	for person in data.suspects:
		if person.id == id:
			return person
	return {}

func weapon_valid(id: String) -> bool:
	for weapon in data.weapon_options:
		if weapon.id == id:
			return true
	return false

func question(id: String) -> String:
	var person := suspect(id)
	if person.is_empty():
		return ""
	if not questioned.has(id):
		questioned.append(id)
	return person.statement

func requirements(evidence: RefCounted) -> Array[String]:
	var missing: Array[String] = []
	if not evidence.has_lens(): missing.append("Collect the magnifying glass in the foyer.")
	if not evidence.records.get("foyer-knife",{}).get("magnified",false): missing.append("Use the lens on the library knife.")
	if not evidence.records.get("foyer-knife",{}).get("collected",false): missing.append("Collect the knife as evidence.")
	if not floor_examined: missing.append("Examine the disturbed library rug.")
	if questioned.size() < data.suspects.size(): missing.append("Question all three guests.")
	return missing

func accuse(id: String, weapon: String, room: String, at: String, evidence: RefCounted) -> Dictionary:
	if not active or suspect(id).is_empty() or not weapon_valid(weapon) or room not in data.room_options:
		return {"result":"blocked","text":"Choose a valid suspect, weapon and room."}
	if outcome == "solved":
		return {"result":"solved","text":data.ending}
	var missing := requirements(evidence)
	if at != "g_foyer": missing.append("Return to the foyer to present the accusation.")
	if not missing.is_empty():
		return {"result":"blocked","text":"Before presenting your case:\n\n"+"\n".join(missing)}
	var correct: bool = id == data.solution.suspect and weapon == data.solution.weapon and room == data.solution.room
	var result := "solved" if correct else "wrong"
	attempts.append({"suspect":id,"weapon":weapon,"room":room,"result":result})
	if correct:
		outcome = "solved"
		return {"result":result,"text":data.ending}
	return {"result":result,"text":"Your reconstruction does not explain all the evidence. The accusation is withdrawn; the household remains locked inside.\n\nReview the weapon, the rug and the conflicting accounts. For this first prototype, you may investigate and try again without losing your notes."}

static func placements(house: RefCounted) -> Array:
	var case_data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DATA))
	var result: Array = []
	var index: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/characters/poses/char/directional-index.json"))
	for person in case_data.suspects:
		if not house.npc_candidates.has(person.room):
			house.npc_candidates[person.room] = house.roster.candidates(house,person.room)
		var choices: Array = house.npc_candidates[person.room]
		assert(not choices.is_empty(),"Case suspect has no reachable placement")
		var placement := {"id":person.id,"room":person.room,"position":choices[choices.size()/2].duplicate(),"statement_index":0}
		if person.id == "likeness-photo01":
			for asset in index.assets:
				if asset.pose_id == "standing_idle_south":
					placement.pose_asset = asset
		result.append(placement)
	return result
