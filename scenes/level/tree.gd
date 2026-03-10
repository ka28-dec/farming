extends StaticBody2D


func _ready() -> void:
	$Sprite2D.frame = randi() % $Sprite2D.hframes
