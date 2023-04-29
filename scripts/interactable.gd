extends Button

var main
var type
var associated_object


func _ready():
	if type == "enemy":
		add_theme_stylebox_override("normal", 
			load("res://resources/interactable_normal_red.tres"))


func _on_interactable_pressed():
	if type == "enemy" and !main.combat_encounter:
		print("Starting combat!")
		var new_combat = load("res://scenes/combat_encounter.tscn").instantiate()
		new_combat.enemy = associated_object
		new_combat.player = main.player
		new_combat.main = main
		new_combat.enemy_interactable = self
		main.combat_encounter = new_combat
		main.get_node("%InteractPanelMargin").add_child(new_combat)
		await get_tree().create_timer(0.5).timeout
		new_combat.get_node("PlayerAttackTimer").stop()
		new_combat.get_node("PlayerAttackTimer").emit_signal("timeout")
