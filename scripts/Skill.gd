extends Node

@onready var main = get_tree().get_root().get_child(0)

var skill_name = "Skill"
var experience = 2000
var level = 1
var experience_needed = 100

# Determine and update level based on experience value
func handle_level_up():
	var new_level = int(experience / experience_needed) + 1
	while new_level > level:
		level += 1
		main.add_message(skill_name + " level up! Level " + str(level) + " reached!")
		experience_needed = experience_needed * 1.5
		new_level = int(experience / experience_needed) + 1
