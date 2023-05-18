@tool
extends Control
@export var neighbors = []
signal location_clicked(location)
var show_labels = true
var pathfinding_visited = false
var pathfinding_parent
var interactables
var description = "The next area comes into view."
var inventory # Generated in _ready()


func _ready():
	if show_labels:
		$Label.visible = true
		$Label.text = self.name
	
	inventory = InvData.new()
	for i in range(0,20):
		inventory.slots.append(SlotData.new())
	

func _process(_delta):
	if check_for_mouse(20):
		$ColorRect.color = Color(0.59, 0.61, 0.61)
	else:
		$ColorRect.color = Color(1, 1, 1)


func check_for_mouse(radius):
	var mouse_pos = get_global_mouse_position()
	if mouse_pos.distance_to(position) < radius:
		return true


func _input(event):
	if event.is_action_released("left_click"):
		if check_for_mouse(20):
			emit_signal("location_clicked", self)
