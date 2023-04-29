extends CharacterBody2D

var inventory : Array

func _input(event):
	if Input.is_action_just_pressed("right"):
		velocity.x += 100
	
func _physics_process(delta):
	velocity = velocity.lerp(Vector2.ZERO, 0.1)
	if velocity.length() >= 300:
		velocity = velocity.normalized() * 300
	
	move_and_slide()
