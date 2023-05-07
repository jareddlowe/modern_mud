extends PanelContainer


@onready var scroll_cont = $%MessageScrollContainer
@onready var level = $%SubViewport/Villagetown
@onready var player = $%Player
@onready var current_panel = $%InventoryPanel
@onready var message_panel = $%MessagePanel
@onready var inventory_panel = $%InventoryPanel
@onready var nav_buttons = $%ButtonHBoxContainer
@onready var skills_panel = $%SkillsPanel
@onready var entity_panel_slots = $%EntityPanelHFlow
var combat_encounter # Active/current combat encounter
var message_panel_flash = false
var counter = 0
var previous_message
var rc_menu
var last_picked_slot
var picked_item
var no_interactables_mode = false


func _ready():
	DisplayServer.window_set_min_size(Vector2(886, 800))
	for i in nav_buttons.get_children():
		i.connect("menu_button_pressed", on_menu_button_pressed)
		nav_buttons.get_node("ItemsButton").connected_panel = inventory_panel
		nav_buttons.get_node("SkillsButton").connected_panel = skills_panel
	
	var sword = load("res://scenes/Item.tscn").instantiate()
	sword.item_resource = load("res://resources/Sword.tres")
	level.find_child("Village Square").items.append(sword)
	
	var sword2 = load("res://scenes/Item.tscn").instantiate()
	sword2.item_resource = load("res://resources/Sword.tres")
	player.inventory.append(sword2)
	
	
	for i in get_node("%InventoryGrid").get_children():
		i.connect("item_right_clicked", create_right_click_menu)
		i.connect("item_dragged", _item_dragged)
		i.connect("item_dropped", _item_dropped)
	
	for i in get_node("%NearbyItemsGrid").get_children():
		i.connect("item_right_clicked", create_right_click_menu)
		i.connect("item_dragged", _item_dragged)
		i.connect("item_dropped", _item_dropped)



func _process(delta):
	erase_right_click_menu_if_mouse_is_far_enough()
	if not no_interactables_mode and counter < 0.1:
		counter += 1 * delta
	elif not no_interactables_mode:
		update_interactables(player.current_location)
		populate_items_in_inventory()
		populate_items_in_location(player.current_location)
		counter = 0


func _input(event):
	var slot_list
	# Here we 'forget' to add the NearbyItemsGrid when player is moving,
	# to prevent the player from dropping items while moving between locations.
	if player.stopped:
		slot_list = get_node("%InventoryGrid").get_children()
		slot_list += get_node("%NearbyItemsGrid").get_children()
	else:
		slot_list = get_node("%InventoryGrid").get_children()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
	# Deposit any dragged item into the closest slot.
		if !picked_item or event.pressed:
			return
		var current_slot
		for slot in slot_list:
			if check_if_mouse_above(slot):
				current_slot = slot
		if current_slot == null:
			var closest_slot
			var last_dist = 10000
			for slot in slot_list:
				var dist
				var mouse_pos = get_global_mouse_position()
				dist = mouse_pos.distance_to(slot.global_position)
				if dist < last_dist:
					last_dist = dist
					closest_slot = slot
			if closest_slot.has_item():
				var old_item = closest_slot.get_item()
				old_item.get_parent().remove_child(old_item)
				last_picked_slot.add_item(old_item)
				if last_picked_slot in get_node("%NearbyItemsGrid").get_children():
					if old_item not in player.current_location.items:
						player.current_location.items.append(old_item)
				elif last_picked_slot in get_node("%InventoryGrid").get_children():
					if old_item not in player.inventory:
						player.inventory.append(old_item)
				$VirtualCursor.remove_child(picked_item)
				closest_slot.add_item(picked_item)
				if closest_slot in get_node("%NearbyItemsGrid").get_children():
					if picked_item not in player.current_location.items:
						player.current_location.items.append(picked_item)
				elif closest_slot in get_node("%InventoryGrid").get_children():
					if picked_item not in player.inventory:
						player.inventory.append(picked_item)
				picked_item.modulate.a = 1.0
			else:
				picked_item.get_parent().remove_child(picked_item)
				closest_slot.add_item(picked_item)
				if closest_slot in get_node("%NearbyItemsGrid").get_children():
					if picked_item not in player.current_location.items:
						player.current_location.items.append(picked_item)
				elif closest_slot in get_node("%InventoryGrid").get_children():
					if picked_item not in player.inventory:
						player.inventory.append(picked_item)
				picked_item.modulate.a = 1.0
			picked_item = null
		else:
			current_slot.emit_signal("item_dropped", current_slot)


func _item_dragged(item, slot):
	if not picked_item:
		item.get_parent().remove_child(item)
		# Here we check if item was dragged out of NearbyItemsGrid, because 
		# we must remove the item from the location's item list.
		if slot in get_node("%NearbyItemsGrid").get_children():
			player.current_location.items.erase(item)
		elif slot in get_node("%InventoryGrid").get_children():
			player.inventory.erase(item)
		$VirtualCursor.add_child(item)
		item.modulate.a = 0.2
		last_picked_slot = slot
		picked_item = item


func _item_dropped(slot):
	if picked_item:
		if !slot.has_item(): # Drop item
			$VirtualCursor.remove_child(picked_item)
			slot.add_item(picked_item)
			if slot in get_node("%NearbyItemsGrid").get_children():
				if picked_item not in player.current_location.items:
					player.current_location.items.append(picked_item)
			elif slot in get_node("%InventoryGrid").get_children():
				if picked_item not in player.inventory:
					player.inventory.append(picked_item)
			picked_item.modulate.a = 1
			picked_item = null
		else: # Swap items
			var slot_item = slot.get_item()
			slot_item.get_parent().remove_child(slot_item)
			last_picked_slot.add_item(slot_item)
			if last_picked_slot in get_node("%NearbyItemsGrid").get_children():
				if slot_item not in player.current_location.items:
					player.current_location.items.append(slot_item)
			elif last_picked_slot in get_node("%InventoryGrid").get_children():
				if slot_item not in player.inventory:
					player.inventory.append(slot_item)
			$VirtualCursor.remove_child(picked_item)
			slot.add_item(picked_item)
			if slot in get_node("%NearbyItemsGrid").get_children():
				if picked_item not in player.current_location.items:
					player.current_location.items.append(picked_item)
			if slot in get_node("%InventoryGrid").get_children():
				if picked_item not in player.inventory:
					player.inventory.append(picked_item)
			picked_item.modulate.a = 1
			picked_item = null


func add_message(text, sound=""):
	# Adds message to text box
	if previous_message:
		previous_message.modulate.a -= 0.35
	if sound == "click":
		$Clicker.pitch_scale = randf_range(2.5, 3.0)
		$Clicker.playing = true
	var new_label = load("res://scenes/Message.tscn").instantiate()
	new_label.text = text
	scroll_cont.get_node("VBoxContainer").add_child(new_label)
	message_panel.message_panel_flash = true
	previous_message = new_label


func on_menu_button_pressed(button):
	if button.connected_panel != null:
		current_panel.visible = false
		current_panel = button.connected_panel
		current_panel.visible = true


func update_interactables(given_location):
	var obj_list = []
	if given_location.get_child_count() > 0:
		for obj in given_location.get_children(false):
			if obj.get("type") == "npc" or obj.get("type") == "enemy":
				obj_list.append(obj)
	var interactable_list = []
	if entity_panel_slots.get_child_count() > 0:
		for interactable in entity_panel_slots.get_children():
			interactable_list.append(interactable)
	for interactable in interactable_list: # Clears object-less interactables.
		if not obj_list.has(interactable.associated_object):
			interactable.queue_free()
	for obj in obj_list:
		# If obj_list contains a interactable-less object, 
		# make an interactable for it.
		if not obj.associated_interactable:
			var new_interactable = load("res://scenes/Interactable.tscn").instantiate()
			obj.associated_interactable = new_interactable
			new_interactable.associated_object = obj
			new_interactable.type = obj.type
			new_interactable.get_node("Label").text = obj.obj_name
			entity_panel_slots.add_child(new_interactable)


func clear_interactables():
	for i in entity_panel_slots.get_children():
		i.queue_free()


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
	for item in given_location.items:
		if not is_instance_valid(item.get_parent()): # If item has no slot
			var slot = empty_slots.pop_front()
			slot.add_item(item)


func populate_items_in_inventory():
	var slots = get_node("%InventoryGrid").get_children()
	var empty_slots = []
	for slot in slots:
		if !slot.has_item():
			empty_slots.append(slot)
	for item in player.inventory:
		if is_instance_valid(item):
			if not is_instance_valid(item.get_parent()): # If item has no slot
				var slot = empty_slots.pop_front()
				slot.add_item(item)


func create_right_click_menu(_node):
	if rc_menu:
		rc_menu.queue_free()
		rc_menu = null
	rc_menu = load("res://scenes/RightClickMenu.tscn").instantiate()
	$VirtualCursor.add_child(rc_menu)
	rc_menu.global_position = get_global_mouse_position()


func erase_right_click_menu_if_mouse_is_far_enough():
	if rc_menu:
		var mouse_pos = get_global_mouse_position()
		var menu_pos = rc_menu.global_position
		var panel = rc_menu.get_node("PanelContainer")
		if mouse_pos.distance_to(menu_pos + panel.size / 2) > 70:
			rc_menu.queue_free()
			rc_menu = null


func check_if_mouse_above(i):
	# Todo: check if this panel is active
	var pos = get_global_mouse_position()
	if pos.x > i.global_position.x and pos.x < i.global_position.x + i.size.x:
		if pos.y > i.global_position.y and pos.y < i.global_position.y + i.size.y:
			return true
