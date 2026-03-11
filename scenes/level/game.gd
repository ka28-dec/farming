extends Node2D

@onready var player := $Objects/Player


func _on_player_tool_use(tool: int, pos: Vector2) -> void:
	var grid_pos = Vector2i(floor(pos.x / 16.0), floor(pos.y / 16.0))
	if tool == player.Tools.HOE:
		$Layers/SoilLayer.set_cells_terrain_connect([grid_pos], 0, 0)
		print(grid_pos)
