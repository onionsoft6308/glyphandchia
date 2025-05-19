
extends Node

var current_active_item = null

func set_active_item(item):
    if current_active_item and current_active_item != item:
        current_active_item._hide_icons_immediately()
    current_active_item = item

func clear_active_item(item):
    if current_active_item == item:
        current_active_item = null