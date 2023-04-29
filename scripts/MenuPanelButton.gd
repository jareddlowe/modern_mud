@tool
extends Button

signal menu_button_pressed(button)
@export var button_name : String
var connected_panel
var counter = 0

func _ready():
	$Label.text = button_name

func _on_menu_panel_button_pressed():
	emit_signal("menu_button_pressed", self)

func _process(delta):
	if counter > 1:
		$Label.text = button_name
		counter = 0
	counter += delta
