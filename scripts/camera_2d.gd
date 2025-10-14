# Camera2D.gd
extends Camera2D

@export var follow_speed: float = 5.0
@onready var player = $"../Player"

@export var zoom_speed := 0.1
@export var min_zoom := 0.2
@export var max_zoom := 10.0

func _process(delta):
	# --- Follow player smoothly ---
	if player:
		global_position = global_position.lerp(player.global_position, delta * follow_speed)

	# --- Zoom controls ---
	if Input.is_action_pressed("zoom_out"):
		zoom -= Vector2(zoom_speed, zoom_speed)
	if Input.is_action_pressed("zoom_in"):
		zoom += Vector2(zoom_speed, zoom_speed)

	# Clamp each component separately
	zoom.x = clamp(zoom.x, min_zoom, max_zoom)
	zoom.y = clamp(zoom.y, min_zoom, max_zoom)
