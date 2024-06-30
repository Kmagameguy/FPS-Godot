class_name PlayerJumpingState extends PlayerMovementState

@export var SPEED        : float = 6.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25
@export var JUMP_VELOCITY: float = 4.5
@export var DOUBLE_JUMP_VELOCITY : float = JUMP_VELOCITY
@export_range(0.5, 1.0, 0.01) var INPUT_REDUCER: float = 0.85

var DOUBLE_JUMP: bool = false

func enter(_previous_state: PlayerState) -> void:
	PLAYER.velocity.y += JUMP_VELOCITY
	ANIMATION.play(PLAYER.STATES.JUMP.ANIMATION.START)

func exit() -> void:
	DOUBLE_JUMP = false

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED * INPUT_REDUCER, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_pressed(PLAYER.STATES.JUMP.ACTION) && !DOUBLE_JUMP:
		DOUBLE_JUMP = true
		PLAYER.velocity.y = DOUBLE_JUMP_VELOCITY

	if Input.is_action_just_released(PLAYER.STATES.JUMP.ACTION):
		if PLAYER.velocity.y > 0:
			PLAYER.velocity.y = PLAYER.velocity.y / 2.0

	if PLAYER.is_on_floor():
		ANIMATION.play(PLAYER.STATES.JUMP.ANIMATION.END)
		transition.emit(PLAYER.STATES.IDLE.STATE_NAME)
