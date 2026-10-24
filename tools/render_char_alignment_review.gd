extends SceneTree
## Technical canvas export and review composition only; never redraws pose pixels.
const BASE := "res://assets/characters/poses/char/"
const REVIEW := BASE+"review/alignment_01/"
const FACTOR := 64.0/1673.0
var jobs: Array = []
var game: Node2D

class PoseOverlay extends Node2D:
	var texture: Texture2D
	var contact: Vector2
	func _draw() -> void:
		draw_texture_rect(texture,Rect2(-contact*FACTOR,texture.get_size()*FACTOR),false)

class Comparison extends Node2D:
	var records: Array = []
	var font: Font = ThemeDB.fallback_font
	func _draw() -> void:
		draw_rect(Rect2(0,0,1600,1180),Color("17242b"))
		draw_string(font,Vector2(24,32),"CHAR / ALIGNMENT 01 / SEVEN REVIEW DRAFTS",HORIZONTAL_ALIGNMENT_LEFT,-1,26,Color("e4c68d"))
		draw_string(font,Vector2(24,58),"One common drawing scale. Seated figures stay shorter. Pose, asymmetry and fit approval are pending.",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color.WHITE)
		for i in records.size():
			var entry: Dictionary = records[i]
			var x: float = (i%4)*400.0
			var y: float = 78+floori(i/4.0)*532
			draw_rect(Rect2(x+8,y,384,522),Color("27343c"))
			draw_string(font,Vector2(x+20,y+27),entry.id,HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("f0d8a8"))
			var texture: Texture2D = entry.texture
			var at := Vector2(x+200-texture.get_width()*0.13,y+47)
			draw_line(Vector2(x+20,y+47+1673*0.26),Vector2(x+380,y+47+1673*0.26),Color("56646b"),1)
			draw_texture_rect(texture,Rect2(at,texture.get_size()*0.26),false)
			draw_string(font,Vector2(x+20,y+510),entry.status,HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("b7c8ce"))
		draw_string(font,Vector2(24,1164),"Source scale reference: 1673 px = 64 logical standing pixels. No per-pose height normalization or automatic mirroring.",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("c9d6dc"))

class Context extends Node2D:
	var frame: Texture2D
	var job: Dictionary
	var crop: Rect2
	var font: Font = ThemeDB.fallback_font
	func _draw() -> void:
		if frame==null:
			return
		draw_rect(Rect2(0,0,1440,960),Color("17242b"))
		draw_string(font,Vector2(24,36),"CHAR / "+job.pose_id.to_upper()+" / CHAIR CONTEXT",HORIZONTAL_ALIGNMENT_LEFT,-1,26,Color("e4c68d"))
		draw_string(font,Vector2(24,68),"VISUAL MOCKUP ONLY — actual room render plus review overlay; no runtime pose integration or foreground mask.",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color.WHITE)
		draw_texture_rect(frame,Rect2(24,100,960,640),false)
		draw_texture_rect_region(frame,Rect2(1020,100,384,384),crop)
		var world := Vector2(job.furniture.world_contact[0],job.furniture.world_contact[1])
		var seat := Vector2(job.source_landmarks.seat[0],job.source_landmarks.seat[1])
		var feet := Vector2(job.source_landmarks.feet[0],job.source_landmarks.feet[1])
		var foot_world := world+(feet-seat)*FACTOR
		var screen_seat := Vector2(24,100)+(world-Vector2(0,24))*2
		var screen_feet := Vector2(24,100)+(foot_world-Vector2(0,24))*2
		draw_circle(screen_seat,4,Color("ffaf59"))
		draw_circle(screen_feet,4,Color("64dbea"))
		var lines: PackedStringArray = ["4x local detail — same world scale",job.furniture.room_name,
			job.furniture.orientation_id+" / actor "+job.furniture.actor_facing,job.furniture.instance_id,"anchor: "+job.furniture.anchor_id,
			"Seat world: "+str(world),"Foot estimate: "+str(foot_world.round()),"Orange = seat; cyan = estimated feet",
			"Contact + source landmarks: provisional","Foreground mask: not supplied","Approach footprint: locally clear","Path / collision / occupancy: not tested"]
		for i in lines.size():
			draw_string(font,Vector2(1020,515+i*26),lines[i],HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("c9d6dc"))
		draw_string(font,Vector2(24,785),"CONTACT: "+job.fit_contact,HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("e4c68d"))
		draw_string(font,Vector2(24,820),"Scale is fixed at 64 / 1673 for every pose. The image has not been enlarged to match a chair or standing height.",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color.WHITE)
		draw_string(font,Vector2(24,855),"Review hip support, knees, feet, skirt volume, pose direction and overlaps. Baked chair arms may cover the body incorrectly.",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color.WHITE)
		draw_string(font,Vector2(24,890),"These are rendered alignment samples, not approved staging. Furniture anchors and proper front/back layers still need calibration.",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color.WHITE)

class Closeups extends Node2D:
	var entries: Array = []
	var font: Font = ThemeDB.fallback_font
	func _draw() -> void:
		draw_rect(Rect2(0,0,1500,700),Color("17242b"))
		draw_string(font,Vector2(22,32),"CHAR / THREE CHAIR CONTEXTS / VISUAL MOCKUPS",HORIZONTAL_ALIGNMENT_LEFT,-1,25,Color("e4c68d"))
		draw_string(font,Vector2(22,60),"One shared scale; estimated seat/foot contacts. Foreground masks, navigation and runtime pose integration remain untested.",HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color.WHITE)
		for i in entries.size():
			var entry: Dictionary = entries[i]
			draw_string(font,Vector2(i*500+14,97),entry.id,HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("f0d8a8"))
			draw_texture_rect_region(entry.texture,Rect2(i*500+10,115,480,480),entry.crop)
			draw_string(font,Vector2(i*500+14,630),entry.room,HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color.WHITE)
			draw_string(font,Vector2(i*500+14,659),entry.contact,HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("b7c8ce"))

func _initialize() -> void:
	call_deferred("run")

func texture(path: String) -> Texture2D:
	var image := Image.load_from_file(path)
	assert(image != null,"Unreadable image: "+path)
	return ImageTexture.create_from_image(image)

func run() -> void:
	var approval_batch: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(BASE+"batches/alignment_01.json"))
	for approved_job in approval_batch.get("jobs",[]):
		if approved_job.get("approval","") == "approved":
			printerr("IMAGE_APPROVAL_LOCK: approved alignment samples cannot be re-exported. Use a separately authorized revision path.")
			quit(2)
			return
	DirAccess.make_dir_recursive_absolute(REVIEW)
	var ignored := FileAccess.open(BASE+"review/.gdignore",FileAccess.WRITE)
	ignored.store_string("")
	ignored.close()
	var batch: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(BASE+"batches/alignment_01.json"))
	var cards: Array = [{"id":"APPROVED DESIGN V2","texture":texture(BASE+"masters/likeness-review-02/char-likeness-v2.png"),"status":"User-approved appearance reference"}]
	for entry in batch.jobs:
		var job: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(BASE+"prompts/alignment_01/"+entry.pose_id+".json"))
		jobs.append(job)
		var source := Image.load_from_file("res://"+job.source_master)
		source.convert(Image.FORMAT_RGBA8)
		var padded := Image.create(1045,1844,false,Image.FORMAT_RGBA8)
		padded.fill(Color.TRANSPARENT)
		padded.blit_rect(source,Rect2i(Vector2i.ZERO,source.get_size()),Vector2i(64,64))
		assert(padded.get_region(Rect2i(Vector2i(64,64),source.get_size())).get_data()==source.get_data(),"Padding altered source pixels")
		var destination: String = "res://"+job.exported_draft
		DirAccess.make_dir_recursive_absolute(destination.get_base_dir())
		assert(padded.save_png(destination)==OK)
		cards.append({"id":job.pose_id,"texture":ImageTexture.create_from_image(source),"status":"DRAFT / pose approval pending"})
	var sheet := SubViewport.new()
	sheet.size=Vector2i(1600,1180)
	sheet.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	sheet.canvas_item_default_texture_filter=Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(sheet)
	var comparison := Comparison.new()
	comparison.records=cards
	sheet.add_child(comparison)
	await process_frame
	await RenderingServer.frame_post_draw
	assert(sheet.get_texture().get_image().save_png(REVIEW+"comparison.png")==OK)
	comparison.queue_free()
	await process_frame
	sheet.size=Vector2i(1440,960)
	var context := Context.new()
	sheet.add_child(context)
	var room_view := SubViewport.new()
	room_view.size=Vector2i(480,360)
	room_view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	room_view.canvas_item_default_texture_filter=Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	root.add_child(room_view)
	game=load("res://src/mansion/playable_mansion.tscn").instantiate()
	room_view.add_child(game)
	game.close_view=false
	game.ui.visible=false
	game.player.visible=false
	game.player.set_physics_process(false)
	game.set_process(false)
	game.portals_layer.visible=false
	var snippets: Array = []
	for job in jobs:
		if not job.pose_id.begins_with("seated"):
			continue
		game.house.current_room=job.furniture.room_id
		game.house.position=Vector2(240,280)
		game.load_room()
		game.guest.visible=false
		for actor in game.npc_actors:
			actor.visible=false
		game.update_camera()
		game.camera.reset_smoothing()
		var overlay := PoseOverlay.new()
		overlay.texture=texture("res://"+job.source_master)
		overlay.contact=Vector2(job.source_landmarks.seat[0],job.source_landmarks.seat[1])
		overlay.position=Vector2(job.furniture.world_contact[0],job.furniture.world_contact[1])
		game.world.add_child(overlay)
		await process_frame
		await RenderingServer.frame_post_draw
		var frame := room_view.get_texture().get_image().get_region(Rect2i(0,24,480,320))
		context.frame=ImageTexture.create_from_image(frame)
		context.job=job
		var point := Vector2(job.furniture.world_contact[0],job.furniture.world_contact[1]-24)
		context.crop=Rect2(Vector2(clampf(point.x-48,0,384),clampf(point.y-48,0,224)),Vector2(96,96))
		context.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		assert(sheet.get_texture().get_image().save_png(REVIEW+job.pose_id+"--context.png")==OK)
		snippets.append({"id":job.pose_id,"texture":context.frame,"crop":context.crop,"room":job.furniture.room_name,"contact":job.furniture.instance_id+" / seat"})
		overlay.queue_free()
		await process_frame
	context.queue_free()
	await process_frame
	sheet.size=Vector2i(1500,700)
	var closeups := Closeups.new()
	closeups.entries=snippets
	sheet.add_child(closeups)
	await process_frame
	await RenderingServer.frame_post_draw
	assert(sheet.get_texture().get_image().save_png(REVIEW+"context-closeups.png")==OK)
	print("CHAR_ALIGNMENT_REVIEW_OK seven pixel-preserving padded exports, comparison, three contexts, closeups")
	quit()
