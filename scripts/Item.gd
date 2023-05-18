extends TextureRect
class_name GameItem

@export var item_resource : ItemData
var item_name : String
var use_function : Callable
@onready var main = get_tree().get_current_scene()
var type


func _ready():
	if item_resource:
		texture = item_resource.texture
		item_name = item_resource.item_name
		type = item_resource.type
	else:
		print("No item resource defined for " + item_name)


func _input(event):
	if event is InputEventMouseButton and !event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if main.check_if_mouse_above(self) and not main.picked_item:
				if get_parent().get_parent() in main.get_node("%InventoryGrid").get_children():
					use()
				elif get_parent().get_parent() in main.get_node("%NearbyItemsGrid").get_children():
					move_to_inventory(self)


func use():
	if type == "Buriable":
		queue_free()
		#main.player_inv_res.slots


func move_to_inventory(item):
	var slot = item.get_parent().get_parent()
	main.player.current_location.location_inv.slots[slot.get_index()].item = null
	#item.get_parent().remove_child(item)
	# first empty slot
	main.add_item_to_first_empty_slot(item.item_resource)

