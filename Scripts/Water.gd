extends Sprite2D

@export var canoe_path: NodePath
@export var ripple_lifetime: float = 0.5
@export var ripple_interval: float = 0.3 # seconds between ripples

var ripples := []
var last_ripple_time := 0.0
var was_moving := false

func _process(_delta):
    var canoe = get_node_or_null(canoe_path)
    var t = Time.get_ticks_msec() / 1000.0
    var moving_now = false
    if canoe:
        moving_now = canoe.velocity.length() > 1.0
        # Clear ripples when movement starts
        if moving_now and not was_moving:
            ripples.clear()
            last_ripple_time = t
        was_moving = moving_now

        var tex_size = texture.get_size()
        var half_size = (tex_size * scale) * 0.5
        var top_left = global_position - half_size
        var offset = canoe.global_position - top_left
        var uv = Vector2(
            offset.x / (tex_size.x * scale.x),
            offset.y / (tex_size.y * scale.y)
        )
        # Spawn a ripple only at intervals while moving
        if moving_now:
            if t - last_ripple_time > ripple_interval:
                ripples.append({ "center": uv, "start_time": t })
                last_ripple_time = t
        # Remove old ripples
        ripples = ripples.filter(func(r): return t - r.start_time < ripple_lifetime)
        # Pass up to 8 ripples to the shader
        for i in range(8):
            if i < ripples.size():
                material.set_shader_parameter("ripple_center" + str(i), ripples[i].center)
                material.set_shader_parameter("ripple_time" + str(i), t - ripples[i].start_time)
            else:
                material.set_shader_parameter("ripple_center" + str(i), Vector2(-10, -10))
                material.set_shader_parameter("ripple_time" + str(i), 0.0)
    else:
        for i in range(8):
            material.set_shader_parameter("ripple_center" + str(i), Vector2(-10, -10))
            material.set_shader_parameter("ripple_time" + str(i), 0.0)