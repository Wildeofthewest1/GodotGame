extends CharacterBody2D

@export var max_speed: float = 600.0
@export var thrust_power: float = 1200.0
@export var drag: float = 1  # drag factor per frame, closer to 1 = less friction

var currency: int = 0
@onready var laser = $AnimatedSprite2D/Laser
@onready var anim := $AnimatedSprite2D

func add_currency(amount: int):
	currency += amount
	print("Currency:", currency)

@export var gravitational_constant: float = 2500

var tangent = Vector2.ZERO

@onready var tangent_line: Line2D = $TangentLine

func _physics_process(delta):
	var mouse_pos = get_global_mouse_position()
	var mouse_direction = (mouse_pos - global_position).normalized()

	# --- Rotation ---
	var target_angle = mouse_direction.angle() + PI / 2
	anim.rotation = lerp_angle(anim.rotation, target_angle, delta * 10)
	$AnimatedSprite2D.rotation = anim.rotation
	
	var is_thrusting = Input.is_action_pressed("activate_thrust")
	
	# --- Thrust ---
	if is_thrusting:  # assign this in Input Map
		var thrust = mouse_direction * thrust_power * delta
		velocity += thrust
		print(velocity.length())
		# Optional: cap max speed
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
	
	# --- Gravity from planets ---
	for planet in get_tree().get_nodes_in_group("planets"):
		var to_planet = planet.global_position - global_position
		var distance = to_planet.length()
		
		var planet_surface = planet.radius + 10.5  # a small buffer above the surface
		
		if distance > planet_surface:
			var direction = to_planet.normalized()
			var force = gravitational_constant * planet.mass / (distance * distance)
			velocity += direction * force * delta
			
		if distance < planet_surface and not is_thrusting:
			tangent = Vector2(-to_planet.y, to_planet.x)
			var tangent_component = velocity.project(tangent)
			velocity -= tangent_component * delta * 4
			
			update_tangent_line(tangent_component)
			
	# --- Apply drag (simulate space resistance or fine control) ---
	velocity *= drag
	
	# --- Animation and thruster visuals ---
	update_animation()
	$AnimatedSprite2D/Thruster.emitting = Input.is_action_pressed("activate_thrust")

	# --- Shooting ---
	if Input.is_action_just_pressed("fire_laser"):
		fire_laser()
	
	move_and_slide()
	
	_update_trajectory_line()
	

func update_tangent_line(dir: Vector2):
	# draw line relative to the ship
	tangent_line.clear_points()
	tangent_line.add_point(Vector2.ZERO)
	tangent_line.add_point(dir * 100)



@onready var trajectory_line: Line2D = $TrajectoryLine
@export var prediction_steps: int = 5000
@export var prediction_dt: float = 0.1  # seconds per step

func _update_trajectory_line():
	var points: Array[Vector2] = []
	var sim_pos = global_position
	var sim_vel = velocity

	# --- Get player collider radius ---
	var player_radius := 0.0
	if $CollisionShape2D.shape is CircleShape2D:
		player_radius = $CollisionShape2D.shape.radius

	var hit = false

	for i in range(prediction_steps):
		var prev_pos = sim_pos

		# --- Apply gravity from all planets ---
		for planet in get_tree().get_nodes_in_group("planets"):
			var to_planet = planet.global_position - sim_pos
			var distance = to_planet.length()
			if distance == 0:
				continue
			var direction = to_planet / distance
			var force = gravitational_constant * planet.mass / (distance * distance)
			sim_vel += direction * force * prediction_dt

		# --- Apply drag ---
		sim_vel *= pow(drag, prediction_dt / get_physics_process_delta_time())

		# --- Move the simulated position ---
		sim_pos += sim_vel * prediction_dt

		# --- Check for collision with any planet ---
		for planet in get_tree().get_nodes_in_group("planets"):
			var to_planet = planet.global_position - sim_pos
			var distance = to_planet.length()
			var combined_radius = planet.radius + player_radius

			if distance < combined_radius:
				# The path between prev_pos and sim_pos crosses the surface.
				# We'll find the exact intersection point along that segment.
				var from_planet_prev = prev_pos - planet.global_position
				var from_planet_curr = sim_pos - planet.global_position

				# Solve for t where the line between prev and curr hits the surface radius.
				var prev_dist = from_planet_prev.length()
				var curr_dist = from_planet_curr.length()
				var t = (prev_dist - combined_radius) / (prev_dist - curr_dist)
				t = clamp(t, 0.0, 1.0)

				var surface_point = prev_pos.lerp(sim_pos, t)
				points.append(surface_point - global_position)

				hit = true
				break

		points.append(sim_pos - global_position)
		if hit:
			break

	# --- Draw the trajectory ---
	trajectory_line.clear_points()
	for p in points:
		trajectory_line.add_point(p)








func update_animation():
	var move_speed = velocity.length()
	if move_speed > 0.1:
		anim.speed_scale = lerp(0.5, 20.0, move_speed / max_speed)
		if not anim.is_playing():
			anim.play()
	else:
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
