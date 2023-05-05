extends TextureRect

@export var item_resource : Resource
var item_name : String
var use_function : Callable


func update_item_from_resource():
	texture = item_resource.texture
	item_name = item_resource.item_name
	use_function = item_resource.default_use


func use():
	if use_function:
		use_function.call()


func _input(event):
	if event is InputEventMouseButton and !event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			use()
