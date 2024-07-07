class_name PlayerIdleState extends PlayerMovementState

@export var SPEED          : float = 5.0
@export var ACCELERATION   : float = 0.1
@export var DECELERATION   : float = 0.25

func enter(_previous_state: PlayerState) -> void:
	if ANIMATION.is_playing() && ANIMATION.current_animation == PLAYER.STATES.JUMP.ANIMATION.END:
		await ANIMATION.animation_finished

	ANIMATION.pause()

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	# This is kinda weird, would be nice if these were optional args or something...
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()

	if Input.is_action_pressed(PLAYER.STATES.CROUCH.ACTION) && PLAYER.is_on_floor():
		transition.emit(PLAYER.STATES.CROUCH.STATE_NAME)

	if PLAYER.velocity.length() > 0.0 && PLAYER.is_on_floor():
		transition.emit(PLAYER.STATES.WALK.STATE_NAME)

	if Input.is_action_pressed(PLAYER.STATES.JUMP.ACTION) && PLAYER.is_on_floor():
		transition.emit(PLAYER.STATES.JUMP.STATE_NAME)

	if PLAYER.velocity.y < -3.0 && PLAYER.is_in_air():
		transition.emit(PLAYER.STATES.FALL.STATE_NAME)
