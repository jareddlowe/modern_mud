extends Control

@onready var player = get_parent().get_node("%Player")
@onready var main = get_parent()
var nearby_items_res = load("res://resources/nearby_items.tres")
var last_picked_slot_inventory
var last_picked_slot
var picked_item

# How the inventory system works:
# The player node has an inventory variable, which is assigned an inventory resource. 
# (player_inv_res.tres) This is an array of slot resources, which contain item resources.
# To access the player's inventory items, use player.inventory.slots[slot_index].item
# We can set these slots to different resources to change the items in the inventory.
# To access the item resource of a visual item node, use slot.get_item().resource,
# slot being a slot.tscn child of the visual inventory grid. ($%InventoryGrid)


func _process(_delta):
	erase_right_click_menu_if_mouse_is_far_enough()


func _input(event):
	# Handle dropping of items into closest slot
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
			existing_item = player.inventory.slots[closest_slot.get_index()].item
			closest_slot_inventory = player.inventory
		# Handle swapping and dropping of items
		if existing_item: # Swap
			print("Swapping")
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
		# Item will be taken upon swapping unless we set input as handled.
		get_viewport().set_input_as_handled()


func _item_dragged(item, slot):
	last_picked_slot = slot
	if slot.get_parent().name == "InventoryGrid":
		slot.get_parent().resource.slots[slot.get_index()].item = null
		last_picked_slot_inventory = player.inventory
	else:
		# If dragged out of nearby items grid:
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


func update_inventories():
	# Update inventory grid.
	for slot in main.get_node("%InventoryGrid").get_children(): # For each visual slot...
		if slot.has_item(): # If the slot has an item...
			# Check if the real inventory has an item in that slot...
			if player.inventory.slots[slot.get_index()].item:
				# If it does, check if the visual item is the same as the real item...
				if player.inventory.slots[slot.get_index()].item != slot.get_item().resource:
					# If it isn't, replace it with the proper visual item.
					slot.remove_item_from_slot()
					var new_item = load("res://scenes/Item.tscn").instantiate()
					new_item.resource = player.inventory.slots[slot.get_index()].item
					slot.add_item(new_item)
			else: # If it doesn't, remove the visual item.
				slot.remove_item_from_slot()
		else: # If the slot has no item... 
			# Check if the real inventory has an item in that slot...
			if player.inventory.slots[slot.get_index()].item != null:
				# If it does, add a new visual item to the slot.
				var new_item = load("res://scenes/Item.tscn").instantiate()
				new_item.resource = player.inventory.slots[slot.get_index()].item
				slot.add_item(new_item)
	
	# Update nearby items grid.
	for slot in main.get_node("%NearbyItemsGrid").get_children():
		if slot.has_item():
			if player.location.inventory.slots[slot.get_index()].item:
				if player.location.inventory.slots[slot.get_index()].item != slot.get_item().resource:
					slot.remove_item_from_slot()
					var new_item = load("res://scenes/Item.tscn").instantiate()
					new_item.resource = player.location.inventory.slots[slot.get_index()].item
					slot.add_item(new_item)
			else:
				slot.remove_item_from_slot()
		else:
			if player.location.inventory.slots[slot.get_index()].item != null:
				var new_item = load("res://scenes/Item.tscn").instantiate()
				new_item.resource = player.location.inventory.slots[slot.get_index()].item
				slot.add_item(new_item)


func erase_right_click_menu_if_mouse_is_far_enough():
	if is_instance_valid(main.rc_menu):
		var mouse_pos = get_global_mouse_position()
		var menu_pos = main.rc_menu.global_position
		var panel = main.rc_menu.get_node("PanelContainer")
		if mouse_pos.distance_to(menu_pos + panel.size / 2) > 70:
			main.rc_menu.queue_free()
			main.rc_menu = null
