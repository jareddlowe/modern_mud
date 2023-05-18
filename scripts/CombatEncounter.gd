extends HBoxContainer

@onready var main = get_tree().get_current_scene()
@onready var player = main.player
var enemy # Assigned by coder after instancing
var combat_ended = false
var winner : String

# This node handles combat. 
# It is meant to be instanced as child of the UI event panel itself.
# There is only meant to be one of these scenes "active" at a time.

func _ready():
	main.current_event = self # This ensures only one is active at a time.
	$PlayerAttackTimer.wait_time = player.attack_speed
	$EnemyAttackTimer.wait_time = enemy.attack_speed
	$PlayerBox/Label.text = player.name
	$EnemyBox/Label.text = enemy.obj_name


func _process(_delta):
	if combat_ended:
		return
	get_node("%PlayerProgressBar").value = (player.current_hp / player.max_hp) * 100.0
	get_node("%EnemyProgressBar").value = (enemy.current_hp / enemy.max_hp) * 100.0
	if player.current_hp <= 0:
		combat_ended = true
		winner = "Enemy"
		await get_tree().create_timer(2.0).timeout
		queue_free()
	elif enemy.current_hp <= 0:
		combat_ended = true
		winner = "Player"
		await get_tree().create_timer(1.0).timeout
		roll_for_item_drops(enemy)
		enemy.queue_free()
		queue_free()


func roll_for_item_drops(given_enemy):
	for item in given_enemy.drop_table:
		var r = randf_range(0.0000,1.0000)
		if r >= 0.0 and r <= given_enemy.drop_table[item]:
			var new_item = load("res://scenes/Item.tscn").instantiate()
			new_item.item_resource = load("res://resources/items/" + item + ".tres")
			#player.current_location.items.append(new_item)
			#main.populate_items_in_location(player.current_location)


func _on_enemy_attack_timer_timeout():
	if combat_ended:
		return
	var damage_max = (enemy.strength / 2)
	var damage = randi_range(0, damage_max)
	var pos = get_node("PlayerBox").global_position + (get_node("PlayerBox").get_rect().size / 2)
	var new_damage = load("res://scenes/FloatingDamage.tscn").instantiate()
	pos.y -= 35
	player.current_hp -= damage
	new_damage.damage = damage
	new_damage.global_position = pos
	main.add_child(new_damage)
	$EnemyAttackTimer.start()


func _on_player_attack_timer_timeout():
	if combat_ended:
		return
	var damage_max = (player.strength / 2)
	var damage = randi_range(0, damage_max)
	var pos = get_node("EnemyBox").global_position + (get_node("EnemyBox").get_rect().size / 2)
	var new_damage = load("res://scenes/FloatingDamage.tscn").instantiate()
	pos.y -= 35
	enemy.current_hp -= damage
	new_damage.damage = damage
	new_damage.global_position = pos
	main.add_child(new_damage)
	$PlayerAttackTimer.start()

