extends TextureRect
class_name GameItem

@export var resource : ItemData
var item_name : String
var use_function : Callable
@onready var main = get_tree().get_current_scene()
@onready var inv_manager = main.get_node("InventoryManager")
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
				if get_parent().get_parent() in main.get_node("%InventoryGrid").get_children():
					use()
				elif get_parent().get_parent() in main.get_node("%NearbyItemsGrid").get_children():
					move_to_inventory(self)


func use():
	if type == "Buriable":
		#queue_free()
		#main.player_inv_res.slots
		pass


func move_to_inventory(item):
	var slot = item.get_parent().get_parent()
	main.player.location.inventory.slots[slot.get_index()].item = null
	#item.get_parent().remove_child(item)
	# first empty slot
	main.get_node("InventoryManager").add_item(item.resource, main.player.inventory)

