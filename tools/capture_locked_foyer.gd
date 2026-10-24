extends SceneTree
## Render the actual foyer's north/front-door response without global input.

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var scene = load("res://src/foyer/foyer.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.player.position = Vector2(240, 205)
	scene.close_view = false
	scene.update_camera()
	scene.camera.reset_smoothing()
	scene.interact()
	if scene.dialogue_heading != "THE LOCKED FRONT DOORS" or not scene.player.locked:
		quit(1)
		return
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://test-results/screenshots")
	var error := root.get_texture().get_image().save_png("res://test-results/screenshots/foyer-locked-front-door.png")
	quit(0 if error == OK else 1)
