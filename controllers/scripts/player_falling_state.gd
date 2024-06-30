class_name PlayerFallingState extends PlayerMovementState

@export var SPEED       : float = 5.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export var DOUBLE_JUMP_VELOCITY: float = 4.5

var DOUBLE_JUMP: bool = false

func enter(_previous_state: PlayerState) -> void:
	ANIMATION.pause()

func exit() -> void:
	DOUBLE_JUMP = false

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_pressed(PLAYER.STATES.JUMP.ACTION) && !DOUBLE_JUMP:
		DOUBLE_JUMP = true
		PLAYER.velocity.y = DOUBLE_JUMP_VELOCITY

	if PLAYER.is_on_floor():
		ANIMATION.play(PLAYER.STATES.JUMP.ANIMATION.END)
		transition.emit(PLAYER.STATES.IDLE.STATE_NAME)
