extends Resource
class_name ItemData

@export var item_name : String
@export var texture : Texture2D
@export_enum("Equippable", "Consumable", "Buriable", "None") var type = "None"
@export_enum("Weapon", "AltWeapon", "Head", "Neck", "Chest", "Hands", "Legs", "Feet",
	"Ring", "Belt", "Back", "None") var equip_type = "None"
@export var bury_exp : int
