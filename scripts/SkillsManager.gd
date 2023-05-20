extends Node

func update_skills():
	var skills = get_children()
	for skill in skills:
		skill.handle_level_up()

func _ready():
	await get_tree().create_timer(1.0).timeout
	update_skills()

