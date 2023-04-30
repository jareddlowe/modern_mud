extends HBoxContainer

@onready var main = get_tree().get_current_scene()
var player # Assigned by coder after instancing
var enemy # Assigned by coder after instancing
var combat_ended = false
var winner : String


func _ready():
	$PlayerAttackTimer.wait_time = player.attack_speed
	$EnemyAttackTimer.wait_time = enemy.attack_speed
	$PlayerBox/Label.text = player.name
	$EnemyBox/Label.text = enemy.obj_name


func _process(delta):
	if combat_ended:
		return
	get_node("%PlayerProgressBar").value = (player.current_hp / player.max_hp) * 100.0
	get_node("%EnemyProgressBar").value = (enemy.current_hp / enemy.max_hp) * 100.0
	if player.current_hp <= 0:
		print("Player dead!")
		combat_ended = true
		winner = "Enemy"
		await get_tree().create_timer(2.0).timeout
		queue_free()
		print("Game over.")
	elif enemy.current_hp <= 0:
		print("Enemy dead!")
		combat_ended = true
		winner = "Player"
		# Drop enemy items
		await get_tree().create_timer(1.0).timeout
		enemy.queue_free()
		queue_free()


func _on_enemy_attack_timer_timeout():
	if combat_ended:
		return
	print("Enemy attacks!")
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
	print("Player attacks!")
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

