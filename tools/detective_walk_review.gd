extends SceneTree
## Technical nearest-neighbour contact sheets, measurement overlay and loop frames.
const Appearance = preload("res://src/characters/character_render.gd")
const Horizontal = preload("res://src/characters/detective_animation.gd")
const BASE := "res://assets/characters/detective-walk-v1/review/"
var original: Texture2D
var original_data: Dictionary
var horizontal: RefCounted
var viewport: SubViewport
var canvas: Node2D
var font: Font
var mode := "contact"
var phase := 0
var front: Texture2D
var canon: Array[Texture2D] = []
var canon_data: Array[Dictionary] = []

func _initialize() -> void:
	call_deferred("run")

func label(at: Vector2, value: String, size := 16, color := Color("#d5e2e1")) -> void:
	canvas.draw_string(font,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func run() -> void:
	original = load("res://assets/foyer/investigator-sheet.png")
	original_data = Appearance.sheet(original,4,4)
	horizontal = Horizontal.new()
	front = ImageTexture.create_from_image(original.get_image().get_region(Rect2i(313,0,313,313)))
	for path in ["res://assets/characters/prototype/cast-01.png","res://assets/characters/prototype/cast-13.png","res://assets/characters/standards/kwinn-reference.png","res://assets/characters/prototype/cast-06.png"]:
		var texture := ImageTexture.create_from_image(Image.load_from_file(path))
		canon.append(texture)
		canon_data.append(Appearance.single(texture))
	font = ThemeDB.fallback_font
	viewport = SubViewport.new()
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	canvas = Node2D.new()
	canvas.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	canvas.draw.connect(paint)
	viewport.add_child(canvas)
	await save("contact",Vector2i(1280,1200),BASE+"horizontal-comparison.png")
	await save("measure",Vector2i(1080,760),"res://assets/characters/standards/detective-measurements.png")
	await save("canon",Vector2i(1100,570),"res://assets/characters/standards/canonical-comparison.png")
	for i in 4:
		phase = i
		await save("loop",Vector2i(640,420),BASE+"loop-"+str(i)+".png")
	print("DETECTIVE_REVIEW_SAVED")
	quit()

func save(next_mode: String, size: Vector2i, path: String) -> void:
	mode = next_mode
	viewport.size = size
	canvas.queue_redraw()
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	viewport.get_texture().get_image().save_png(path)

func sprite(at: Vector2, scale_value: float, proposed: bool, row: int, frame: int) -> void:
	canvas.draw_set_transform(at,0,Vector2.ONE*scale_value)
	if proposed:
		horizontal.draw_frame(canvas,Vector2.LEFT if row == 1 else Vector2.RIGHT,frame)
	else:
		Appearance.draw_frame(canvas,original,original_data,row*4+frame)
	canvas.draw_set_transform(Vector2.ZERO)

func paint() -> void:
	canvas.draw_rect(Rect2(Vector2.ZERO,viewport.size),Color("#15232c"))
	if mode == "contact":
		label(Vector2(20,28),"DETECTIVE / ORIGINAL VS USER-CORRECTED HORIZONTAL CYCLE",23,Color("#e0c58d"))
		label(Vector2(20,51),"Nearest-neighbour 4x gameplay size. Original up/down frames and 112 px/s movement remain unchanged.")
		for row in 4:
			var top := 65+row*280
			label(Vector2(18,top+20),["ORIGINAL LEFT","USER-CORRECTED LEFT","ORIGINAL RIGHT","USER-CORRECTED RIGHT"][row],18,Color("#e0c58d"))
			for col in 4:
				var at := Vector2(col*320+160,top+266)
				canvas.draw_rect(Rect2(col*320+2,top+27,316,245),Color("#26343e"),false)
				canvas.draw_line(at-Vector2(140,0),at+Vector2(140,0),Color("#769996"))
				sprite(at,3.7,row%2 == 1,1 if row < 2 else 2,col)
				label(Vector2(col*320+12,top+45),"FRAME "+str(col+1),12)
	elif mode == "loop":
		label(Vector2(22,27),"ORIGINAL",20,Color("#e0c58d"))
		label(Vector2(335,27),"USER CORRECTION / CLEANED",18,Color("#e0c58d"))
		label(Vector2(22,50),"8 fps / 0.5 second cycle / 112 logical pixels per second",14)
		for row in 2:
			label(Vector2(10,86+row*160),"LEFT" if row == 0 else "RIGHT",13)
			for col in 2:
				var at := Vector2(170+col*310,222+row*160)
				canvas.draw_line(at-Vector2(95,0),at+Vector2(95,0),Color("#769996"))
				sprite(at,2.0,col == 1,row+1,phase)
		label(Vector2(22,411),"Phase "+str(phase+1)+" / 4. Ground pivots fixed. No pose transformations after user correction.",12)
	elif mode == "measure":
		label(Vector2(20,30),"EXISTING DETECTIVE / MEASUREMENT REFERENCE",23,Color("#e0c58d"))
		label(Vector2(20,55),"Original front idle, row 0 / column 1. Source cell 313 x 313, shown at 2x nearest neighbour.")
		canvas.draw_texture_rect(front,Rect2(30,80,626,626),false)
		var origin := Vector2(30,80)
		var boxes := [Rect2(85,41,130,251),Rect2(104,41,99,90),Rect2(109,132,87,79),Rect2(111,209,80,83)]
		for i in boxes.size():
			canvas.draw_rect(Rect2(origin+boxes[i].position*2,boxes[i].size*2),[Color("#e0c58d"),Color("#79d6d4"),Color("#ef9c88"),Color("#b8b3ee")][i],false,2)
		canvas.draw_line(Vector2(180,664),Vector2(620,664),Color("#e0c58d"),2)
		label(Vector2(650,115),"EXACT ALPHA BOUNDS",19,Color("#e0c58d"))
		var lines := ["Full figure: 130 x 251 source px","Bounds: (85,41) to (215,292)","Padding: L85 T41 R98 B21","Sheet reference height: 254 px","Display: 32.76 x 63.24 logical px","Source scale: 64/254 = 0.25197","Ground: opaque bottom y=292","Feet origin: (0,0) in game","","ANATOMY / VISUAL ESTIMATES","Head incl. hair: ~99 x 90 px","About 2.79 heads tall","Torso: ~87 x 79 px","Shoulders: ~97 px wide","Arms: ~65-80 px incl. sleeve","Legs + boots: ~83 px","Hands: ~20 x 24 px","Boots: ~28-34 x 22-27 px"]
		for i in lines.size():
			label(Vector2(650,145+i*27),lines[i],16)
		label(Vector2(20,737),"Colored boxes: exact figure bounds; estimated head, torso, legs. Anatomy boundaries are obscured by hair and clothing.",14)
	elif mode == "canon":
		label(Vector2(20,30),"CANONICAL ART REFERENCES / CURRENT DETECTIVE COMPARISON",23,Color("#e0c58d"))
		label(Vector2(20,55),"Same 64-pixel standing-height rule, enlarged 5x. Equal display height does not mean equal anatomy.")
		for i in 5:
			var at := Vector2(110+i*220,450)
			canvas.draw_line(at-Vector2(100,0),at+Vector2(100,0),Color("#769996"))
			if i == 0:
				sprite(at,5,false,0,1)
			else:
				canvas.draw_set_transform(at,0,Vector2.ONE*5)
				Appearance.draw_frame(canvas,canon[i-1],canon_data[i-1],0)
				canvas.draw_set_transform(Vector2.ZERO)
			label(Vector2(i*220+18,485),["DETECTIVE (existing)","CHAR #01","SARAH JO #13","KWINN #07","CHRIS #06"][i],16,Color("#e0c58d"))
			label(Vector2(i*220+18,510),["~2.79 heads","~3.93 heads","~4.63 heads","~3.75 heads","~4.14 heads (cap)"][i],15)
		label(Vector2(20,550),"Ratios are hair/cap-crown-to-chin estimates, not exact anatomical segmentation. Current detective is intentionally preserved.",14)
