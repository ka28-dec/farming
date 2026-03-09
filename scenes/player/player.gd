extends CharacterBody2D

@onready var move_state_machine: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/MoveStateMachine/playback")
var direction: Vector2
var speed := 200


func _physics_process(_delta: float) -> void:
	get_input()
	velocity = direction * speed
	move_and_slide()
	animation()


func get_input() -> void:
	direction = Input.get_vector("left", "right", "up", "down")


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
	else:
		move_state_machine.travel("idle")
