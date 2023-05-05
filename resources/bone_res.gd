extends Item
class_name Bone

func _init():
	default_use = bury
	print('yeah!')

func bury():
	print("Buried bone!")
