extends Node2D

@export var target_scene: PackedScene
@export var max_targets: int = 5
@export var min_y: float = -50
@onready var camera := $"../Camera2D"

func _ready():
	# Initial spawn
	for i in range(max_targets):
		spawn_target()

func _process(_delta):
	# Keep the number of targets at max_targets
	if get_target_count() < max_targets:
		spawn_target()

func spawn_target():
	if not camera:
		return

	# Get camera extents in world coordinates
	var viewport_rect = get_viewport_rect()
	var screen_half_size = viewport_rect.size * 0.5 / camera.zoom

	var cam_pos = camera.global_position

	# Random position within camera view
	var x = randf_range(cam_pos.x - screen_half_size.x, cam_pos.x + screen_half_size.x)
	var y = randf_range(cam_pos.y - screen_half_size.y, cam_pos.y + screen_half_size.y)

	# Ensure target spawns above min_y
	y = min(y, min_y)

	var target = target_scene.instantiate()
	get_tree().current_scene.add_child(target)
	target.global_position = Vector2(x, y)

func get_target_count() -> int:
	var count = 0
	for child in get_tree().current_scene.get_children():
		if child.is_in_group("targets"):
			count += 1
	return count
