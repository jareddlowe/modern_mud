extends TextureRect
class_name GameItem

@export var resource : ItemData
@onready var main = get_tree().get_current_scene()
@onready var inv_manager = main.get_node("InventoryManager")
@onready var slot = get_parent().get_parent()
var item_name : String
var use_function : Callable
var type


func _ready():
	print('Item created!')
	if resource:
		texture = resource.texture
		item_name = resource.item_name
		type = resource.type
	else:
		print("No item resource defined for " + name)


func _input(event):
	if event is InputEventMouseButton and !event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if main.check_if_mouse_above(self) and not inv_manager.picked_item:
				if slot in main.get_node("%InventoryGrid").get_children():
					use()
				elif slot in main.get_node("%NearbyItemsGrid").get_children():
					move_to_inventory()
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if main.check_if_mouse_above(self) and not inv_manager.picked_item:
				if is_instance_valid(main.rc_menu):
					main.rc_menu.queue_free()
				# Instantiate a new right click menu
				var new_menu = load("res://scenes/RightClickMenu.tscn").instantiate()
				main.rc_menu = new_menu
				new_menu.global_position = get_global_mouse_position()
				main.add_child(new_menu)
				if slot in main.get_node("%InventoryGrid").get_children():
					# Add a drop button and connect its pressed signal to our drop function 
					var new_button = load("res://scenes/RightClickMenuButton.tscn").instantiate()
					new_button.text = "Drop"
					new_button.pressed.connect(drop)
					new_menu.get_node("PanelContainer/VBoxContainer").add_child(new_button)
					
				if slot in main.get_node("%NearbyItemsGrid").get_children():
					# Add a take button and connect its pressed signal to our take function
					var new_button = load("res://scenes/RightClickMenuButton.tscn").instantiate()
					new_button.text = "Take"
					new_button.pressed.connect(take)
					new_menu.get_node("PanelContainer/VBoxContainer").add_child(new_button)
					
				# Add a cancel button
				var new_button = load("res://scenes/RightClickMenuButton.tscn").instantiate()
				new_button.text = "Cancel"
				new_button.pressed.connect(cancel)
				new_menu.get_node("PanelContainer/VBoxContainer").add_child(new_button)


func use():
	if type == "Buriable":
		main.player.inventory.slots[slot.get_index()].item = null


func drop():
	if main.rc_menu:
		main.rc_menu.queue_free()
	inv_manager.add_item(resource, main.player.location.inventory)
	main.player.inventory.slots[slot.get_index()].item = null


func take():
	if main.rc_menu:
		main.rc_menu.queue_free()
	move_to_inventory()


func move_to_inventory():
	var item = main.player.location.inventory.slots[slot.get_index()].item
	main.player.location.inventory.slots[slot.get_index()].item = null
	inv_manager.add_item(item, main.player.inventory)


func cancel():
	if main.rc_menu:
		main.rc_menu.queue_free()
