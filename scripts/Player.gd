extends Control

@onready var main = get_tree().get_current_scene()
@onready var location = main.find_child("Goblin Camp")
@onready var movement_label = main.get_node("%MovementLabel")
@onready var dest = location
@onready var final_dest = location
@onready var inv_manager = main.get_node("InventoryManager")
signal location_changed
var speed = 100
var description_sent = false
var dist_to_walk = 0
var path
var dist
var dir
var first_dest
var original_dest
var original_dist
var stopped = true
var attack_speed = 2.0
var current_hp = 10.0
var max_hp = 10.0
var strength = 10
var inventory = load("res://resources/player_inv.tres")


func _ready():
	global_position = location.global_position
	for i in main.find_child("Locations").get_children():
		i.location_clicked.connect(_location_clicked)


func create_phantom():
	# Plan: break the connection between location and dest,
	# then insert a temporary "phantom" location between them.
	# This way we can pathfind properly even when between locations.
	var phantom = load("res://scenes/Location.tscn").instantiate()
	phantom.global_position = global_position
	# Using original_dest allows us to go back and forth multiple times.
	# If we used dest, it would become location when backtracking,
	# which breaks the logic because it is added to the neighbors list twice.
	phantom.neighbors = [location, original_dest]
	# Break the connection between the two locations.
	location.neighbors.erase(dest)
	dest.neighbors.erase(location)
	# Insert phantom.
	location.neighbors.push_front(phantom)
	dest.neighbors.push_front(phantom)
	first_dest = dest
	return phantom


func delete_phantom(phantom):
	location.neighbors.erase(phantom)
	first_dest.neighbors.erase(phantom)
	location.neighbors.push_front(first_dest)
	first_dest.neighbors.push_front(location)
	phantom.queue_free()


func _location_clicked(clicked_location): # Sets dest.
	final_dest = clicked_location
	main.no_interactables_mode = true
	# If player is in combat... check here...
	if dist > 0.5: # If player is between two locations...
		var phantom = create_phantom()
		path = find_path(phantom, final_dest)
		if path:
			dest = path[0]
			stopped = false
			movement_label.playing = true
		delete_phantom(phantom)
	else: # If player is at a location...
		path = find_path(location, final_dest)
		if path:
			dest = path[0]
			stopped = false
			movement_label.playing = true
			# We set original_dest here,
			# and in _process when player auto-moves.
			original_dest = dest
			original_dist = global_position.distance_to(dest.global_position)
			main.clear_interactables()
			inv_manager.clear_nearby_items()
			main.get_node("%DisabledVisual").visible = true
		dist_to_walk = global_position.distance_to(dest.global_position)
		description_sent = false
	if is_instance_valid(main.current_event):
		main.current_event.combat_ended = true
		main.current_event.queue_free()


func _process(delta): # Sets location and handles movement.
	dir = global_position.direction_to(dest.global_position)
	dist = global_position.distance_to(dest.global_position)
	if not stopped:
		if dist > 0.5 and dist < 5:
			# 0.05 high speed, 0.005 low speed
			global_position = global_position.lerp(dest.global_position, 0.05) 
		elif dist < 0.5: # Stop, Resetting one-shot variables
			update_location()
			if location != final_dest:
				auto_move()
			else: # Final stop
				inv_manager.populate_items_in_location(dest)
				main.get_node("%DisabledVisual").visible = false
				main.no_interactables_mode = false
		elif dist > 5:
			global_position += dir * speed * delta


func auto_move():
	print("Automoving...")
	path = find_path(location, final_dest)
	if path:
		dest = path[0]
		stopped = false
		movement_label.playing = true
		original_dest = dest
		original_dist = global_position.distance_to(dest.global_position)
		dist_to_walk = global_position.distance_to(dest.global_position)
		description_sent = false
		main.get_node("%DisabledVisual").visible = true
		main.clear_nearby_items()


func update_location():
	location = dest
	description_sent = false
	stopped = true
	movement_label.playing = false


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
	for loc in locations.get_children():
		loc.pathfinding_parent = null
		loc.pathfinding_visited = false
	return _path
