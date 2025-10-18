extends RigidBody2D

@export var radius: float = 50:
	set(value):
		radius = value
		_update_planet_shape_and_mass()

var spritewidth: float = 64.0
@export var density: float = 21.0  # tweak this for how "heavy" planets feel

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

	# --- Mass scales with radius² ---
	mass = density * pow(radius, 1)
