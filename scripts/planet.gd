extends RigidBody2D

@export var radius: float = 50:
	set(value):
		radius = value
		_update_planet_shape_and_mass()

var spritewidth: float = 64.0
@export var density: float = 21.0  # tweak this for how "heavy" planets feel
@export var gravitational_constant: float = 100

func _ready():
	add_to_group("planets")
	_update_planet_shape_and_mass()

	# Prevent unwanted spinning
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = false

func _update_planet_shape_and_mass():
	# --- Collision shape ---
	var shape := CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape

	# --- Visual size ---
	if $AnimatedSprite2D:
		$AnimatedSprite2D.scale = Vector2.ONE * (2.0 * radius / spritewidth)

	# --- Mass scales with radius² (2D gravity) ---
	mass = density * pow(radius, 2)


func _physics_process(delta):
	_apply_gravity_to_other_planets(delta)


func _apply_gravity_to_other_planets(delta):
	for other in get_tree().get_nodes_in_group("planets"):
		if other == self:
			continue

		var to_other = other.global_position - global_position
		var distance = to_other.length()
		if distance == 0:
			continue

		# Direction of attraction
		var direction = to_other / distance

		# Newton’s law of gravitation
		var force = gravitational_constant * (mass * other.mass) / pow(distance, 2)

		# Apply equal and opposite impulses
		var impulse = direction * force

		# Apply to both bodies
		apply_central_force(impulse)
