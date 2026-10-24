extends Node2D
## Art integration preview, deliberately separate from playable room navigation.

const MANIFEST := "res://assets/rooms/room-manifest.json"
var rooms: Array = []
var layouts: Array = []
var current := 0
var background: Sprite2D
var player: CharacterBody2D
var guest: Node2D
var camera: Camera2D
var hud: Node2D
var prop_layer: Node2D
var actors_visible := true
var props_visible := true
var close_view := false
var font: Font = ThemeDB.fallback_font
var capture_mode := false

func _ready() -> void:
	DisplayServer.window_set_title("Sleuth — Mansion Environment Review")
	RenderingServer.set_default_clear_color(Color("#101a21"))
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
	rooms = data.rooms
	for room in rooms:
		for variant in room.variants:
			var view: Dictionary = room.duplicate(true)
			view.merge(variant, true)
			layouts.append(view)
	background = Sprite2D.new()
	background.centered = false
	background.position = Vector2(0, 24)
	add_child(background)
	prop_layer = Node2D.new()
	prop_layer.position = Vector2(0, 24)
	add_child(prop_layer)
	var actors := Node2D.new()
	actors.y_sort_enabled = true
	add_child(actors)
	player = preload("res://src/foyer/player.gd").new()
	player.locked = true
	actors.add_child(player)
	guest = preload("res://src/foyer/guest.gd").new()
	guest.addressed = true
	actors.add_child(guest)
	camera = Camera2D.new()
	add_child(camera)
	var layer := CanvasLayer.new()
	layer.layer = 20
	add_child(layer)
	hud = Node2D.new()
	hud.draw.connect(draw_hud)
	layer.add_child(hud)
	capture_mode = "--environment-capture" in OS.get_cmdline_user_args()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--room="):
			var wanted := arg.trim_prefix("--room=")
			for i in layouts.size():
				if layouts[i].id == wanted:
					current = i
	load_room(current)
	if capture_mode:
		call_deferred("capture_all")
	elif "--environment-test" in OS.get_cmdline_user_args():
		call_deferred("run_review_checks")

func load_room(index: int) -> void:
	current = posmod(index, layouts.size())
	var room: Dictionary = layouts[current]
	var texture := load(str(room.asset)) as Texture2D
	if texture == null or texture.get_size() != Vector2(480, 320):
		push_error("Invalid environment: " + str(room.asset))
		get_tree().quit(1)
		return
	background.texture = texture
	var feet: Array = room.comparison_feet
	player.position = Vector2(float(feet[0]), float(feet[1]) + 24)
	guest.position = player.position + Vector2(46, -3)
	if room.has("guest_comparison_feet"):
		guest.position = Vector2(float(room.guest_comparison_feet[0]), float(room.guest_comparison_feet[1]) + 24)
	player.visible = actors_visible
	guest.visible = actors_visible
	for child in prop_layer.get_children():
		prop_layer.remove_child(child)
		child.queue_free()
	for data in room.get("layers", []):
		var prop := Sprite2D.new()
		prop.centered = false
		prop.texture = load(str(data.asset)) as Texture2D
		prop.position = Vector2(float(data.position[0]), float(data.position[1]))
		prop.scale = Vector2(float(data.size[0]) / prop.texture.get_width(), float(data.size[1]) / prop.texture.get_height())
		prop_layer.add_child(prop)
	prop_layer.visible = props_visible
	update_camera()
	hud.queue_redraw()

func update_camera() -> void:
	camera.zoom = Vector2.ONE * (2.0 if close_view else 1.0)
	camera.position = Vector2(clampf(player.position.x, 120, 360), clampf(player.position.y - 18, 114, 254)) if close_view else Vector2(240, 180)
	camera.force_update_scroll()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo or capture_mode:
		return
	if event.keycode >= KEY_1 and event.keycode <= KEY_9:
		load_room((event.keycode - KEY_1) * 2)
	elif event.keycode in [KEY_RIGHT, KEY_DOWN]:
		load_room(current + 1)
	elif event.keycode in [KEY_LEFT, KEY_UP]:
		load_room(current - 1)
	elif event.keycode == KEY_Z:
		close_view = not close_view
		update_camera()
	elif event.keycode == KEY_A:
		actors_visible = not actors_visible
		player.visible = actors_visible
		guest.visible = actors_visible
	elif event.keycode == KEY_V:
		load_room(current + (1 if current % 2 == 0 else -1))
	elif event.keycode == KEY_P:
		props_visible = not props_visible
		prop_layer.visible = props_visible
	hud.queue_redraw()

func draw_hud() -> void:
	hud.draw_rect(Rect2(0, 0, 480, 24), Color("#101a21"))
	hud.draw_string(font, Vector2(12, 16), "%02d%s / %s" % [layouts[current].number, layouts[current].layout, layouts[current].name], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#dfc895"))
	hud.draw_string(font, Vector2(312, 16), "ART REVIEW / %dx" % (2 if close_view else 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#a8b9bc"))
	hud.draw_rect(Rect2(0, 344, 480, 16), Color("#101a21"))
	hud.draw_string(font, Vector2(9, 355), "1-9 / ARROWS  Room   V  Variant   Z  Zoom   A  Actors   P  Props", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#c4c5bd"))

func settle_frame() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw

func run_review_checks() -> void:
	var failures: Array[String] = []
	var checks := 0
	for i in layouts.size():
		load_room(i)
		checks += 1
		if background.texture.get_size() != Vector2(480, 320) or not player.locked:
			failures.append("Invalid dimensions or actor not locked: " + str(layouts[i].id))
	load_room(layouts.size() - 1)
	review_key(KEY_RIGHT)
	checks += 1
	if current != 0:
		failures.append("Next layout did not wrap")
	review_key(KEY_LEFT)
	checks += 1
	if current != layouts.size() - 1:
		failures.append("Previous layout did not wrap")
	review_key(KEY_5)
	review_key(KEY_V)
	checks += 1
	if layouts[current].id != "library-alternate":
		failures.append("Room selection/variant toggle failed")
	review_key(KEY_Z)
	checks += 1
	if camera.zoom != Vector2(2, 2):
		failures.append("Close preview did not zoom")
	review_key(KEY_A)
	checks += 1
	if player.visible or guest.visible:
		failures.append("Actor visibility toggle failed")
	review_key(KEY_P)
	checks += 1
	if prop_layer.visible:
		failures.append("Prop visibility toggle failed")
	var report := {"ok": failures.is_empty(), "checks": checks, "failures": failures, "layouts": layouts.size()}
	DirAccess.make_dir_recursive_absolute("res://test-results")
	var file := FileAccess.open("res://test-results/environment-engine-tests.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	print("ENVIRONMENT_TEST_RESULT ", JSON.stringify(report))
	get_tree().quit(0 if failures.is_empty() else 1)

func review_key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	_unhandled_key_input(event)

func capture_all() -> void:
	DirAccess.make_dir_recursive_absolute("res://test-results/environments")
	var captures: Array = []
	var only := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--room="):
			only = arg.trim_prefix("--room=")
	for i in layouts.size():
		if not only.is_empty() and layouts[i].id != only:
			continue
		for zoom in [1, 2]:
			close_view = zoom == 2
			load_room(i)
			await settle_frame()
			var path := "res://test-results/environments/%s-%dx.png" % [layouts[i].id, zoom]
			if get_viewport().get_texture().get_image().save_png(path) != OK:
				get_tree().quit(1)
				return
			captures.append(path)
			print("ENVIRONMENT_CAPTURED ", path)
	var report := {"ok": true, "room_count": rooms.size(), "layout_count": layouts.size(), "capture_count": captures.size(), "captures": captures, "gameplay_navigation_tested": false, "native_actor_height": 48, "room_size": [480, 320]}
	var file := FileAccess.open("res://test-results/environments/engine-review.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	get_tree().quit()
