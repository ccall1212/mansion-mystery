extends SceneTree
## Technical extraction of the user's corrected sheet. Interior RGB is preserved.
const BASE := "res://assets/characters/detective-walk-v1/"
func _initialize() -> void:
    var original := Image.load_from_file(BASE+"masters/user-corrected-horizontal.png")
    var mask := Image.load_from_file(BASE+"masters/user-cleanup-candidate.png")
    assert(original.get_size() == mask.get_size())
    original.convert(Image.FORMAT_RGBA8)
    var cleaned := original.duplicate() as Image
    var fringe_pixels := 0
    for y in original.get_height():
        for x in original.get_width():
            var color := original.get_pixel(x,y)
            color.a = 1.0 if mask.get_pixel(x,y).a >= 0.5 else 0.0
            if color.a > 0:
                var edge := false
                for delta in [Vector2i(-2,0),Vector2i(2,0),Vector2i(0,-2),Vector2i(0,2)]:
                    var p: Vector2i = Vector2i(x,y)+delta
                    if p.x < 0 or p.y < 0 or p.x >= mask.get_width() or p.y >= mask.get_height() or mask.get_pixelv(p).a < 0.5:
                        edge = true
                if edge and color.r > color.g*2.8 and color.r > color.b*2.8 and color.s > 0.70 and color.h < 0.055:
                    color = Color("#241c1a")
                    fringe_pixels += 1
            cleaned.set_pixel(x,y,color)
    assert(cleaned.save_png(BASE+"cleaned-user-sheet.png") == OK)
    var sheet := Image.create(1600,1200,false,Image.FORMAT_RGBA8)
    var measurements: Array = []
    for row in 2:
        # The pasted sheet is not a uniform atlas; split in actual transparent gaps.
        var empty: Array[bool] = []
        for x in cleaned.get_width():
            var clear := true
            for y in range(row*600,(row+1)*600):
                if cleaned.get_pixel(x,y).a > 0.5:
                    clear = false
                    break
            empty.append(clear)
        var separators := [0]
        for column in range(1,4):
            var guess := column*cleaned.get_width()/4
            var found := -1
            for distance in 90:
                for x in [guess-distance,guess+distance]:
                    if x > 0 and x < empty.size()-1 and empty[x]:
                        found = x
                        break
                if found >= 0:
                    break
            assert(found >= 0)
            var left := found
            var right := found
            while left > 0 and empty[left-1]:
                left -= 1
            while right < empty.size()-1 and empty[right+1]:
                right += 1
            separators.append((left+right)/2)
        separators.append(cleaned.get_width())
        for col in 4:
            var source := Rect2i(separators[col],row*600,separators[col+1]-separators[col],600)
            var image := cleaned.get_region(source)
            var bounds := image.get_used_rect()
            var centres: Array[float] = []
            # Align a stationary head axis, not a sleeve/coat whose swing is intentional.
            for y in range(bounds.position.y+40,bounds.position.y+110):
                var left := image.get_width()
                var right := -1
                for x in image.get_width():
                    if image.get_pixel(x,y).a >= 0.5:
                        left = mini(left,x)
                        right = maxi(right,x)
                if right >= left:
                    centres.append((left+right)*0.5)
            centres.sort()
            var axis: float = centres[centres.size()/2]
            # Shared head-to-hip offset per facing; never align by a moving arm.
            var hip_axis := roundi(axis + (15 if row == 0 else -15))
            var offset := Vector2i(col*400+200-hip_axis,row*600+540-bounds.end.y)
            sheet.blit_rect(image,bounds,bounds.position+offset)
            var frame := Image.create(400,600,false,Image.FORMAT_RGBA8)
            frame.blit_rect(image,bounds,bounds.position+Vector2i(200-hip_axis,540-bounds.end.y))
            frame.save_png(BASE+("left" if row == 0 else "right")+"-"+str(col)+".png")
            measurements.append({"row":row,"column":col,"source_rect":[source.position.x,source.position.y,source.size.x,source.size.y],"source_bounds":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y],"pivot":[col*400+200,row*600+540],"offset":[200-hip_axis,540-bounds.end.y]})
    assert(sheet.save_png(BASE+"horizontal-sheet.png") == OK)
    FileAccess.open(BASE+"extraction.json",FileAccess.WRITE).store_string(JSON.stringify({"frames":measurements,"fringe_pixels":fringe_pixels,"method":"user RGB; generated alpha mask; red exterior fringe only; no limb transforms or resizing"},"  "))
    print("USER_WALK_EXTRACTED fringe=",fringe_pixels)
    quit()
