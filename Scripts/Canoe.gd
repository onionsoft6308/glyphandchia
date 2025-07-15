extends Node2D

@export var acceleration := 300.0
@export var max_speed := 400.0
@export var deceleration := 400.0
@export var turn_speed := 4.0 # radians per second

var velocity := Vector2.ZERO
var moving := false
var target_pos := Vector2.ZERO
var is_blocked := false

@onready var line = $Line2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_blocked:
		line.clear_points()  # Clear the line immediately when blocked
		return

	var ui_layer = get_tree().get_root().get_node_or_null("UILayer")
	if ui_layer:
		var overlay = ui_layer.get_node_or_null("DialogueOverlay")
		if overlay and overlay.visible:
			return

	# --- Block canoe input if mouse is over a POI ClickArea ---
	var mouse_pos = get_global_mouse_position()
	var space_state = get_world_2d().direct_space_state
	var params = PhysicsPointQueryParameters2D.new()
	params.position = mouse_pos
	params.collide_with_areas = true
	params.collide_with_bodies = false
	var result = space_state.intersect_point(params, 32)
	for item in result:
		if item.collider and item.collider.is_in_group("poi_click_area"):
			return

	# --- Canoe movement code below ---
	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point(to_local(mouse_pos))

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		moving = true
		target_pos = mouse_pos
	else:
		moving = false

	var to_target = target_pos - global_position
	var distance = to_target.length()
	var target_angle = to_target.angle()

	rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
	var facing_dot = Vector2.RIGHT.rotated(rotation).dot(to_target.normalized())
	var facing_threshold = 0.95

	if moving and distance > 2.0 and facing_dot > facing_threshold:
		var desired_velocity = Vector2.RIGHT.rotated(rotation) * max_speed
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)
		if distance < 100:
			velocity = velocity.normalized() * lerp(0.0, max_speed, distance / 100.0)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
		if velocity.length() < 1.0:
			velocity = Vector2.ZERO

	if is_blocked:
		return

	global_position += velocity * delta
