extends Node2D

# preload your planet scene
const PlanetScene = preload("res://scenes/Planet.tscn")

# dictionary describing the planets
var planet_data = {
	"planet_a": {
		"radius": 60.0,
		"position": Vector2(0, 0),
		"velocity": Vector2(0, 0)
	},
	"planet_b": {
		"radius": 30.0,
		"position": Vector2(400, 0),
		"velocity": Vector2(0, 60)
	},
	"planet_c": {
		"radius": 45.0,
		"position": Vector2(-600, 0),
		"velocity": Vector2(0, -50)
	}
}

func _ready():
	_spawn_planets()

func _spawn_planets():
	for name in planet_data.keys():
		var info = planet_data[name]
		var planet = PlanetScene.instantiate()

		# set planet properties
		planet.radius = info.radius
		planet.global_position = info.position
		planet.linear_velocity = info.velocity  # initial orbit speed
		
		# optional: customise sprite
		# planet.$AnimatedSprite2D.texture = load(info.sprite_path)

		add_child(planet)
