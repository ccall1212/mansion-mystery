extends Control
## Background annotation tool. No character art generation or gameplay staging.
const Library = preload("res://src/furniture/furniture_library.gd")
var library: RefCounted
var layout: Dictionary = {}
var texture: Texture2D
var selected := -1
var anchor_index := 0
var mode := "select"
var dirty := false:
	set(value):
		dirty = value
		if is_inside_tree():
			get_window().title = "Sleuth / Furniture Background Mapper"+(" *" if value else "")
var updating := false
var history: Array[Dictionary] = []
var dragging := ""
var drag_start := Vector2.ZERO
var drag_current := Vector2.ZERO
var drag_item: Dictionary = {}
var stage: Control
var type_picker: OptionButton
var variant_picker: OptionButton
var items: ItemList
var id_edit: LineEdit
var layout_edit: LineEdit
var anchor_picker: OptionButton
var facing_picker: OptionButton
var ready_box: CheckBox
var anchor_enabled: CheckBox
var target_edit: LineEdit
var anchor_info: Label
var status: Label
var background_label: Label
var dialog: FileDialog
var discard: ConfirmationDialog
var close_confirmation: ConfirmationDialog
var pose_dialog: AcceptDialog
var font: Font

func _ready() -> void:
	get_window().content_scale_size = Vector2i(1280,800)
	get_window().size = Vector2i(1280,800)
	get_window().title = "Sleuth / Furniture Background Mapper"
	get_tree().auto_accept_quit = false
	if library == null:
		library = Library.new()
	font = ThemeDB.fallback_font
	build_ui()
	var initial := "res://assets/foyer/foyer-background.png"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--background="):
			initial = argument.trim_prefix("--background=")
	open_background(initial)

func label(value: String, at: Vector2, size_value := Vector2(340,25)) -> Label:
	var node := Label.new()
	node.text = value
	node.position = at
	node.size = size_value
	add_child(node)
	return node

func button(value: String, at: Vector2, width: float, action: Callable) -> Button:
	var node := Button.new()
	node.text = value
	node.position = at
	node.size = Vector2(width,32)
	node.pressed.connect(action)
	add_child(node)
	return node

func build_ui() -> void:
	label("FURNITURE / BACKGROUND MAPPER",Vector2(20,12),Vector2(800,30)).add_theme_font_size_override("font_size",24)
	background_label = label("",Vector2(20,45),Vector2(870,23))
	label("Layout ID",Vector2(905,43),Vector2(80,24))
	layout_edit = LineEdit.new()
	layout_edit.position = Vector2(985,42)
	layout_edit.size = Vector2(275,28)
	layout_edit.text_changed.connect(func(value: String):
		if not updating and not layout.is_empty():
			layout.id = value
			dirty = true)
	add_child(layout_edit)
	button("Open background",Vector2(20,78),175,request_open)
	button("Draw furniture",Vector2(205,78),155,func(): set_mode("draw"))
	button("Select / move",Vector2(370,78),145,func(): set_mode("select"))
	button("Undo",Vector2(525,78),85,undo)
	button("Save",Vector2(620,78),90,save)
	button("Pose list",Vector2(720,78),100,show_pose_list)
	stage = Control.new()
	stage.position = Vector2(20,125)
	stage.size = Vector2(850,566)
	stage.mouse_filter = Control.MOUSE_FILTER_STOP
	stage.gui_input.connect(canvas_input)
	stage.draw.connect(draw_canvas)
	add_child(stage)
	label("Orientation preset (new / replacement)",Vector2(905,78))
	type_picker = OptionButton.new()
	type_picker.position = Vector2(905,106)
	type_picker.size = Vector2(166,30)
	for type in library.catalog.types:
		type_picker.add_item(library.catalog.types[type])
		type_picker.set_item_metadata(type_picker.item_count-1,type)
	type_picker.item_selected.connect(func(_index: int): populate_variants())
	add_child(type_picker)
	variant_picker = OptionButton.new()
	variant_picker.position = Vector2(1080,106)
	variant_picker.size = Vector2(180,30)
	variant_picker.item_selected.connect(func(index: int): variant_picker.tooltip_text = str(variant_picker.get_item_metadata(index)))
	add_child(variant_picker)
	populate_variants()
	label("Placed furniture",Vector2(905,142))
	items = ItemList.new()
	items.position = Vector2(905,168)
	items.size = Vector2(355,135)
	items.item_selected.connect(func(index: int): select_item(index))
	add_child(items)
	label("Instance ID (unique in this background)",Vector2(905,310))
	id_edit = LineEdit.new()
	id_edit.position = Vector2(905,337)
	id_edit.size = Vector2(355,30)
	id_edit.focus_entered.connect(remember)
	id_edit.text_changed.connect(func(value: String):
		if not updating and selected >= 0:
			layout.instances[selected].id = value
			dirty = true
			stage.queue_redraw())
	add_child(id_edit)
	button("Apply preset / reset anchors",Vector2(905,376),239,apply_variant).tooltip_text = "Keeps the furniture rectangle, replaces its orientation and resets contact points. Undo restores the previous calibration."
	button("Delete",Vector2(1150,376),110,delete_selected)
	label("Interaction point",Vector2(905,414))
	anchor_picker = OptionButton.new()
	anchor_picker.position = Vector2(905,442)
	anchor_picker.size = Vector2(355,30)
	anchor_picker.item_selected.connect(func(index: int): anchor_index = index; refresh_anchor())
	add_child(anchor_picker)
	label("Actor faces",Vector2(905,480),Vector2(115,25))
	facing_picker = OptionButton.new()
	facing_picker.position = Vector2(1030,479)
	facing_picker.size = Vector2(230,30)
	for direction in library.catalog.directions:
		facing_picker.add_item(direction)
	facing_picker.add_item("Lying: use axis / headboard")
	facing_picker.item_selected.connect(change_facing)
	add_child(facing_picker)
	button("Mark contact",Vector2(905,518),170,func(): set_mode("contact"))
	button("Mark approach",Vector2(1085,518),175,func(): set_mode("approach"))
	anchor_info = label("",Vector2(905,559),Vector2(355,66))
	anchor_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	anchor_info.add_theme_font_size_override("font_size",13)
	anchor_enabled = CheckBox.new()
	anchor_enabled.position = Vector2(905,630)
	anchor_enabled.text = "Use this interaction point"
	anchor_enabled.toggled.connect(func(value: bool):
		if not updating and selected >= 0:
			remember()
			layout.instances[selected].anchors[anchor_index].enabled = value
			layout.instances[selected].ready_for_staging = false
			dirty = true
			refresh_anchor())
	add_child(anchor_enabled)
	label("Target ID",Vector2(905,662),Vector2(80,25))
	target_edit = LineEdit.new()
	target_edit.position = Vector2(990,659)
	target_edit.size = Vector2(270,30)
	target_edit.placeholder_text = "counter ID for a bar stool"
	target_edit.focus_entered.connect(remember)
	target_edit.text_changed.connect(func(value: String):
		if not updating and selected >= 0:
			layout.instances[selected].target_instance_id = value
			dirty = true)
	add_child(target_edit)
	ready_box = CheckBox.new()
	ready_box.position = Vector2(905,697)
	ready_box.text = "Contact points reviewed for staging"
	ready_box.toggled.connect(func(value: bool):
		if not updating and selected >= 0:
			remember()
			layout.instances[selected].ready_for_staging = value
			dirty = true)
	add_child(ready_box)
	label("Drag a rectangle in Draw mode. Select: drag to move; drag lower-right square to resize.",Vector2(20,707),Vector2(860,25))
	label("Orange = contact; cyan = approach; arrow = actor facing; shaded strip = footprint.",Vector2(20,734),Vector2(860,24))
	status = label("",Vector2(20,768),Vector2(1230,25))
	dialog = FileDialog.new()
	dialog.access = FileDialog.ACCESS_RESOURCES
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.current_dir = "res://assets"
	dialog.filters = PackedStringArray(["*.png,*.jpg,*.jpeg,*.webp ; Background images"])
	dialog.file_selected.connect(open_background)
	add_child(dialog)
	discard = ConfirmationDialog.new()
	discard.dialog_text = "Discard unsaved furniture changes and open another background?"
	discard.confirmed.connect(func(): dialog.popup_centered(Vector2i(850,580)))
	add_child(discard)
	close_confirmation = ConfirmationDialog.new()
	close_confirmation.dialog_text = "Save furniture changes before closing?"
	close_confirmation.ok_button_text = "Save and close"
	close_confirmation.cancel_button_text = "Keep editing"
	close_confirmation.add_button("Discard changes",false,"discard")
	close_confirmation.confirmed.connect(func():
		save()
		if not dirty:
			get_tree().quit())
	close_confirmation.custom_action.connect(func(action: StringName):
		if action == "discard":
			get_tree().quit())
	add_child(close_confirmation)
	pose_dialog = AcceptDialog.new()
	pose_dialog.title = "Required pose IDs / furniture contacts"
	add_child(pose_dialog)

func populate_variants() -> void:
	variant_picker.clear()
	var type: String = type_picker.get_item_metadata(type_picker.selected)
	for id in library.catalog.variants:
		var variant: Dictionary = library.catalog.variants[id]
		if variant.type == type:
			var caption: String = ("Horizontal, head " if variant.axis == "east_west" else "Vertical, head ")+str(variant.headboard) if type == "bed" else id.trim_prefix(type+"_")
			variant_picker.add_item(caption)
			variant_picker.set_item_metadata(variant_picker.item_count-1,id)
	if variant_picker.item_count > 0:
		variant_picker.tooltip_text = str(variant_picker.get_item_metadata(variant_picker.selected))

func request_open() -> void:
	if dirty:
		discard.popup_centered()
	else:
		dialog.popup_centered(Vector2i(850,580))

func open_background(path: String) -> void:
	if not path.begins_with("res://assets/"):
		status.text = "Copy the background into the project's assets folder first."
		return
	var image := Image.new()
	var bytes := FileAccess.get_file_as_bytes(path)
	var error := ERR_FILE_UNRECOGNIZED
	match path.get_extension().to_lower():
		"png": error = image.load_png_from_buffer(bytes)
		"jpg", "jpeg": error = image.load_jpg_from_buffer(bytes)
		"webp": error = image.load_webp_from_buffer(bytes)
	if error != OK:
		status.text = "Unable to decode this background image."
		return
	texture = ImageTexture.create_from_image(image)
	layout = library.for_background(path)
	if layout.is_empty():
		var id := path.get_file().get_basename().replace("-","_").to_lower()
		id = RegEx.create_from_string("[^a-z0-9_]").sub(id,"_",true)
		if not Library.valid_id(id):
			id = "background_"+id
		layout = library.new_layout(path,id,Vector2(480,480.0*image.get_height()/image.get_width()))
	selected = -1
	anchor_index = 0
	dirty = false
	history.clear()
	mode = "select"
	background_label.text = path
	refresh()
	status.text = "Background loaded. Choose a furniture type and orientation, then Draw furniture."

func remember() -> void:
	if not updating and not layout.is_empty():
		history.append(layout.duplicate(true))
		if history.size() > 40:
			history.pop_front()

func undo() -> void:
	if history.is_empty():
		return
	layout = history.pop_back()
	selected = mini(selected,layout.instances.size()-1)
	dirty = true
	refresh()
	status.text = "Previous furniture edit restored. Save to keep it."

func refresh() -> void:
	updating = true
	id_edit.editable = selected >= 0
	target_edit.editable = selected >= 0
	ready_box.disabled = selected < 0
	anchor_picker.disabled = selected < 0
	layout_edit.text = layout.get("id","")
	items.clear()
	for item in layout.instances:
		items.add_item(item.id+" / "+item.variant_id)
		items.set_item_tooltip(items.item_count-1,item.id+"\nOrientation: "+item.variant_id)
	if selected >= 0 and selected < layout.instances.size():
		items.select(selected)
		var item: Dictionary = layout.instances[selected]
		id_edit.text = item.id
		target_edit.text = item.target_instance_id
		ready_box.button_pressed = item.ready_for_staging
		var type: String = library.catalog.variants[item.variant_id].type
		for i in type_picker.item_count:
			if type_picker.get_item_metadata(i) == type:
				type_picker.select(i)
		populate_variants()
		for i in variant_picker.item_count:
			if variant_picker.get_item_metadata(i) == item.variant_id:
				variant_picker.select(i)
		anchor_picker.clear()
		for anchor in item.anchors:
			anchor_picker.add_item(anchor.id+" / "+anchor.contact_kind)
		anchor_index = clampi(anchor_index,0,item.anchors.size()-1)
		anchor_picker.select(anchor_index)
	else:
		selected = -1
		id_edit.text = ""
		target_edit.text = ""
		ready_box.button_pressed = false
		anchor_picker.clear()
	updating = false
	refresh_anchor()
	stage.queue_redraw()

func select_item(index: int) -> void:
	selected = index
	anchor_index = 0
	mode = "select"
	refresh()

func refresh_anchor() -> void:
	if selected < 0:
		anchor_info.text = "Select furniture to calibrate its contacts and see pose requirements."
		anchor_enabled.disabled = true
		facing_picker.disabled = true
		return
	var anchor: Dictionary = layout.instances[selected].anchors[anchor_index]
	updating = true
	anchor_enabled.disabled = false
	anchor_enabled.button_pressed = anchor.get("enabled",true)
	facing_picker.disabled = anchor.posture == "lying"
	if anchor.posture == "lying":
		facing_picker.select(4)
	else:
		facing_picker.select(library.catalog.directions.find(anchor.actor_facing))
	updating = false
	anchor_info.text = "Contact %s; approach %s\n%s" % [str(anchor.contact),str(anchor.approach),", ".join(Library.pose_ids(anchor)) if anchor.get("enabled",true) else "Disabled: no pose needed for this interaction."]
	stage.queue_redraw()

func set_mode(value: String) -> void:
	if value in ["contact","approach"] and selected < 0:
		status.text = "Select a furniture instance first."
		return
	mode = value
	status.text = "Mode: "+mode+". "+("Click the matching location on the image." if value in ["contact","approach"] else "Drag on the image to "+("draw a furniture rectangle." if value == "draw" else "move selected furniture."))

func next_id(variant: String) -> String:
	var type: String = library.catalog.variants[variant].type
	for number in range(1,10000):
		var candidate: String = str(layout.id)+"_"+type+"_%02d" % number
		var exists := false
		for item in layout.instances:
			exists = exists or item.id == candidate
		if not exists:
			return candidate
	return "furniture_overflow"

func canvas_rect() -> Rect2:
	if layout.is_empty():
		return Rect2()
	var size_value := Library.vector(layout.coordinate_size)
	var scale_value := minf(stage.size.x/size_value.x,stage.size.y/size_value.y)
	return Rect2((stage.size-size_value*scale_value)/2,size_value*scale_value)

func background_point(at: Vector2) -> Vector2:
	var image_rect := canvas_rect()
	return (at-image_rect.position)/(image_rect.size.x/float(layout.coordinate_size[0]))

func canvas_point(at: Vector2) -> Vector2:
	var image_rect := canvas_rect()
	return image_rect.position+at*(image_rect.size.x/float(layout.coordinate_size[0]))

func selected_bounds() -> Rect2:
	var item: Dictionary = layout.instances[selected]
	var result := Library.rect(item.bounds)
	result.position += Library.vector(item.position)
	return result

func canvas_input(event: InputEvent) -> void:
	if layout.is_empty():
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var point := background_point(event.position)
		if event.pressed:
			if not canvas_rect().has_point(event.position):
				return
			if mode in ["contact","approach"] and selected >= 0:
				remember()
				var offset := point-Library.vector(layout.instances[selected].position)
				layout.instances[selected].anchors[anchor_index][mode] = [snappedf(offset.x,0.5),snappedf(offset.y,0.5)]
				layout.instances[selected].ready_for_staging = false
				dirty = true
				mode = "select"
				refresh()
				return
			drag_start = point
			drag_current = point
			if mode == "draw":
				dragging = "new"
			else:
				if selected >= 0 and event.position.distance_to(canvas_point(selected_bounds().end)) < 12:
					dragging = "resize"
				else:
					selected = -1
					for i in range(layout.instances.size()-1,-1,-1):
						var item: Dictionary = layout.instances[i]
						var bounds := Library.rect(item.bounds)
						bounds.position += Library.vector(item.position)
						if bounds.has_point(point):
							selected = i
							break
					dragging = "move" if selected >= 0 else ""
				if selected >= 0:
					remember()
					drag_item = layout.instances[selected].duplicate(true)
				refresh()
		elif not dragging.is_empty():
			if dragging == "new":
				var bounds := Rect2(drag_start,drag_current-drag_start).abs()
				if bounds.size.x >= 8 and bounds.size.y >= 8:
					remember()
					var variant: String = variant_picker.get_item_metadata(variant_picker.selected)
					layout.instances.append(library.create_instance(variant,next_id(variant),bounds))
					selected = layout.instances.size()-1
					dirty = true
					mode = "select"
				dragging = ""
			refresh()
	elif event is InputEventMouseMotion and not dragging.is_empty():
		var point := background_point(event.position)
		point = point.clamp(Vector2.ZERO,Library.vector(layout.coordinate_size)-Vector2(0.1,0.1))
		drag_current = point
		if dragging == "move" and selected >= 0:
			var item := drag_item.duplicate(true)
			var position_value := Library.vector(item.position)+point-drag_start
			var box := Library.rect(item.bounds)
			position_value = position_value.clamp(-box.position,Library.vector(layout.coordinate_size)-box.end)
			item.position = [position_value.x,position_value.y]
			item.ready_for_staging = false
			layout.instances[selected] = item
			dirty = true
		elif dragging == "resize" and selected >= 0:
			var old := Library.rect(drag_item.bounds)
			old.position += Library.vector(drag_item.position)
			var new_size := (point-old.position).max(Vector2(8,8))
			var factor := new_size/old.size
			var item := drag_item.duplicate(true)
			var origin := old.position+Vector2(new_size.x/2,new_size.y)
			item.position = [origin.x,origin.y]
			item.bounds = [-new_size.x/2,-new_size.y,new_size.x,new_size.y]
			var footprint := Library.rect(drag_item.footprint)
			item.footprint = [footprint.position.x*factor.x,footprint.position.y*factor.y,footprint.size.x*factor.x,footprint.size.y*factor.y]
			for anchor in item.anchors:
				for field in ["contact","approach","gaze_target"]:
					if not anchor.has(field):
						continue
					var at := Library.vector(anchor[field])*factor
					anchor[field] = [at.x,at.y]
				var clearance := Library.rect(anchor.clearance)
				anchor.clearance = [clearance.position.x*factor.x,clearance.position.y*factor.y,clearance.size.x*factor.x,clearance.size.y*factor.y]
			item.ready_for_staging = false
			layout.instances[selected] = item
			dirty = true
		stage.queue_redraw()

func apply_variant() -> void:
	if selected < 0:
		return
	remember()
	var variant: String = variant_picker.get_item_metadata(variant_picker.selected)
	layout.instances[selected] = library.create_instance(variant,layout.instances[selected].id,selected_bounds())
	anchor_index = 0
	dirty = true
	refresh()

func delete_selected() -> void:
	if selected < 0:
		return
	remember()
	layout.instances.remove_at(selected)
	selected = -1
	dirty = true
	refresh()

func change_facing(index: int) -> void:
	if updating or selected < 0 or index >= 4:
		return
	remember()
	layout.instances[selected].anchors[anchor_index].actor_facing = library.catalog.directions[index]
	layout.instances[selected].ready_for_staging = false
	dirty = true
	refresh_anchor()

func save() -> void:
	var errors: PackedStringArray = library.save_layout(layout)
	if errors.is_empty():
		dirty = false
		status.text = "Saved and registered: "+library.layout_directory.path_join(str(layout.id)+".json")
		refresh()
	else:
		status.text = errors[0]

func show_pose_list() -> void:
	var lines := PackedStringArray(["BACKGROUND: "+str(layout.id),"Contact points are not character origins. No pose artwork is implied.",""])
	for item in layout.instances:
		lines.append(item.id+" / "+item.variant_id)
		for anchor in item.anchors:
			lines.append("  "+str(anchor.id)+": "+(", ".join(Library.pose_ids(anchor)) if anchor.get("enabled",true) else "disabled"))
	var content := TextEdit.new()
	content.custom_minimum_size = Vector2(900,530)
	content.editable = false
	content.text = "\n".join(lines)
	for child in pose_dialog.get_children():
		if child is TextEdit:
			pose_dialog.remove_child(child)
			child.queue_free()
	pose_dialog.add_child(content)
	pose_dialog.popup_centered(Vector2i(950,600))

func draw_canvas() -> void:
	stage.draw_rect(Rect2(Vector2.ZERO,stage.size),Color("#0a131b"))
	if texture == null or layout.is_empty():
		return
	var image_rect := canvas_rect()
	stage.draw_texture_rect(texture,image_rect,false)
	var factor := image_rect.size.x/float(layout.coordinate_size[0])
	for i in layout.instances.size():
		var item: Dictionary = layout.instances[i]
		var point := Library.vector(item.position)
		var box := Library.rect(item.bounds)
		box.position += point
		var drawn := Rect2(canvas_point(box.position),box.size*factor)
		var color := Color("#f2c979") if i == selected else Color("#7cc7ca")
		stage.draw_rect(drawn,Color(color,0.08))
		stage.draw_rect(drawn,color,false,2)
		var foot := Library.rect(item.footprint)
		stage.draw_rect(Rect2(canvas_point(point+foot.position),foot.size*factor),Color(0.9,0.5,0.25,0.20))
		stage.draw_string(font,drawn.position+Vector2(3,15),item.id,HORIZONTAL_ALIGNMENT_LEFT,-1,12,color)
		for a in item.anchors.size():
			var anchor: Dictionary = item.anchors[a]
			if not anchor.get("enabled",true):
				continue
			var contact := canvas_point(point+Library.vector(anchor.contact))
			var approach := canvas_point(point+Library.vector(anchor.approach))
			stage.draw_line(contact,approach,Color("#64b9c2"),1)
			stage.draw_circle(approach,4,Color("#64b9c2"))
			stage.draw_circle(contact,6 if i == selected and a == anchor_index else 4,Color("#f7ac61"))
			if anchor.actor_facing != null:
				var direction: Vector2 = {"north":Vector2.UP,"east":Vector2.RIGHT,"south":Vector2.DOWN,"west":Vector2.LEFT}[anchor.actor_facing]
				stage.draw_line(contact,contact+direction*18,Color("#ffe5b7"),2)
		if i == selected:
			stage.draw_rect(Rect2(drawn.end-Vector2(5,5),Vector2(10,10)),color)
	if dragging == "new":
		var box := Rect2(canvas_point(drag_start),(drag_current-drag_start)*factor).abs()
		stage.draw_rect(box,Color("#f2c979"),false,2)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed:
		if event.keycode == KEY_S:
			save()
		elif event.keycode == KEY_Z:
			undo()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if dirty and close_confirmation != null:
			close_confirmation.popup_centered()
		else:
			get_tree().quit()
