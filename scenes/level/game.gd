extends Node2D

@onready var player := $Objects/Player
var plant_scene:PackedScene = preload("res://scenes/level/plant.tscn")
@export var daytime_gradient: Gradient

func _process(_delta: float) -> void:
	var daytime_point: float = 1.0 - $DayTimer.time_left / $DayTimer.wait_time
	$CanvasModulate.color = daytime_gradient.sample(daytime_point)
	if Input.is_action_just_pressed("ui_focus_next"):
		day_switch()


func _on_player_tool_use(tool: int, pos: Vector2) -> void:
	var grid_pos := Vector2i(floor(pos.x / 16.0), floor(pos.y / 16.0))
	if tool == player.Tools.HOE:
		var cell: TileData = $Layers/GrassLayer.get_cell_tile_data(grid_pos)
		if cell and cell.get_custom_data("usable"):
			$Layers/SoilLayer.set_cells_terrain_connect([grid_pos], 0, 0)
	
	if tool == player.Tools.WATER:
		var cell: TileData = $Layers/SoilLayer.get_cell_tile_data(grid_pos)
		if cell:
			$Layers/SoilWaterLayer.set_cell(grid_pos, 0, Vector2i(randi_range(0, 2), 0))
			
	if tool == player.Tools.AXE:
		for tree in get_tree().get_nodes_in_group("Trees"):
			if tree.position.distance_to(pos) < 16:
				tree.hit()


func _on_player_seed_use(seed_enum: int, pos: Vector2) -> void:
	var grid_pos := Vector2i(floor(pos.x / 16.0), floor(pos.y / 16.0))
	var cell: TileData = $Layers/SoilLayer.get_cell_tile_data(grid_pos)
	if cell:
		var plant_pos := Vector2(grid_pos.x * 16 + 8, grid_pos.y * 16 - 4)
		var plant :StaticBody2D = plant_scene.instantiate()
		plant.setup(seed_enum, grid_pos)
		$Objects.add_child(plant)
		plant.position = plant_pos


func day_switch() -> void:
	var tween = create_tween()
	tween.tween_property($CanvasLayer/ColorRect, "modulate:a", 1.0, 1.0)
	tween.tween_interval(1.0) # 次のTweenの実行まで感覚をあける
	tween.tween_callback(level_reset) # Tweenの途中で関数を呼ぶ
	tween.tween_property($CanvasLayer/ColorRect, "modulate:a", 0.0, 1.0)


func level_reset():
	for plant in get_tree().get_nodes_in_group("Plants"):
		plant.grow(plant.grid_pos in $Layers/SoilWaterLayer.get_used_cells())
	$Layers/SoilWaterLayer.clear()
	$DayTimer.start()
