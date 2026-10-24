extends SceneTree
## Capture the actual room renderer, then draw review-only annotation sheets.
const Library = preload("res://src/furniture/furniture_library.gd")
const OUTPUT := "res://assets/furniture/review/all-rooms/"
var game: Node2D
var report := {"rooms":[],"pose_requirements":{},"ok":false}

class ReviewSheet extends Node2D:
	var picture: Texture2D
	var layout: Dictionary
	var room: Dictionary
	var room_id: String
	var shared_names: String
	var font: Font = ThemeDB.fallback_font
	func _draw() -> void:
		if room.is_empty() or picture == null:
			return
		draw_rect(Rect2(0,0,1440,960),Color("17242b"))
		draw_string(font,Vector2(24,38),"SLEUTH / "+room.name.to_upper()+" / FURNITURE REVIEW",HORIZONTAL_ALIGNMENT_LEFT,-1,25,Color("e4c68d"))
		var floor_name: String = {"-1":"BASEMENT","0":"GROUND FLOOR","1":"UPPER FLOOR"}[str(int(room.floor))]
		draw_string(font,Vector2(24,68),floor_name+"  |  "+room_id+"  |  "+str(layout.instances.size())+" object tags",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color.WHITE)
		draw_string(font,Vector2(24,95),"Draft contacts: orange = body/feet contact; cyan = approach. Numbers match the right-hand IDs.",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("c4d5da"))
		draw_texture_rect(picture,Rect2(24,120,960,640),false)
		for index in layout.instances.size():
			var item: Dictionary = layout.instances[index]
			var origin := Library.vector(item.position)
			var bounds := Library.rect(item.bounds)
			bounds.position = Vector2(24,120)+(bounds.position+origin)*2
			bounds.size *= 2
			draw_rect(bounds,Color(1,.8,.35,.7),false,1.5)
			for a in item.anchors:
				if not a.get("enabled",true):
					continue
				var contact := Vector2(24,120)+(origin+Library.vector(a.contact))*2
				var approach := Vector2(24,120)+(origin+Library.vector(a.approach))*2
				draw_line(contact,approach,Color(0.3,.85,.95,.6),1)
				draw_circle(approach,3,Color("64dbea"))
				draw_circle(contact,4,Color("ff9759"))
				if a.get("actor_facing") != null:
					var facing: Vector2 = {"north":Vector2.UP,"east":Vector2.RIGHT,"south":Vector2.DOWN,"west":Vector2.LEFT}[a.actor_facing]
					draw_line(contact,contact+facing*22,Color("ffe5b7"),2)
					draw_line(contact+facing*22,contact+facing*16+facing.orthogonal()*5,Color("ffe5b7"),2)
					draw_line(contact+facing*22,contact+facing*16-facing.orthogonal()*5,Color("ffe5b7"),2)
				if a.has("gaze_target"):
					var gaze := Vector2(24,120)+(origin+Library.vector(a.gaze_target))*2
					draw_dashed_line(contact,gaze,Color(0.75,0.63,0.88,0.6),1,5)
					draw_circle(gaze,3,Color("bfa0df"))
			var marker := bounds.position+Vector2(12,12)
			draw_circle(marker,12,Color("15242c"))
			draw_arc(marker,12,0,TAU,24,Color("efcf8a"),1)
			draw_string(font,marker+Vector2(-8 if index>=9 else -4,5),str(index+1),HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color.WHITE)
			var y: int = 139+index*64
			draw_string(font,Vector2(1004,y),"%02d  %s" % [index+1,item.id],HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("f1d6a3"))
			draw_string(font,Vector2(1028,y+20),item.variant_id,HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color.WHITE)
			var labels: PackedStringArray = []
			for a in item.anchors:
				if a.get("enabled",true):
					var label: String = "lying / head "+str(a.head_toward) if a.posture=="lying" else a.posture+" / "+str(a.actor_facing)
					if not label in labels:
						labels.append(label)
			draw_string(font,Vector2(1028,y+39),"; ".join(labels) if not labels.is_empty() else "Disabled: access blocked",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("acbfc8"))
		draw_string(font,Vector2(24,800),"SHARED ART: "+shared_names,HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("e4c68d"))
		draw_string(font,Vector2(24,832),"Visual tags do not create doors, move furniture, or enable automatic NPC staging.",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color.WHITE)
		draw_string(font,Vector2(24,862),"Existing room navigation, pose landmarks and foreground overlap still need calibration.",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color.WHITE)
		draw_string(font,Vector2(24,900),"Portable clue objects are shown by the game renderer; they retain their separate evidence IDs.",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("acbfc8"))

class FloorSheet extends Node2D:
	var entries: Array = []
	var title := ""
	var font: Font = ThemeDB.fallback_font
	func _draw() -> void:
		draw_rect(Rect2(0,0,1440,1560),Color("17242b"))
		draw_string(font,Vector2(24,38),"SLEUTH / "+title+" / ALL TAGGED ROOMS",HORIZONTAL_ALIGNMENT_LEFT,-1,25,Color("e4c68d"))
		for i in entries.size():
			draw_texture_rect(entries[i],Rect2((i%2)*720,60+(i/2)*500,720,480),false)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	var ignored := FileAccess.open(OUTPUT+".gdignore",FileAccess.WRITE)
	ignored.store_string("")
	ignored.close()
	var viewport := SubViewport.new()
	viewport.size = Vector2i(480,360)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(viewport)
	game = load("res://src/mansion/playable_mansion.tscn").instantiate()
	viewport.add_child(game)
	game.close_view = false
	game.ui.visible = false
	game.set_process(false)
	game.player.set_physics_process(false)
	game.player.visible = false
	game.portals_layer.visible = false
	var sheets := SubViewport.new()
	sheets.size = Vector2i(1440,960)
	sheets.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sheets.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(sheets)
	var sheet := ReviewSheet.new()
	sheets.add_child(sheet)
	var floors := {"-1":[],"0":[],"1":[]}
	for id in game.house.rooms:
		var room: Dictionary = game.house.rooms[id]
		game.house.current_room = id
		game.house.position = Vector2(240,280)
		game.load_room()
		game.guest.visible = false
		for npc in game.npc_actors:
			npc.visible = false
		game.update_camera()
		game.camera.reset_smoothing()
		var layout: Dictionary = game.house.furniture_library.for_background(room.asset,room.get("furniture_layout",""))
		assert(not layout.is_empty(),"Missing furniture layout: "+id)
		var shared: PackedStringArray = []
		for other in game.house.rooms:
			if game.house.rooms[other].asset == room.asset:
				shared.append(game.house.rooms[other].name)
		await process_frame
		await RenderingServer.frame_post_draw
		var frame := viewport.get_texture().get_image().get_region(Rect2i(0,24,480,320))
		sheet.picture = ImageTexture.create_from_image(frame)
		sheet.layout = layout
		sheet.room = room
		sheet.room_id = id
		sheet.shared_names = ", ".join(shared)
		sheet.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		var captured := sheets.get_texture().get_image()
		assert(captured.save_png(OUTPUT+id+".png") == OK)
		floors[str(int(room.floor))].append(ImageTexture.create_from_image(captured))
		var room_report := {"id":id,"name":room.name,"floor":room.floor,"asset":room.asset,"layout":layout.id,"tags":layout.instances.size(),"contacts":[]}
		for item in layout.instances:
			for anchor in item.anchors:
				if not anchor.get("enabled",true):
					continue
				var approach := Library.vector(item.position)+Library.vector(anchor.approach)+Vector2(0,24)
				var key: String = id+"::"+item.id+"::"+anchor.id
				var reachable: bool = game.house.feet_free(id,approach,false)
				room_report.contacts.append({"key":key,"approach_clear":reachable,"pose_ids":Array(Library.pose_ids(anchor)),"actor_facing":anchor.get("actor_facing"),"interaction_side":anchor.get("interaction_side"),"posture":anchor.posture,"orientation_id":item.variant_id})
				for pose in Library.pose_ids(anchor):
					if not report.pose_requirements.has(pose):
						report.pose_requirements[pose] = []
					report.pose_requirements[pose].append({"contact":key,"approach_clear":reachable})
		report.rooms.append(room_report)
		print("ROOM_CAPTURE ",id," tags=",layout.instances.size())
	sheet.queue_free()
	await process_frame
	sheets.size = Vector2i(1440,1560)
	var floor_sheet := FloorSheet.new()
	sheets.add_child(floor_sheet)
	for floor_id in floors:
		floor_sheet.title = {"-1":"BASEMENT","0":"GROUND FLOOR","1":"UPPER FLOOR"}[floor_id]
		floor_sheet.entries = floors[floor_id]
		floor_sheet.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		assert(sheets.get_texture().get_image().save_png(OUTPUT+"floor_"+floor_id+".png") == OK)
	report.ok = report.rooms.size()==18
	var output := FileAccess.open("res://test-results/tagged-room-coverage.json",FileAccess.WRITE)
	output.store_string(JSON.stringify(report,"  "))
	output.close()
	print("TAGGED_ROOM_CAPTURE_OK ",report.ok)
	quit(0 if report.ok else 1)
