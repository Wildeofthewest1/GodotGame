extends Area2D

@export var velocity: Vector2 = Vector2.ZERO
@export var lifetime: float = 3.0
@export var shooter: Node = null

func _ready():
	# Start lifetime countdown
	$LifetimeTimer.wait_time = lifetime
	$LifetimeTimer.timeout.connect(_on_lifetime_timeout)
	$LifetimeTimer.start()

	# Connect collision signal
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# Set sprite rotation to match velocity
	if velocity.length() > 0:
		rotation = velocity.angle()
	
func _physics_process(delta):
	position += velocity * delta

func _on_lifetime_timeout():
	queue_free()

func _on_body_entered(body: Node):
	if body == shooter:
		return
	queue_free()
	# Called when laser hits a physics body (player, planet, etc.)
	if body.is_in_group("player"):
		print("Hit player!")
		if body.has_method("take_hit"):
			body.take_hit()

		# You could call body.take_damage() here if implemented
	queue_free()

func _on_area_entered(area: Area2D):
	# Called if it hits another Area2D (like another laser or shield)
	print("Laser hit area:", area.name)
	queue_free()
