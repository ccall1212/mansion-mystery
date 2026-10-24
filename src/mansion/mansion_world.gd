extends Node
## Selected once on launch; room art and floor identity never reroll on re-entry.

const Session = preload("res://src/mansion/mansion_session.gd")
const SAVE_PATH := "user://mansion-blueprint-session.json"
const FIXED_SAVE_PATH := "user://mansion-blueprint-fixed-session.json"
var session = Session.new()

func _ready() -> void:
	var requested_seed := -1
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--mansion-seed="):
			var value := argument.trim_prefix("--mansion-seed=")
			if RegEx.create_from_string("^[0-9]{1,10}$").search(value):
				requested_seed = int(value)
	session.new_game(requested_seed)

func valid_save_path(path: String) -> bool:
	return path.begins_with("user://mansion-blueprint-") and path.ends_with(".json") and path.trim_prefix("user://") == path.get_file()

func save_session(path := SAVE_PATH) -> bool:
	if not valid_save_path(path):
		return false
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(session.snapshot(), "  "))
	file.close()
	return DirAccess.rename_absolute(path + ".tmp", path) == OK

func load_session(path := SAVE_PATH, required_room := "") -> bool:
	if not valid_save_path(path) or not FileAccess.file_exists(path):
		return false
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not required_room.is_empty() and (not data is Dictionary or data.get("current_room") != required_room):
		return false
	if data is Dictionary and data.get("room_memory") is Dictionary:
		var memory: Variant = data.room_memory.get("g_foyer", {})
		if memory is Dictionary:
			if memory.has("clock_note") and not memory.clock_note is String:
				return false
			if memory.has("evidence"):
				var evidence = preload("res://src/evidence/evidence_state.gd").new()
				if not evidence.restore(memory.evidence):
					return false
	return session.restore(data)
