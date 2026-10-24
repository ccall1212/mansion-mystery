extends RefCounted
## Background-local furniture annotations, independent of painted art and NPC poses.
const CATALOG := "res://assets/furniture/catalog.json"
const BINDINGS := "res://assets/furniture/backgrounds.json"
const LAYOUTS := "res://assets/furniture/layouts"
var catalog: Dictionary
var bindings: Dictionary = {"schema_version":1,"backgrounds":{}}
var registry_path: String
var layout_directory: String

func _init(registry := BINDINGS, directory := LAYOUTS) -> void:
	catalog = JSON.parse_string(FileAccess.get_file_as_string(CATALOG))
	registry_path = registry
	layout_directory = directory
	if FileAccess.file_exists(registry_path):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(registry_path))
		if parsed is Dictionary and parsed.get("backgrounds") is Dictionary:
			bindings = parsed

static func valid_id(value: Variant) -> bool:
	return value is String and value.length() <= 96 and RegEx.create_from_string("^[a-z][a-z0-9_]*$").search(value) != null

static func numbers(value: Variant, count: int) -> bool:
	if not value is Array or value.size() != count:
		return false
	for number in value:
		if not (number is int or number is float) or not is_finite(float(number)):
			return false
	return true

static func vector(value: Array) -> Vector2:
	return Vector2(value[0],value[1])

static func rect(value: Array) -> Rect2:
	return Rect2(value[0],value[1],value[2],value[3])

func new_layout(background: String, id: String, size: Vector2) -> Dictionary:
	return {"schema_version":1,"id":id,"background":background,"coordinate_space":"background_local",
		"coordinate_size":[size.x,size.y],"instances":[]}

func create_instance(variant_id: String, id: String, bounds: Rect2) -> Dictionary:
	var template: Dictionary = catalog.variants[variant_id]
	var source := rect(template.bounds)
	var factor := bounds.size/source.size
	var origin := Vector2(bounds.get_center().x,bounds.end.y)
	var instance := {"id":id,"variant_id":variant_id,"position":[origin.x,origin.y],
		"bounds":[-bounds.size.x/2,-bounds.size.y,bounds.size.x,bounds.size.y],
		"footprint":[],"anchors":template.anchors.duplicate(true),"target_instance_id":"",
		"ready_for_staging":false,"render_mode":"baked","notes":"Unverified contact points; calibrate against this background and character pose."}
	var footprint := rect(template.footprint)
	instance.footprint = [footprint.position.x*factor.x,footprint.position.y*factor.y,footprint.size.x*factor.x,footprint.size.y*factor.y]
	for anchor in instance.anchors:
		for field in ["contact","approach","gaze_target"]:
			if not anchor.has(field):
				continue
			var point := vector(anchor[field])*factor
			anchor[field] = [point.x,point.y]
		var clearance := rect(anchor.clearance)
		anchor.clearance = [clearance.position.x*factor.x,clearance.position.y*factor.y,clearance.size.x*factor.x,clearance.size.y*factor.y]
	return instance

func validate(layout: Variant) -> PackedStringArray:
	var errors := PackedStringArray()
	if not layout is Dictionary or layout.get("schema_version") != 1:
		return ["Unsupported furniture layout schema."]
	if not valid_id(layout.get("id")):
		errors.append("Layout ID must use lowercase snake_case.")
	var background: Variant = layout.get("background")
	if not background is String or not background.begins_with("res://assets/") or not FileAccess.file_exists(background) or ".." in background.split("/") or background.get_extension().to_lower() not in ["png","jpg","jpeg","webp"]:
		errors.append("Background must be an existing image under res://assets/.")
	if layout.get("coordinate_space") != "background_local" or not numbers(layout.get("coordinate_size"),2):
		return ["Expected finite background-local coordinate size."]
	var size := vector(layout.coordinate_size)
	if size.x <= 0 or size.y <= 0 or size.x > 10000 or size.y > 10000:
		return ["Invalid coordinate size."]
	if not layout.get("instances") is Array:
		return ["Furniture instances must be an array."]
	var ids: Dictionary = {}
	for item in layout.instances:
		if not item is Dictionary or not valid_id(item.get("id")):
			errors.append("Invalid instance ID.")
			continue
		var id: String = item.id
		if ids.has(id):
			errors.append("Duplicate instance ID: "+id)
		ids[id] = true
		if not catalog.variants.has(item.get("variant_id","")):
			errors.append("Unknown orientation ID: "+str(item.get("variant_id")))
		if not numbers(item.get("position"),2) or not numbers(item.get("bounds"),4) or not numbers(item.get("footprint"),4):
			errors.append(id+": invalid position/bounds/footprint.")
			continue
		for field in ["bounds","footprint"]:
			if item[field][2] <= 0 or item[field][3] <= 0:
				errors.append(id+": empty "+field)
		var visual := rect(item.bounds)
		visual.position += vector(item.position)
		if visual.position.x < -0.01 or visual.position.y < -0.01 or visual.end.x > size.x+0.01 or visual.end.y > size.y+0.01:
			errors.append(id+": furniture rectangle lies outside the background.")
		if not item.get("ready_for_staging") is bool or item.get("render_mode") != "baked":
			errors.append(id+": expected baked annotation with a staging-review flag.")
		if not item.get("target_instance_id","") is String:
			errors.append(id+": target instance ID must be text.")
		if not item.get("anchors") is Array:
			errors.append(id+": missing anchors.")
			continue
		var anchor_ids: Dictionary = {}
		for anchor in item.anchors:
			if not anchor is Dictionary or not valid_id(anchor.get("id")):
				errors.append(id+": invalid anchor ID.")
				continue
			if anchor_ids.has(anchor.id):
				errors.append(id+": duplicate anchor "+anchor.id)
			anchor_ids[anchor.id] = true
			if not anchor.get("enabled",true) is bool:
				errors.append(id+": anchor enabled flag must be boolean.")
			if anchor.has("gaze_target") and not numbers(anchor.gaze_target,2):
				errors.append(id+": gaze target must be a finite local point.")
			if anchor.has("interaction_side") and anchor.interaction_side not in catalog.directions:
				errors.append(id+": interaction side must be a canonical direction.")
			if not numbers(anchor.get("contact"),2) or not numbers(anchor.get("approach"),2) or not numbers(anchor.get("clearance"),4):
				errors.append(id+": invalid contact/approach/clearance.")
				continue
			if anchor.get("posture") not in ["standing","seated","kneeling","lying"] or anchor.get("contact_kind") not in ["feet","seat","knees","pelvis"]:
				errors.append(id+": unsupported posture/contact kind.")
			if anchor.get("posture") == "lying":
				var head: Variant = anchor.get("head_toward")
				var axis: Variant = anchor.get("body_axis")
				if not ((axis == "east_west" and head in ["east","west"]) or (axis == "north_south" and head in ["north","south"])) or anchor.get("actor_facing") != null:
					errors.append(id+": invalid lying axis/head alignment.")
			elif anchor.get("actor_facing") not in catalog.directions:
				errors.append(id+": actor facing must be a canonical direction.")
			if not anchor.get("activities") is Array or anchor.activities.is_empty():
				errors.append(id+": missing activities.")
			else:
				for action in anchor.activities:
					if not valid_id(action):
						errors.append(id+": invalid activity label.")
			if item.get("ready_for_staging",false) and anchor.get("enabled",true):
				for field in ["contact","approach"]:
					if not Rect2(Vector2.ZERO,size).has_point(vector(item.position)+vector(anchor[field])):
						errors.append(id+": staging-ready "+field+" outside background.")
	for item in layout.instances:
		if not item is Dictionary or not item.get("target_instance_id","") is String:
			continue
		var target: String = item.get("target_instance_id","")
		if not target.is_empty() and (not ids.has(target) or target == item.get("id")):
			errors.append(str(item.get("id"))+": invalid target furniture instance.")
		if item.get("ready_for_staging",false) and catalog.variants.has(item.get("variant_id","")):
			var required: Variant = catalog.variants[item.variant_id].required_target_type
			if required != null:
				var matched := false
				for other in layout.instances:
					if other is Dictionary and other.get("id") == target and catalog.variants.has(other.get("variant_id","")):
						matched = catalog.variants[other.variant_id].type == required
				if not matched:
					errors.append(str(item.get("id"))+": link a "+str(required)+" before staging approval.")
	return errors

func for_background(background: String, override_path := "") -> Dictionary:
	var value: Variant = override_path if not override_path.is_empty() else bindings.backgrounds.get(background,"")
	if not value is String:
		return {}
	var path: String = value
	if path.is_empty() or not FileAccess.file_exists(path):
		return {}
	var layout: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not validate(layout).is_empty() or layout.background != background:
		return {}
	return layout

static func write_atomic(path: String, data: Dictionary) -> Error:
	var result := DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	if result != OK:
		return result
	var file := FileAccess.open(path+".tmp",FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data,"  ")+"\n")
	file.close()
	return DirAccess.rename_absolute(path+".tmp",path)

func save_layout(layout: Dictionary) -> PackedStringArray:
	var errors := validate(layout)
	if not errors.is_empty():
		return errors
	var path := layout_directory.path_join(str(layout.id)+".json")
	if FileAccess.file_exists(path):
		var previous: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if not previous is Dictionary or previous.get("background") != layout.background:
			return ["This layout ID already belongs to a different background; choose a new ID."]
	if write_atomic(path,layout) != OK:
		return ["Could not save furniture layout."]
	var updated := bindings.duplicate(true)
	updated.backgrounds[layout.background] = path
	if write_atomic(registry_path,updated) != OK:
		return ["Layout saved, but background registration failed. Save again to register it."]
	bindings = updated
	return []

func resolve(layout: Dictionary, area: Rect2) -> Dictionary:
	if not validate(layout).is_empty():
		return {}
	var size := vector(layout.coordinate_size)
	var factor := minf(area.size.x/size.x,area.size.y/size.y)
	var origin := area.position+(area.size-size*factor)/2
	var result := {"layout_id":layout.id,"background_rect":Rect2(origin,size*factor),"instances":[]}
	for item in layout.instances:
		var point := origin+vector(item.position)*factor
		var resolved: Dictionary = item.duplicate(true)
		resolved.position = point
		for field in ["bounds","footprint"]:
			var box := rect(item[field])
			resolved[field] = Rect2(point+box.position*factor,box.size*factor)
		for anchor in resolved.anchors:
			anchor.contact = point+vector(anchor.contact)*factor
			anchor.approach = point+vector(anchor.approach)*factor
			if anchor.has("gaze_target"):
				anchor.gaze_target = point+vector(anchor.gaze_target)*factor
			var clearance := rect(anchor.clearance)
			anchor.clearance = Rect2(anchor.contact+clearance.position*factor,clearance.size*factor)
			anchor.pose_ids = pose_ids(anchor)
		result.instances.append(resolved)
	return result

static func pose_ids(anchor: Dictionary) -> PackedStringArray:
	var result := PackedStringArray()
	if not anchor.get("enabled",true):
		return result
	for action in anchor.activities:
		var alignment: String = str(anchor.body_axis)+"_head_"+str(anchor.head_toward) if anchor.posture == "lying" else str(anchor.actor_facing)
		result.append(str(anchor.posture)+"_"+str(action)+"_"+alignment)
	return result
