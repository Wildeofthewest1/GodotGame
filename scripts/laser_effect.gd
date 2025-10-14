extends Node2D

@onready var line := $Line2D

func _ready():
	# Start fully visible
	line.modulate.a = 1.0

	# Fade out over time, then delete
	var tween = create_tween()
	tween.tween_property(line, "modulate:a", 0.0, 0.2)  # fade-out over 0.2 seconds
	await tween.finished
	queue_free()
