extends Node

class Overview extends Node2D:
	var plans: Array = []
	var font: Font = ThemeDB.fallback_font
	func label(at: Vector2, value: String, size := 12, color := Color("#c9d8de")) -> void:
		draw_string(font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
	func _draw() -> void:
		draw_rect(Rect2(0, 0, 1440, 70 + plans.size() * 350), Color("#0b1c29"))
		label(Vector2(18, 29), "SLEUTH / FOUR MANSION BLUEPRINTS", 25, Color("#dfc895"))
		label(Vector2(18, 52), "Paired doors · Main (M) and service (S) stairs align across floors · Proposed layouts, room art/geometry follows review", 16)
		for p in plans.size():
			var plan: Dictionary = plans[p]
			var top := 70 + p * 350
			label(Vector2(18, top + 19), plan.name + "  /  4 rooms + 2 halls per floor", 19, Color("#dfc895"))
			for level in [-1, 0, 1]:
				var left: int = 16 + (level + 1) * 480
				label(Vector2(left, top + 44), ["BASEMENT", "GROUND FLOOR", "UPPER FLOOR"][level + 1], 13, Color("#96c6d0"))
				for room in plan.rooms:
					if int(room.floor) != level:
						continue
					var rect := Rect2(left + room.grid[0] * 145, top + 56 + room.grid[1] * 84, 145, 84)
					var fill := Color("#3c3b31") if room.get("contains_stairs", false) else Color("#1d3b4d") if room.role == "passage" else Color("#142d3e")
					draw_rect(rect, fill)
					draw_rect(rect, Color("#8aadb9"), false, 1)
					for port in room.ports:
						var center := rect.get_center()
						if room.get("locked_ports", []).has(port):
							draw_line(Vector2(center.x - 14, rect.position.y), Vector2(center.x + 14, rect.position.y), Color("#db8b79"), 4)
							label(rect.position + Vector2(6, 15), "FRONT / LOCKED", 11, Color("#edb2a2"))
							continue
						if port in ["north", "south"]:
							var y := rect.position.y if port == "north" else rect.end.y
							draw_line(Vector2(center.x - 9, y), Vector2(center.x + 9, y), fill, 4)
							draw_line(Vector2(center.x - 8, y), Vector2(center.x + 8, y), Color("#d2b77e"), 2)
						elif port in ["east", "west"]:
							var x := rect.position.x if port == "west" else rect.end.x
							draw_line(Vector2(x, center.y - 9), Vector2(x, center.y + 9), fill, 4)
							draw_line(Vector2(x, center.y - 8), Vector2(x, center.y + 8), Color("#d2b77e"), 2)
					var line := ""
					var row := 0
					for word in str(room.name).split(" "):
						if (line + word).length() > 12:
							label(rect.position + Vector2(6, 34 + row * 14), line.strip_edges(), 11)
							row += 1
							line = ""
						line += word + " "
					label(rect.position + Vector2(6, 34 + row * 14), line.strip_edges(), 11)
					if room.get("contains_stairs", false):
						var mark := "M" if str(room.id).contains("main") else "S"
						mark += " ↑" if room.ports.has("up") else ""
						mark += " ↓" if room.ports.has("down") else ""
						label(rect.position + Vector2(6, 15), mark, 11, Color("#e5c68c"))
			draw_line(Vector2(16, top + 331), Vector2(1415, top + 331), Color("#315166"))

func _ready() -> void:
	get_window().size = Vector2i(320, 180)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/mansion/blueprints.json"))
	var groups: Array = [data.blueprints]
	for plan in data.blueprints:
		groups.append([plan])
	for index in groups.size():
		var viewport := SubViewport.new()
		viewport.size = Vector2i(1440, 70 + groups[index].size() * 350)
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		add_child(viewport)
		var sheet := Overview.new()
		sheet.plans = groups[index]
		viewport.add_child(sheet)
		await get_tree().process_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var filename := "all-mansion-blueprints.png" if index == 0 else "manor-%d-all-floors.png" % index
		if viewport.get_texture().get_image().save_png("res://assets/mansion/review/" + filename) != OK:
			get_tree().quit(1)
			return
		print("BLUEPRINT_OVERVIEW_SAVED ", filename)
		viewport.queue_free()
	get_tree().quit()
