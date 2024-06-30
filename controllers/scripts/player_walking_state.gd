class_name PlayerWalkingState extends PlayerMovementState

@export var SPEED          : float = 5.0
@export var ACCELERATION   : float = 0.1
@export var DECELERATION   : float = 0.25
@export var MAX_ANIM_SPEED : float = 2.2

func enter() -> void:
	ANIMATION.play(PLAYER.STATES.WALK.ANIMATION, -1.0, 1.0)

func exit() -> void:
	ANIMATION.speed_scale = 1.0

func update(delta: float):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	set_animation_speed(PLAYER.velocity.length())
	
	if Input.is_action_pressed(PLAYER.STATES.SPRINT.ACTION) && PLAYER.is_on_floor():
		transition.emit(PLAYER.STATES.SPRINT.STATE_NAME)

	if Input.is_action_pressed(PLAYER.STATES.CROUCH.ACTION) && PLAYER.is_on_floor():
		transition.emit(PLAYER.STATES.CROUCH.STATE_NAME)
	
	if PLAYER.velocity.length() == 0.0:
		transition.emit(PLAYER.STATES.IDLE.STATE_NAME)

func set_animation_speed(speed: float):
	var alpha: float = remap(speed, 0.0, SPEED, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, MAX_ANIM_SPEED, alpha)
