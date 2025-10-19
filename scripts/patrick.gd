extends RigidBody2D

@export var gravitational_constant: float = 1

func _physics_process(delta: float) -> void:
	for planet in get_tree().get_nodes_in_group("planets"):
		var to_planet = planet.global_position - global_position
		var distance = to_planet.length()
		
		if distance > 0.0:
			var direction = to_planet.normalized()
			var force = gravitational_constant * planet.mass / (distance * distance)
			
			# Apply a continuous force toward the planet
			apply_central_force(direction * force)
