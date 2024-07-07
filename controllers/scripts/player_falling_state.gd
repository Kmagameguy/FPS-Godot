class_name PlayerFallingState extends PlayerMovementState

@export var SPEED       : float = 5.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var DOUBLE_JUMP_VELOCITY: float = 4.5
@export_range(0.5, 1.0, 0.01) var INPUT_REDUCER: float = 0.85

var _previous_state: PlayerState

func enter(previous_state: PlayerState) -> void:
	_previous_state = previous_state
	ANIMATION.pause()

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED * INPUT_REDUCER, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()

	if Input.is_action_just_pressed(PLAYER.STATES.JUMP.ACTION) && _not_previously_jumping():
		transition.emit(PLAYER.STATES.JUMP.STATE_NAME)

	if PLAYER.is_on_floor():
		ANIMATION.play(PLAYER.STATES.JUMP.ANIMATION.END)
		transition.emit(PLAYER.STATES.IDLE.STATE_NAME)

func _not_previously_jumping() -> bool:
	return !(_previous_state is PlayerJumpingState ||
			_previous_state is PlayerDoubleJumpingState)
