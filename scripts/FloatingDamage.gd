extends Node2D

@onready var label = $Label
var damage : int

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if label.text != str(damage):
		label.text = str(damage)
	position.y -= 20 * delta
	modulate.a -= 0.8 * delta
