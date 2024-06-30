class_name PlayerWalkingState

extends PlayerState

@export var ANIMATION : AnimationPlayer
@export var MAX_ANIM_SPEED : float = 2.2

func enter() -> void:
	ANIMATION.play("Walking", -1.0, 1.0)

func update(_delta: float):
	set_animation_speed(Global.player.velocity.length())
	if Global.player.velocity.length() == 0.0:
		transition.emit("PlayerIdleState")

func set_animation_speed(speed: float):
	var alpha: float = remap(speed, 0.0, Global.player.SPEED_DEFAULT, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, MAX_ANIM_SPEED, alpha)
