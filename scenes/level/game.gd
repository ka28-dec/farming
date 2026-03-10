extends Node2D

@onready var player := $Objects/Player


func _on_player_tool_use(tool: int, pos: Vector2) -> void:
	var grid_pos = Vector2i(int(pos.x / 16), int(pos.y / 16))
	if tool == player.Tools.HOE:
		print("hoe")
	print(tool, " ", grid_pos)
