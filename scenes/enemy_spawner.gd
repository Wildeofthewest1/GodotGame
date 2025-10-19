extends Node2D

@export var enemy_scene: PackedScene
@export var respawn_position: Vector2 = Vector2(1000, 0) # Where to spawn the new enemy
@export var spawn_delay: float = 2.0 # Optional delay before spawning

func _ready():
	# Spawn the first enemy manually
	spawn_enemy(Vector2(200, 0)) # Initial spawn location

func spawn_enemy(spawn_pos: Vector2):
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_pos
	add_child(enemy)

	# Connect to the death signal so we can spawn again when it dies
	enemy.enemy_died.connect(_on_enemy_died)

func _on_enemy_died(pos: Vector2):
	print("Enemy died at:", pos)

	# Optional delay before respawning
	await get_tree().create_timer(spawn_delay).timeout

	# Spawn a new one at a specific location
	spawn_enemy(respawn_position)
