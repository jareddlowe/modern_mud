extends Node2D

var camera_smoothing = 10  # Lower means slower panning.
var camera_dest
@onready var player = get_tree().get_root().get_child(0).get_node("%Player")


func _ready():
	camera_dest = player
	$Camera2D.global_position = player.global_position

	for i in $Locations.get_children():
		if i.name == "Village Square":
			i.neighbors = [
				$"Locations/Shops",
				$"Locations/Woods",
				$"Locations/Goblin Camp",
				$"Locations/Swamps"]
		elif i.name == "Shops":
			i.neighbors = [
				$"Locations/Village Square",
				$"Locations/Mill",
				$"Locations/Farm"]
		elif i.name == "Mill":
			i.neighbors = [
				$"Locations/Shops",
				$"Locations/Woods"]
		elif i.name == "Woods":
			i.neighbors = [
				$"Locations/Mill",
				$"Locations/Village Square",
				$"Locations/Tower"]
		elif i.name == "Goblin Camp":
			i.neighbors = [
				$"Locations/Farm",
				$"Locations/Village Square",
				$"Locations/Gate"]
		elif i.name == "Farm":
			i.neighbors = [
				$"Locations/Goblin Camp",
				$"Locations/Shops"]
		elif i.name == "Swamps":
			i.neighbors = [
				$"Locations/Village Square",
				$"Locations/Tower"]
		elif i.name == "Tower":
			i.neighbors = [
				$"Locations/Swamps",
				$"Locations/Woods"]
		elif i.name == "Gate":
			i.neighbors = [
				$"Locations/Goblin Camp"]

	draw_lines()
	await get_tree().create_timer(0.5).timeout
	owner.add_message("You arrive in the world.", "click")
	await get_tree().create_timer(3).timeout
	owner.add_message("Click locations on the [color=#fffaa9]map[/color] " \
		+ "to travel! This will change your surroundings. ", "click")



func _physics_process(_delta):
	$Camera2D.global_position = camera_dest.global_position


func draw_lines():
	for location in $Locations.get_children():
		var to_connect = []
		# Construct list of nodes (to_connect) from list of nodepaths.
		for neighbor in location.neighbors:
			to_connect.append(neighbor)
		# Create line and append this location to "connected_to_by" list.
		for neighbor in to_connect:
			var line = Line2D.new()
			line.add_point(location.global_position)
			line.add_point(neighbor.global_position)
			line.width = 1.5
			$Lines.add_child(line)
