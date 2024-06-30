class_name PlayerSprintingState extends PlayerState

@export var ANIMATION : AnimationPlayer
@export var MAX_ANIM_SPEED : float = 1.6

func enter() -> void:
	ANIMATION.play("Sprinting", 0.5, 1.0)
	# TODO: This feels gross, look into refactoring this concern into the player class...
	Global.player._speed = Global.player.SPEED_SPRINTING
	
func update(_delta: float) -> void:
	set_animation_speed(Global.player.velocity.length())
	
func set_animation_speed(speed: float) -> void:
	var alpha: float = remap(speed, 0.0, Global.player.SPEED_SPRINTING, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, MAX_ANIM_SPEED, alpha)

func _input(event: InputEvent) -> void:
	if event.is_action_released("sprint"):
		transition.emit("PlayerWalkingState")
