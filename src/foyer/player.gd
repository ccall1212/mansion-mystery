extends CharacterBody2D
## Original investigator with four facing directions. Origin is the feet for depth sorting.

const Appearance = preload("res://src/characters/character_render.gd")
const HorizontalAnimation = preload("res://src/characters/detective_animation.gd")
var horizontal_animation: RefCounted
var speed: float = Appearance.settings().movement.speed
var stride_distance: float = Appearance.settings().movement.stride_distance
var facing := Vector2.DOWN
var locked := false
var walk_time := 0.0
var automated_direction := Vector2.ZERO
var sprite_sheet: Texture2D
var sprite_regions: Array[Rect2] = []
var appearance: Dictionary = {}
var is_walking := false
var distance_walked := 0.0
var current_frame := 1

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	if ResourceLoader.exists("res://assets/foyer/investigator-sheet.png"):
		sprite_sheet = load("res://assets/foyer/investigator-sheet.png")
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		appearance = Appearance.sheet(sprite_sheet,4,4)
		sprite_regions.assign(appearance.regions)
		if "--original-horizontal" not in OS.get_cmdline_user_args():
			horizontal_animation = HorizontalAnimation.new()
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(10, 5)
	shape.shape = rect
	shape.position = Vector2(0, -2)
	add_child(shape)
	collision_layer = 2
	collision_mask = 1
	queue_redraw()

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	if not locked:
		direction = Vector2(
			float(Input.is_physical_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)),
			float(Input.is_physical_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)))
		if automated_direction != Vector2.ZERO:
			direction = automated_direction
	if direction != Vector2.ZERO:
		if absf(direction.x) > absf(direction.y):
			facing = Vector2(signf(direction.x),0)
		elif absf(direction.y) > absf(direction.x):
			facing = Vector2(0,signf(direction.y))
		elif facing.dot(direction) <= 0:
			facing = Vector2(0,signf(direction.y))
	velocity = direction.normalized() * speed
	var before := position
	move_and_slide()
	var travelled := position.distance_to(before)
	# Collision recovery can shift a stationary body very slightly. It must not
	# restart the walk cycle after input is released.
	is_walking = direction != Vector2.ZERO and travelled > 0.01 and not locked
	if is_walking:
		distance_walked += travelled
		walk_time = fmod(walk_time + travelled/stride_distance,1.0)
		current_frame = int(Appearance.settings().movement.walk_order[int(walk_time*4.0)%4])
	else:
		walk_time = 0.0
		current_frame = int(Appearance.settings().movement.idle_frame)
	queue_redraw()

func pixel(x: float, y: float, w: float, h: float, color: String) -> void:
	draw_rect(Rect2(x, y, w, h), Color(color))

func _draw() -> void:
	Appearance.draw_shadow(self)
	if horizontal_animation and is_walking and absf(facing.x) > 0.4:
		horizontal_animation.draw_frame(self,facing,current_frame)
		return
	if sprite_sheet and sprite_regions.size() == 16:
		var row := 0
		if facing.y < -0.4:
			row = 3
		elif absf(facing.x) > 0.4:
			row = 2 if facing.x > 0 else 1
		Appearance.draw_frame(self,sprite_sheet,appearance,row*4+current_frame)
		return
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE * (Appearance.height() / 29.0))
	var step := int(sin(walk_time) * 1.7)
	pixel(-5, -5, 4, 5 + step, "#171d27")
	pixel(1, -5, 4, 5 - step, "#171d27")
	pixel(-6, -2 + step, 5, 2, "#0a1018")
	pixel(1, -2 - step, 5, 2, "#0a1018")
	pixel(-7, -17, 14, 13, "#29252a")
	pixel(-6, -17, 12, 11, "#855e46")
	pixel(-4, -16, 8, 9, "#a27a54")
	pixel(-2, -16, 4, 8, "#34515a")
	pixel(-1, -15, 2, 3, "#d0b999")
	pixel(-7, -14, 3, 9, "#614a3f")
	pixel(4, -14, 3, 9, "#614a3f")
	pixel(-7, -6, 3, 2, "#b78d69")
	pixel(4, -6, 3, 2, "#b78d69")
	pixel(-5, -26, 10, 11, "#251f26")
	pixel(-4, -24, 8, 8, "#c69b76")
	pixel(-4, -26, 8, 4, "#443333")
	pixel(-5, -24, 2, 6, "#443333")
	pixel(3, -24, 2, 6, "#443333")
	pixel(-3, -26, 6, 1, "#775745")
	if facing.y < -0.4:
		pixel(-4, -24, 8, 7, "#443333")
		pixel(-2, -22, 5, 2, "#503c35")
	elif absf(facing.x) > 0.4:
		var side := 2 if facing.x > 0 else -3
		pixel(side, -21, 1, 2, "#202b35")
		pixel(side, -18, 2, 1, "#e2b68b")
	else:
		pixel(-3, -21, 2, 1, "#202b35")
		pixel(1, -21, 2, 1, "#202b35")
		pixel(-1, -18, 2, 1, "#8c5e50")
