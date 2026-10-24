extends RefCounted
## HD rendering while retaining the existing room/physics/UI reference coordinates.
const REFERENCE := Vector2(480,360)
const DETAIL_ZOOM := 1.5

static func scale_for(viewport: Viewport) -> float:
	var size := viewport.get_visible_rect().size
	return minf(size.x/REFERENCE.x,size.y/REFERENCE.y)

static func fit_window_to_screen() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var usable := DisplayServer.screen_get_usable_rect(DisplayServer.window_get_current_screen())
	var available := Vector2(usable.size)-Vector2(48,80)
	var target := Vector2(1280,960)
	target *= minf(1.0,minf(available.x/target.x,available.y/target.y))
	DisplayServer.window_set_size(Vector2i(target))
	DisplayServer.window_set_position(usable.position+(usable.size-Vector2i(target))/2)

static func toggle_fullscreen() -> void:
	var mode := DisplayServer.window_get_mode()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if mode == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)
