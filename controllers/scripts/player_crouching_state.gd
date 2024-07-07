class_name PlayerCrouchingState extends PlayerMovementState

@export var SPEED       : float = 3.0
@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25
@export_range(1, 6, 0.1) var CROUCH_SPEED: float = 4.0

@onready var CROUCH_SHAPECAST: ShapeCast3D = %CrouchCollisionCast

var RELEASED : bool = false

func enter(previous_state: PlayerState) -> void:
	var UPDATE_TRACK = true
	
	if ANIMATION.is_playing() && ANIMATION.current_animation == PLAYER.STATES.JUMP.ANIMATION.END:
		await ANIMATION.animation_finished
	
	ANIMATION.play(PLAYER.STATES.CROUCH.ANIMATION, -1.0, CROUCH_SPEED)
	if previous_state.name != PLAYER.STATES.SLIDE.STATE_NAME:
		ANIMATION.play(PLAYER.STATES.CROUCH.ANIMATION, -1.0, CROUCH_SPEED)
	elif previous_state.name == PLAYER.STATES.SLIDE.STATE_NAME:
		ANIMATION.current_animation = PLAYER.STATES.CROUCH.ANIMATION
		ANIMATION.seek(1.0, UPDATE_TRACK)

func exit() -> void:
	RELEASED = false

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_released(PLAYER.STATES.CROUCH.ACTION):
		uncrouch()
	elif !Input.is_action_pressed(PLAYER.STATES.CROUCH.ACTION) && !RELEASED:
		RELEASED = true
		uncrouch()
		
func uncrouch():
	var PLAY_FROM_END: bool = true

	if !CROUCH_SHAPECAST.is_colliding() && !Input.is_action_pressed(PLAYER.STATES.CROUCH.ACTION):
		ANIMATION.play(PLAYER.STATES.CROUCH.ANIMATION, -1.0, -CROUCH_SPEED * 1.5, PLAY_FROM_END)
		if ANIMATION.is_playing():
			await ANIMATION.animation_finished
		transition.emit(PLAYER.STATES.IDLE.STATE_NAME)
	elif CROUCH_SHAPECAST.is_colliding():
		await get_tree().create_timer(0.1).timeout
		uncrouch()
