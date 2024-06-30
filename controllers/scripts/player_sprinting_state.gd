class_name PlayerSprintingState extends PlayerMovementState

@export var SPEED         : float = 7.0
@export var ACCELERATION  : float = 0.1
@export var DECELERATION  : float = 0.25
@export var MAX_ANIM_SPEED: float = 1.6

func enter(_previous_state: PlayerState) -> void:
	ANIMATION.play(PLAYER.STATES.SPRINT.ANIMATION, 0.5, 1.0)
	
func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	set_animation_speed(PLAYER.velocity.length())
	
	if Input.is_action_just_released(PLAYER.STATES.SPRINT.ACTION):
		transition.emit(PLAYER.STATES.WALK.STATE_NAME)
	
	if Input.is_action_just_pressed("crouch") && PLAYER.velocity.length() > 6:
		transition.emit(PLAYER.STATES.SLIDE.STATE_NAME)
	
	if Input.is_action_just_pressed(PLAYER.STATES.JUMP.ACTION) && PLAYER.is_on_floor():
		transition.emit(PLAYER.STATES.JUMP.STATE_NAME)

func set_animation_speed(speed: float) -> void:
	var alpha: float = remap(speed, 0.0, SPEED, 0.0, 1.0)
	ANIMATION.speed_scale = lerp(0.0, MAX_ANIM_SPEED, alpha)
