extends TextureRect
class_name GameItem

@export var resource : ItemData
@onready var main = get_tree().get_current_scene()
@onready var inv_manager = main.get_node("InventoryManager")
@onready var slot = get_parent().get_parent()
var item_name : String
var use_function : Callable
var type

# Item is being deleted and recreated every frame

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
					move_to_inventory(self)
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if main.check_if_mouse_above(self) and not inv_manager.picked_item:
				if slot in main.get_node("%InventoryGrid").get_children():
					if is_instance_valid(main.rc_menu):
						main.rc_menu.queue_free()
					# Instantiate a new right click menu
					var new_menu = load("res://scenes/RightClickMenu.tscn").instantiate()
					main.rc_menu = new_menu
					new_menu.global_position = get_global_mouse_position()
					main.add_child(new_menu)
					# Add a drop button and give drop function to it
					var new_button = load("res://scenes/RightClickMenuButton.tscn").instantiate()
					new_button.text = "Drop"
					new_button.button_down.connect(_drop)
					new_menu.get_node("PanelContainer/VBoxContainer").add_child(new_button)
					

func use():
	if type == "Buriable":
		main.player.inventory.slots[slot.get_index()].item = null


func _drop():
	print('ye')
	if main.rc_menu:
		main.rc_menu.queue_free()
	inv_manager.add_item(resource, main.player.location.inventory)
	main.player.inventory.slots[slot.get_index()].item = null
	


func move_to_inventory(item):
	var to_slot = item.slot
	main.player.location.inventory.slots[to_slot.get_index()].item = null
	#item.get_parent().remove_child(item)
	# first empty slot
	main.get_node("InventoryManager").add_item(item.resource, main.player.inventory)

