extends CharacterBody2D

@export var max_speed: float = 400.0
@export var stop_distance: float = 20.0
var currency: int = 0
@onready var laser = $AnimatedSprite2D/Laser

@onready var anim := $AnimatedSprite2D

var mouse_over := false

func add_currency(amount: int):
	currency += amount
	print("Currency:", currency)

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	var mouse_pos = get_global_mouse_position()
	var distance = global_position.distance_to(mouse_pos)
	
	if mouse_over:
		velocity = Vector2.ZERO
	else:
		if distance > stop_distance:
			var direction = (mouse_pos - global_position).normalized()

			# Scale speed based on distance
			var t = clampf(distance / 200.0, 0.0, 1.0)  # adjust 300 for sensitivity
			var current_speed = lerpf(0.0, max_speed, t)

			velocity = direction * current_speed
		else:
			velocity = Vector2.ZERO

	move_and_slide()

	# --- Rotation ---
	if velocity.length() > 0.1:
		var target_angle = velocity.angle() + PI / 2
		anim.rotation = lerp_angle(anim.rotation, target_angle, delta * 10)

	update_animation()

	# Rotate sprite to face movement direction
	if velocity.length() > 0.1:
		var target_angle = velocity.angle() + PI / 2
		$AnimatedSprite2D.rotation = lerp_angle($AnimatedSprite2D.rotation, target_angle, delta * 10)

	if Input.is_action_just_pressed("fire_laser"):
		fire_laser()

	# --- Rotation section ---
	if input_vector != Vector2.ZERO:
		
		var target_angle = input_vector.angle() + PI / 2
		$AnimatedSprite2D.rotation = lerp_angle($AnimatedSprite2D.rotation, target_angle, delta * 10)

# Check if player is moving
	var is_moving = velocity.length() > 0.1

# Enable or disable the thruster emission
	$AnimatedSprite2D/Thruster.emitting = is_moving
	
	# --- Animation Speed Control ---
	update_animation()

# --- Animation behaviour based on movement ---
func update_animation():
	var move_speed = velocity.length()

	if move_speed > 0.1:
		# Scale animation speed based on velocity
		anim.speed_scale = lerp(0.5, 20.0, move_speed / max_speed)  # min 0.5x to max 2x
		if not anim.is_playing():
			anim.play()
	else:
		# Pause animation and keep current frame
		anim.pause()

func fire_laser():
	# Update raycast direction (so it follows rotation)
	var direction = Vector2(0, -300)

	# Force update the RayCast2D
	laser.target_position = direction
	laser.force_raycast_update()

	var hit_position: Vector2
	if laser.is_colliding():
		hit_position = laser.get_collision_point()
		spawn_explosion(hit_position)
		
		var collider = laser.get_collider()
		if collider and collider.has_method("take_hit"):
			collider.take_hit()
		
		print("Hit:")
	else:
		print("No hit")
		direction = Vector2(0, -300).rotated($AnimatedSprite2D.rotation)

		hit_position = laser.global_position + direction

	# Spawn the beam effect in world space
	spawn_laser_effect(laser.global_position, hit_position)

func spawn_laser_effect(start_pos: Vector2, end_pos: Vector2):
	var laser_effect_scene = preload("res://scenes/laser_effect.tscn")
	var beam = laser_effect_scene.instantiate()
	get_tree().current_scene.add_child(beam)
	beam.global_position = start_pos
	beam.get_node("Line2D").clear_points()
	beam.get_node("Line2D").add_point(Vector2.ZERO)
	beam.get_node("Line2D").add_point(end_pos - start_pos)

func spawn_explosion(position: Vector2):
	var explosion_scene = preload("res://scenes/explosion.tscn")
	var explosion = explosion_scene.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = position

	# If the particles are one-shot, trigger them manually
	var particles = explosion.get_node("explosion")
	particles.emitting = true

func _on_hover_area_mouse_entered() -> void:
	mouse_over = true

func _on_hover_area_mouse_exited() -> void:
	mouse_over = false
