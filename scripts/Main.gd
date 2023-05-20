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
@onready var inv_manager = $InventoryManager
var current_event # Active/current combat encounter or chat
var message_panel_flash = false
var counter = 0
var previous_message
var rc_menu
var no_interactables_mode = false
var player_inv_res = load("res://resources/player_inv.tres")
var nearby_items_res = load("res://resources/nearby_items.tres")


func _ready():
	# Set window size.
	DisplayServer.window_set_min_size(Vector2(886, 800))
	# Connect signals.
	for i in nav_buttons.get_children():
		i.connect("menu_button_pressed", on_menu_button_pressed)
		nav_buttons.get_node("ItemsButton").connected_panel = inventory_panel
		nav_buttons.get_node("SkillsButton").connected_panel = skills_panel
	# Instantiate visual slot node for every slot in inventory resource.
	for slot in player_inv_res.slots:
		var new_slot = load("res://scenes/ItemSlot.tscn").instantiate()
		$%InventoryGrid.add_child(new_slot)
	# Instantiate visual slot node for every slot in nearby_items resource.
	for slot_data in nearby_items_res.slots:
		var new_slot = load("res://scenes/ItemSlot.tscn").instantiate()
		$%NearbyItemsGrid.add_child(new_slot)
		new_slot.modulate = Color(1.1, 1.1, 1.1)
	# Connect signals to InventoryManager visual slots.
	# We do it here to ensure slot data exists first.
	for i in get_node("%InventoryGrid").get_children():
		i.connect("item_dragged", inv_manager._item_dragged)
	for i in get_node("%NearbyItemsGrid").get_children():
		i.connect("item_dragged", inv_manager._item_dragged)
	# Add some example items to the inventory.
	var sword = load("res://resources/items/Sword.tres")
	var potion = load("res://resources/items/Potion.tres")
	inv_manager.add_item(sword, player_inv_res)
	inv_manager.add_item(potion, player_inv_res)


func _process(delta):
	if not no_interactables_mode and counter < 0.05:
		counter += 1 * delta
	elif not no_interactables_mode:
		update_interactables(player.location)
		inv_manager.update_inventories()
		#inv_manager.populate_items_in_location(player.location)
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


func check_if_mouse_above(i):
	var pos = get_global_mouse_position()
	if pos.x > i.global_position.x and pos.x < i.global_position.x + i.size.x:
		if pos.y > i.global_position.y and pos.y < i.global_position.y + i.size.y:
			return true
