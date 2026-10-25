extends RefCounted
## Schematic connectivity on the current floor, derived from runtime room data.
static func model(house: RefCounted) -> Dictionary:
	var ids: Array = []
	var adjacent: Dictionary = {}
	var main_count := 0
	for id in house.rooms:
		var room: Dictionary = house.rooms[id]
		if int(room.floor) != house.floor_id(): continue
		ids.append(id)
		adjacent[id] = []
		if room.role == "room": main_count += 1
		for portal in room.portals:
			if int(house.rooms[portal.target].floor) == house.floor_id():
				adjacent[id].append(portal.target)
	var ordered: Array = []
	if not ids.is_empty():
		var start: String = ids[0]
		for id in ids:
			if adjacent[id].size() <= 1:
				start = id
				break
		var pending := [start]
		while not pending.is_empty():
			var id: String = pending.pop_back()
			if id in ordered: continue
			ordered.append(id)
			for other in adjacent[id]: pending.append(other)
	for id in ids:
		if not id in ordered: ordered.append(id)
	var nodes: Array = []
	var edges: Array = []
	var names := {"Library":"Lib.","Dining Room":"Dine","Kitchen":"Kit.","Main Bedroom":"Bed","Basement Storage":"Store","Upstairs Landing":"Land."}
	for id in ordered:
		var room: Dictionary = house.rooms[id]
		var vertical := ""
		for portal in room.portals:
			var delta: int = int(house.rooms[portal.target].floor)-int(house.floor_id())
			if delta != 0: vertical += "+" if delta > 0 else "-"
		nodes.append({"id":id,"label":room.get("map_label",names.get(room.name,"Stair" if room.role == "passage" else str(room.name).left(5))),"current":id==house.current_room,"visited":id in house.visited,"vertical":vertical})
		for other in adjacent[id]:
			if ordered.find(id) < ordered.find(other): edges.append([ordered.find(id),ordered.find(other)])
	return {"floor":house.floor_id(),"main_rooms":main_count,"nodes":nodes,"edges":edges}

static func draw(canvas: CanvasItem, font: Font, house: RefCounted) -> void:
	var data := model(house)
	canvas.draw_rect(Rect2(326,28,149,61),Color(0.04,0.08,0.11,0.95))
	var floor_name := "Basement" if data.floor < 0 else "Upstairs" if data.floor > 0 else "Ground"
	canvas.draw_string(font,Vector2(332,40),floor_name+" / %d rooms" % data.main_rooms,HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("#edce98"))
	var centers: Array[Vector2] = []
	var spacing := minf(28.0,130.0/maxi(1,data.nodes.size()-1))
	for i in data.nodes.size(): centers.append(Vector2(400-(data.nodes.size()-1)*spacing/2+i*spacing,60))
	for edge in data.edges: canvas.draw_line(centers[edge[0]],centers[edge[1]],Color("#819ca8"),1)
	for i in data.nodes.size():
		var node: Dictionary = data.nodes[i]
		var box := Rect2(centers[i]-Vector2(12,7),Vector2(24,14))
		var color := Color("#d6b675") if node.current else Color("#3c646a") if node.visited else Color("#263640")
		canvas.draw_rect(box,color)
		canvas.draw_rect(box,Color("#d6b675") if node.current else Color("#819ca8"),false)
		var width := font.get_string_size(node.label,HORIZONTAL_ALIGNMENT_LEFT,-1,7).x
		canvas.draw_string(font,centers[i]+Vector2(-width/2,2.5),node.label,HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("#101b23") if node.current else Color("#e0eaed"))
		if not node.vertical.is_empty(): canvas.draw_string(font,centers[i]+Vector2(-5,18),"UP" if node.vertical=="+" else "DN" if node.vertical=="-" else "U/D",HORIZONTAL_ALIGNMENT_LEFT,-1,6,Color("#edce98"))
	canvas.draw_string(font,Vector2(332,84),"Gold: here   Teal: visited   UP/DN: stairs",HORIZONTAL_ALIGNMENT_LEFT,-1,6,Color("#adc1ca"))
