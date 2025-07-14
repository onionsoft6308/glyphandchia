extends Sprite2D

@export var canoe_path: NodePath

func _process(_delta):
    var canoe = get_node_or_null(canoe_path)
    if canoe:
        var tex_size = texture.get_size()
        var half_size = (tex_size * scale) * 0.5
        # Get canoe position relative to water's top-left corner in world space
        var top_left = global_position - half_size
        var offset = canoe.global_position - top_left
        var uv = Vector2(
            offset.x / (tex_size.x * scale.x),
            offset.y / (tex_size.y * scale.y)
        )
        material.set_shader_parameter("ripple_center", uv)
        material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
        print("Canoe global:", canoe.global_position, " Water top_left:", top_left, " Offset:", offset, " UV:", uv)
    else:
        material.set_shader_parameter("ripple_center", Vector2(-10, -10))