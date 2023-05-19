extends Control

@onready var player = get_parent().get_node("%Player")
@onready var main = get_parent()
var player_inv_res = load("res://resources/player_inv.tres")
var nearby_items_res = load("res://resources/nearby_items.tres")
var last_picked_slot_inventory
var last_picked_slot
var picked_item


func _input(event):
	if not event is InputEventMouseButton:
		return
	if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
		if not is_instance_valid(picked_item):
			return
		# Get closest slot
		var slot_list = []
		for i in $%InventoryGrid.get_children():
			slot_list.append(i)
		for i in $%NearbyItemsGrid.get_children():
			slot_list.append(i)
		var closest_slot = get_closest_slot(slot_list, Vector2(50,50))
		var existing_item
		var closest_slot_inventory
		# Assign existing_item and closest_slot_inventory
		if closest_slot in $%NearbyItemsGrid.get_children():
			existing_item = player.location.inventory.slots[closest_slot.get_index()].item
			closest_slot_inventory = player.location.inventory
		elif closest_slot in $%InventoryGrid.get_children():
			existing_item = player_inv_res.slots[closest_slot.get_index()].item
			closest_slot_inventory = player_inv_res
		# Handle swapping and dropping of items
		if existing_item: # Swap
			closest_slot_inventory.slots[closest_slot.get_index()].item = picked_item.resource
			picked_item.queue_free()
			last_picked_slot_inventory.slots[last_picked_slot.get_index()].item = existing_item
			last_picked_slot = null
			picked_item = null
		else: # Drop
			closest_slot_inventory.slots[closest_slot.get_index()].item = picked_item.resource
			picked_item.queue_free()
			last_picked_slot = null
			picked_item = null


func _item_dragged(item, slot):
	last_picked_slot = slot
	if slot.get_parent().name == "InventoryGrid":
		slot.get_parent().resource.slots[slot.get_index()].item = null
		last_picked_slot_inventory = slot.get_parent().resource
	else:
		# If dragged out of nearbyitems:
		player.location.inventory.slots[slot.get_index()].item = null
		last_picked_slot_inventory = player.location.inventory
	item.get_parent().remove_child(item)
	main.get_node("VirtualCursor").add_child(item)
	picked_item = item


func add_item(item, inventory):
	for slot in inventory.slots:
		if slot.item == null:
			slot.item = item
			break


func get_closest_slot(slot_list, slot_size):
	var dist = 99999
	var closest_slot
	var mouse_pos = get_global_mouse_position()
	for slot in slot_list:
		var pos = slot.global_position + (slot_size / 2)
		var new_dist = pos.distance_to(mouse_pos)
		if new_dist < dist:
			dist = new_dist
			closest_slot = slot
	return closest_slot


func clear_nearby_items():
	for slot in get_node("%NearbyItemsGrid").get_children():
		var item
		if slot.has_item():
			item = slot.get_child(0).get_child(0)
			item.get_parent().remove_child(item)


func populate_items_in_location(given_location):
	var slots = get_node("%NearbyItemsGrid").get_children()
	var empty_slots = []
	for slot in slots:
		if !slot.has_item():
			empty_slots.append(slot)
	for item in given_location.inventory.slots:
		pass


func update_inventories():
	var index = 0
	for slot in main.get_node("%InventoryGrid").get_children():
		if player_inv_res.slots[index].item == null:
			slot.remove_item_from_slot()
		else:
			if slot.has_item():
				slot.remove_item_from_slot()
			var new_item = load("res://scenes/Item.tscn").instantiate()
			new_item.resource = player_inv_res.slots[index].item
			slot.add_item(new_item)
		index += 1

	index = 0
	for slot in main.get_node("%NearbyItemsGrid").get_children():
		if player.location.inventory.slots[index].item == null:
			slot.remove_item_from_slot()
		else:
			if slot.has_item():
				slot.remove_item_from_slot()
			var new_item = load("res://scenes/Item.tscn").instantiate()
			new_item.resource = player.location.inventory.slots[index].item
			slot.add_item(new_item)
		index += 1
