class_name PlayerIdleState

extends PlayerState

@export var ANIMATION : AnimationPlayer

func enter() -> void:
	ANIMATION.pause()

func update(_delta: float):
	if Global.player.velocity.length() > 0.0 && Global.player.is_on_floor():
		transition.emit("PlayerWalkingState")
