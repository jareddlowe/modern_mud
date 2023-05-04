extends TextureRect

@export var item_resource : Resource
var item_name : String

func update_item_from_resource():
	texture = item_resource.texture
	item_name = item_resource.item_name
