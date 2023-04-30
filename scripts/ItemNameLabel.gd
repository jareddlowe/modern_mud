extends Control

@onready var main = get_parent().get_parent()


func _process(_delta):
	var chosen_slot
	for slot in main.get_node("%InventoryGrid").get_children():
		if slot.check_if_mouse_above():
			chosen_slot = slot
	for slot in main.get_node("%NearbyItemsGrid").get_children():
		if slot.check_if_mouse_above():
			chosen_slot = slot
	if chosen_slot and chosen_slot.get_child(0).get_children().size() > 0 and main.rc_menu == null:
		visible = true
		var label = $Panel/MarginContainer/Label
		label.text = chosen_slot.get_child(0).get_child(0).name
	else:
		visible = false
