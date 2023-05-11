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
var current_event # Active/current combat encounter or chat
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


func _process(delta):
	#erase_right_click_menu_if_mouse_is_far_enough()
	if not no_interactables_mode and counter < 0.1:
		counter += 1 * delta
	elif not no_interactables_mode:
		update_interactables(player.current_location)
		#populate_items_in_inventory()
		populate_items_in_location(player.current_location)
		counter = 0


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
