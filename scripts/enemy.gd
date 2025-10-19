extends CharacterBody2D

@export var move_speed: float = 200.0
@export var fire_interval: float = 5.0
@export var laser_speed: float = 800.0
@export var laser_scene: PackedScene
@export var max_health: int = 3
@export var detection_range: float = 600.0  # how close the player must be
@export var stop_distance: float = 200.0      # stop moving when this close to the player
@export var reward_amount: int = 1

var player: Node2D
var health: int
var player_in_range: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

signal enemy_died(enemy_position: Vector2)

func _ready():
	health = max_health
	player = get_tree().get_first_node_in_group("player")

	# Set up shoot timer
	$ShootTimer.wait_time = fire_interval
	$ShootTimer.timeout.connect(_on_shoot_timer_timeout)
	$ShootTimer.start()

func _physics_process(delta):
	if not player:
		return

	# --- Check distance to player ---
	var distance_to_player = global_position.distance_to(player.global_position)
	player_in_range = distance_to_player <= detection_range

	if player_in_range:

		# --- Rotate so the BOTTOM of the sprite faces the player ---
		look_at(player.global_position)
		rotation += PI / 2   # bottom of sprite is now "front"
		
		if distance_to_player > stop_distance:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * move_speed
			move_and_slide()
	else:
		# Stop moving if out of range
		velocity = Vector2.ZERO

func _on_shoot_timer_timeout():
	if not player:
		return
	if player_in_range:  # only shoot if player is close enough
		_shoot_laser()

func _shoot_laser():
	if not laser_scene:
		print("⚠️ Laser scene not assigned!")
		return

	var laser = laser_scene.instantiate()
	laser.global_position = global_position
	laser.rotation = rotation - PI / 2
	laser.shooter = self
	get_parent().add_child(laser)

	if "velocity" in laser:
		laser.velocity = Vector2.RIGHT.rotated(laser.rotation) * laser_speed
	
	flash_shoot_frame()

func flash_shoot_frame():
	sprite.frame = 1
	await get_tree().create_timer(1.0).timeout
	sprite.frame = 0

# =========================================================
# === Damage system (for being hit by player's laser) ===
# =========================================================
func take_hit():
	health -= 1
	print("Enemy took a hit! Health:", health)
	flash_damage()
	if health <= 0:
		die()

func flash_damage():
	var original_modulate = sprite.modulate
	sprite.modulate = Color("00ff88ff")
	await get_tree().create_timer(0.15).timeout
	sprite.modulate = original_modulate

func die():
	print("Enemy destroyed!")
	emit_signal("enemy_died", global_position)
	if player:
		player.add_currency(reward_amount)
	queue_free()
