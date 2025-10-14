extends Area2D

@export var health := 1
@export var reward_amount := 10

func take_hit():
	health -= 1
	if health <= 0:
		die()

func die():
	print("Target destroyed at ", global_position)
	
	# Give player reward
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.add_currency(reward_amount)

	# Spawn explosion
	var explosion_scene = preload("res://scenes/explosion.tscn")
	var explosion = explosion_scene.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
	explosion.get_node("explosion").emitting = true

	queue_free()
