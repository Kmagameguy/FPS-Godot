class_name PlayerIdleState extends PlayerMovementState

@export var SPEED          : float = 5.0
@export var ACCELERATION   : float = 0.1
@export var DECELERATION   : float = 0.25

func enter() -> void:
	ANIMATION.pause()

func update(delta: float):
	PLAYER.update_gravity(delta)
	# This is kinda weird, would be nice if these were optional args or something...
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()

	if Input.is_action_just_pressed(PLAYER.STATES.CROUCH.ACTION) && PLAYER.is_on_floor():
		transition.emit(PLAYER.STATES.CROUCH.STATE_NAME)

	if PLAYER.velocity.length() > 0.0 && PLAYER.is_on_floor():
		transition.emit(PLAYER.STATES.WALK.STATE_NAME)
