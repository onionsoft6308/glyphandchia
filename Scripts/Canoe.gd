extends Node2D

@export var acceleration := 300.0
@export var max_speed := 400.0
@export var deceleration := 400.0
@export var turn_speed := 4.0 # radians per second

var velocity := Vector2.ZERO
var moving := false
var target_pos := Vector2.ZERO

@onready var line = $Line2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = get_global_mouse_position()
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

	# Smoothly rotate towards the target angle
	rotation = lerp_angle(rotation, target_angle, turn_speed * delta)

	# Only accelerate if facing (roughly) the target direction
	var facing_dot = Vector2.RIGHT.rotated(rotation).dot(to_target.normalized())
	var facing_threshold = 0.95 # 1.0 = perfect, lower = more forgiving

	if moving and distance > 2.0 and facing_dot > facing_threshold:
		var desired_velocity = Vector2.RIGHT.rotated(rotation) * max_speed
		velocity = velocity.move_toward(desired_velocity, acceleration * delta)
		if distance < 100:
			velocity = velocity.normalized() * lerp(0.0, max_speed, distance / 100.0)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
		if velocity.length() < 1.0:
			velocity = Vector2.ZERO

	global_position += velocity * delta
