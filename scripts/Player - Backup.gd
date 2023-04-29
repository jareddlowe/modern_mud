extends Control

@onready var main = get_tree().get_root().get_child(0)
@onready var current_location = main.find_child("Village Square")
@onready var movement_label = main.get_node("%MovementLabel")
@onready var dest = current_location
@onready var final_dest = current_location
@onready var last_location = current_location
signal location_changed
var moving = false
var speed = 10
var description_sent = false
var dist_to_walk = 0
var ongoing = false
var path
var dist
var dir
var movement_mode = "stopped"
var going_back = false
var first_dest


func _ready():
	global_position = current_location.global_position
	for i in main.find_child("Locations").get_children():
		i.location_clicked.connect(_location_clicked)


func _location_clicked(clicked_location): # Sets dest
	dir = global_position.direction_to(dest.global_position)
	dist = global_position.distance_to(dest.global_position)
	if movement_mode == "stopped":
		movement_mode = "traveling"
		movement_label.playing = true
		final_dest = clicked_location
		path = find_path(current_location, clicked_location)
		if path.size() > 0:
			dest = path[0]
		else:
			dest = current_location
		first_dest = dest
		dist_to_walk = global_position.distance_to(dest.global_position)

	elif movement_mode == "traveling":
		# Determine if we clicked forward or back (dest or current_location)
		final_dest = clicked_location
		if clicked_location == current_location:
			dest = current_location
		elif clicked_location == first_dest:
			dest = first_dest
		else:
			path = find_path(current_location, final_dest)
			print("TRAVELING PATH " + str(path))
			if current_location != path[0]:
				print('Bing!')
				dest = dest




func _process(delta): # Sets current_location and handles movement
	dir = global_position.direction_to(dest.global_position)
	dist = global_position.distance_to(dest.global_position)
	if movement_mode == "traveling":
		if current_location != final_dest:
			if dist/dist_to_walk < 0.6 and dist/dist_to_walk > 0.5:
				if not description_sent:
					main.add_message("Yo!")
					description_sent = true
			if dist > 0.1 and dist < 5:
				global_position = global_position.lerp(dest.global_position, 0.1)
			elif dist <= 0.1:
				last_location = current_location
				current_location = dest
				movement_mode = "stopped"
				movement_label.playing = false
				description_sent = false
				first_dest = dest
				if current_location != final_dest:
					path = find_path(current_location, final_dest)
					if path.size() > 0:
						dest = path[0]
						movement_mode = "traveling"
						movement_label.playing = true
						dist_to_walk = global_position.distance_to(dest.global_position)
			elif dist > 5:
				global_position += dir * speed * delta
		else: # If current_location *IS* the final_dest
			if dist/dist_to_walk < 0.6 and dist/dist_to_walk > 0.5:
				if not description_sent:
					main.add_message("Yo!")
					description_sent = true
			if dist > 0.1 and dist < 5:
				global_position = global_position.lerp(dest.global_position, 0.1)
			elif dist <= 0.1:
				last_location = current_location
				current_location = dest
				movement_mode = "stopped"
				movement_label.playing = false
				description_sent = false
				first_dest = dest
			elif dist > 5:
				global_position += dir * speed * delta
			else:
				movement_mode = "stopped"
				movement_label.playing = false
				description_sent = false




func find_path(start, end):
	start.pathfinding_visited = true
	var queue = [start]
	var _path = []
	var curNode
	# While there are nodes in the queue,
	# check if the current node is the end node.
	# If not, mark any neighbors as visited,
	# set their parents as the current node,
	# and add the neighbors to the queue.
	while queue.size() > 0:
		var neighbors = []
		curNode = queue.pop_back()
		if curNode == end: # If we found the end node, we're done here.
			break
		for i in curNode.neighbors:
			if not i.pathfinding_visited:
				neighbors.append(i)
		for i in neighbors:
			i.pathfinding_visited = true
			i.pathfinding_parent = curNode
			queue.push_front(i)
	# Backtrack through the node's parents to create the path.
	while curNode.pathfinding_parent != null:
		_path.push_front(curNode)
		curNode = curNode.pathfinding_parent
	# Reset pathfinding variables.
	var locations = main.level.get_node("Locations")
	for location in locations.get_children():
		location.pathfinding_parent = null
		location.pathfinding_visited = false
	return _path
