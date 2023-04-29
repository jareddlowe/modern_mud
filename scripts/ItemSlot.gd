extends Button

signal item_right_clicked(item)
signal item_dragged(item, slot)
signal item_dropped(slot)
var item_id
var mouse_pressed
var last_parent


func remove_item_from_slot():
	if get_child(0).get_child_count() > 0:
		get_child(0).get_child(0).queue_free()


func add_item(item_node):
	if item_node:
		get_child(0).add_child(item_node)


func get_item():
	return get_child(0).get_child(0)


func check_if_mouse_above():
	# Todo: check if this panel is active
	var mpos = get_global_mouse_position()
	if mpos.x > global_position.x and mpos.x < global_position.x + size.x:
		if mpos.y > global_position.y and mpos.y < global_position.y + size.y:
			return true


func _on_item_slot_button_down():
	mouse_pressed = true


func _on_item_slot_mouse_exited():
	if mouse_pressed and get_child(0).get_children().size() > 0:
		var item = get_child(0).get_child(0)
		emit_signal("item_dragged", item, self)
	# Reset
	mouse_pressed = false


func _on_item_slot_button_up():
	mouse_pressed = false
