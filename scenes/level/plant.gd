extends StaticBody2D

var grid_pos: Vector2i
var age: float
var max_age: int
var grow_speed: float
const plant_data = {
	Global.Seeds.CORN: {
		"texture": preload("res://graphics/plants/corn.png"),
		"max age": 3,
		"grow speed": 0.5,
	},
	Global.Seeds.TOMATO: {
		"texture": preload("res://graphics/plants/tomatoes.png"),
		"max age": 3,
		"grow speed": 0.5,
	},
	Global.Seeds.PUMPKIN: {
		"texture": preload("res://graphics/plants/pumpkin.png"),
		"max age": 3,
		"grow speed": 0.4,
	},
}


func setup(seed_enum: Global.Seeds, grid_position: Vector2i):
	$Sprite2D.texture = plant_data[seed_enum]["texture"]
	max_age = plant_data[seed_enum]["max age"]
	grow_speed = plant_data[seed_enum]["grow speed"]
	grid_pos = grid_position


func grow(watered: bool):
	if age <= max_age and watered:
		age = min(age + grow_speed, max_age)
		$Sprite2D.frame = floor(age)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if age >= max_age:
		queue_free()
