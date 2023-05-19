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
	if resource:
		texture = resource.texture
		item_name = resource.item_name
		type = resource.type
	else:
		print("No item resource defined for " + item_name)


func _input(event):
	if event is InputEventMouseButton and !event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if main.check_if_mouse_above(self) and not inv_manager.picked_item:
				if slot in main.get_node("%InventoryGrid").get_children():
					use()
				elif slot in main.get_node("%NearbyItemsGrid").get_children():
					move_to_inventory(self)


func use():
	if type == "Buriable":
		main.player.inventory.slots[slot.get_index()].item = null


func move_to_inventory(item):
	var slot = item.slot
	main.player.location.inventory.slots[slot.get_index()].item = null
	#item.get_parent().remove_child(item)
	# first empty slot
	main.get_node("InventoryManager").add_item(item.resource, main.player.inventory)

