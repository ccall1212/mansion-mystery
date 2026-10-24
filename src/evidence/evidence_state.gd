extends RefCounted
## Object identity, physical condition and forensic state are independent data.
const MANIFEST := "res://assets/objects/object-manifest.json"
const FLAGS := ["seen", "detailed", "collected", "magnified", "discovered"]
var catalog: Dictionary
var records: Dictionary = {}

func _init() -> void:
	catalog = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
	assert(validate_catalog(), "Invalid evidence manifest")

func validate_catalog() -> bool:
	if catalog.get("schema_version") != 1:
		return false
	for id in catalog.definitions:
		var definition: Dictionary = catalog.definitions[id]
		if definition.id != id or definition.conditions.is_empty():
			return false
		for forensic in definition.allowed_forensics:
			if not catalog.forensics.has(forensic):
				return false
	for id in catalog.instances:
		if not valid_instance(catalog.instances[id]) or catalog.instances[id].id != id:
			return false
	return true

func valid_instance(item: Dictionary) -> bool:
	if not catalog.definitions.has(item.get("definition", "")):
		return false
	var definition: Dictionary = catalog.definitions[item.definition]
	if not definition.conditions.has(item.get("condition", "")) or not definition.allowed_forensics.has(item.get("forensic", "")):
		return false
	return not definition.forensic_conditions.has(item.forensic) or definition.forensic_conditions[item.forensic].has(item.condition)

func item(id: String) -> Dictionary:
	return catalog.instances.get(id, {})

func definition(id: String) -> Dictionary:
	return catalog.definitions[item(id).definition] if not item(id).is_empty() else {}

func record(id: String) -> Dictionary:
	if not records.has(id):
		records[id] = {"seen": false, "detailed": false, "collected": false, "magnified": false, "discovered": false}
	return records[id]

func has_lens() -> bool:
	for id in records:
		if item(id).definition == "magnifier" and records[id].collected:
			return true
	return false

func inspect(id: String, stage := "initial") -> Dictionary:
	if item(id).is_empty() or stage not in ["initial", "detailed", "tool"]:
		return {"ok": false, "text": "This object cannot be examined."}
	var obj := item(id)
	var physical: Dictionary = definition(id).conditions[obj.condition]
	var state := record(id)
	var response := {"ok": true, "stage": stage, "text": "", "inset": "", "new_discovery": false}
	if stage == "tool":
		if not has_lens():
			return {"ok": false, "text": "Find and collect a magnifying glass first.", "inset": ""}
		var forensic: Dictionary = catalog.forensics[obj.forensic]
		response.text = forensic.repeat if state.magnified else forensic.description
		if obj.forensic != "none":
			response.inset = forensic.inset
			if not state.discovered:
				response.text += "\n\n" + forensic.discovery
				response.new_discovery = true
			state.discovered = true
		state.magnified = true
	elif stage == "detailed":
		response.text = physical.repeat if state.detailed else physical.detailed
		state.detailed = true
	else:
		response.text = physical.repeat if state.seen else physical.initial
	state.seen = true
	return response

func collect(id: String) -> Dictionary:
	if item(id).is_empty() or not definition(id).collectible:
		return {"ok": false, "text": "Leave this object in place; its position is recorded."}
	var state := record(id)
	if state.collected:
		return {"ok": true, "text": "Already in your inventory."}
	state.seen = true
	state.collected = true
	return {"ok": true, "text": definition(id).name + " added to your inventory."}

func visible_asset(id: String, closeup := false) -> String:
	# Forensic configuration NEVER selects ordinary art, including after discovery.
	var condition: Dictionary = definition(id).conditions[item(id).condition]
	return condition.closeup if closeup else condition.asset

func journal_entry(id: String) -> String:
	if not records.has(id) or not records[id].seen:
		return ""
	var state: Dictionary = records[id]
	var obj := item(id)
	var condition: Dictionary = definition(id).conditions[obj.condition]
	var result: String = condition.detailed if state.detailed else condition.initial
	if state.magnified:
		result += "\n\nLens: " + catalog.forensics[obj.forensic].description
	if state.discovered:
		result += "\n\n" + catalog.forensics[obj.forensic].discovery
	return result

func snapshot() -> Dictionary:
	return {"schema_version": 1, "records": records.duplicate(true)}

func restore(data: Variant) -> bool:
	if not data is Dictionary or data.get("schema_version") != 1 or not data.get("records") is Dictionary:
		return false
	var staged: Dictionary = data.records
	var lens := false
	for id in staged:
		if not item(id).is_empty() and staged[id] is Dictionary and staged[id].get("collected") == true and item(id).definition == "magnifier":
			lens = true
	for id in staged:
		if item(id).is_empty() or not staged[id] is Dictionary or staged[id].size() != FLAGS.size():
			return false
		var flags: Dictionary = staged[id]
		for key in FLAGS:
			if not flags.get(key) is bool:
				return false
		if (flags.detailed or flags.collected or flags.magnified or flags.discovered) and not flags.seen:
			return false
		if flags.collected and not definition(id).collectible:
			return false
		if flags.magnified and not lens:
			return false
		if flags.discovered != (flags.magnified and item(id).forensic != "none"):
			return false
	records = staged.duplicate(true)
	return true
