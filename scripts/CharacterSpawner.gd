extends Node

var type = "spawner"
var spawned_character
var template_character

# This node is set up to be an NPC spawnpoint that persists in the world.
# It is meant to be added as the child of a Location node.
# Any NPC node which is added as a child of this node will become the template.
# The template is spawned, and upon the character's death
# we respawn the character after a short timer delay.

func _ready():
	# If there is a template character node added as child of CharacterSpawner...
	if get_child_count() > 1: 
		template_character = get_child(1)
		spawned_character = template_character.duplicate()
		get_parent().add_child.call_deferred(spawned_character)


func _on_timer_timeout():
	if template_character:
		spawned_character = template_character.duplicate()
		get_parent().add_child(spawned_character)


func _process(_delta):
	if $Timer.is_stopped() and template_character and !spawned_character:
		$Timer.start()
