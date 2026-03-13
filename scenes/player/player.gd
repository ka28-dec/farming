extends CharacterBody2D

@onready var move_state_machine: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/MoveStateMachine/playback")
@onready var tool_state_machine: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/ToolStateMachine/playback")
var direction: Vector2
var last_direction: Vector2
var speed := 100
var can_move := true
var tool_direction_offset := 14
var tool_direction_offset_y := Vector2(0, 6)

enum Tools {HOE, AXE, WATER}
var current_tool: Tools = Tools.AXE
const tool_connection = {
	Tools.HOE: "hoe",
	Tools.AXE: "axe",
	Tools.WATER: "water",
}
var current_seed: Global.Seeds = Global.Seeds.CORN

signal tool_use(tool: Tools, pos: Vector2)
signal seed_use(seed: Global.Seeds, pos: Vector2)


func _physics_process(_delta: float) -> void:
	if can_move:
		get_input()
	if direction:
		last_direction = direction
		if not $Sounds/WalkSoundTimer.time_left:
			$Sounds/WalkSound.play()
			$Sounds/WalkSoundTimer.start()
	velocity = direction * speed * int(can_move) # true: 1, false: 0
	move_and_slide()
	animation()


func get_input() -> void:	
	direction = Input.get_vector("left", "right", "up", "down")
	
	if Input.is_action_just_pressed("action"):
		tool_state_machine.travel(tool_connection[current_tool])
		$AnimationTree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		can_move = false
		if current_tool in [Tools.HOE, Tools.WATER]:
			await $AnimationTree.animation_finished
			tool_use.emit(current_tool, position + last_direction * tool_direction_offset + tool_direction_offset_y)
			match current_tool:
				Tools.HOE:
					$Sounds/HoeSound.play()
				Tools.WATER:
					$Sounds/WaterSound.play()
	
	# ツール切り替え
	if Input.is_action_just_pressed("tool_forward") or Input.is_action_just_pressed("tool_backward"):
		var tool_direction = Input.get_axis("tool_backward", "tool_forward") as int
		current_tool = posmod(current_tool + tool_direction, Tools.size()) as Tools
		
	# 種切り替え
	if Input.is_action_just_pressed("seed_toggle"):
		current_seed = posmod(current_seed + 1, Global.Seeds.size()) as Global.Seeds
	
	if Input.is_action_just_pressed("plant"):
		can_move = false
		direction = Vector2.ZERO
		seed_use.emit(current_seed, position + last_direction * tool_direction_offset + tool_direction_offset_y)
		await get_tree().create_timer(0.5).timeout
		can_move = true


func animation() -> void:
	# 移動アニメーションと待機アニメーションの切り替え
	if direction:
		move_state_machine.travel("move")
		# 入力ベクトルを整数方向に丸める
		var target_vector: Vector2 = direction.round()
		# 縦横4方向のときのみ向きを更新、斜め入力の場合は直前の向きを維持する
		if target_vector.x == 0 or target_vector.y == 0:
			$AnimationTree.set("parameters/MoveStateMachine/move/blend_position", target_vector)
			$AnimationTree.set("parameters/MoveStateMachine/idle/blend_position", target_vector)
			for state in tool_connection.values():
				$AnimationTree.set("parameters/ToolStateMachine/" + state + "/blend_position", target_vector)
	else:
		move_state_machine.travel("idle")


func _on_animation_tree_animation_finished(_anim_name: StringName) -> void:
	can_move = true


func axe_use() -> void:
	$Sounds/AxeSound.play()
	tool_use.emit(current_tool, position + last_direction * tool_direction_offset + tool_direction_offset_y)
