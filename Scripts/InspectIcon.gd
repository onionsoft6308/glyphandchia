extends Area2D
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_parent()._show_inspect()
		get_parent()._reset_icons()
