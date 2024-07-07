class_name PlayerSlidingState extends PlayerMovementState

@export var TILT_AMOUNT : float = 0.09
@export_range(1, 6, 0.1) var SLIDE_ANIM_SPEED: float = 4.0

@onready var CROUCH_SHAPECAST: ShapeCast3D = %CrouchCollisionCast

var _animation_speed_track   : int = 5
var _animation_rotation_track: int = 3

func enter(_previous_state: PlayerState) -> void:
	set_tilt(PLAYER._current_rotation)
	ANIMATION.get_animation(PLAYER.STATES.SLIDE.ANIMATION).track_set_key_value(_animation_speed_track, 0, PLAYER.velocity.length())
	ANIMATION.speed_scale = 1.0
	ANIMATION.play(PLAYER.STATES.SLIDE.ANIMATION, -1.0, SLIDE_ANIM_SPEED)

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_velocity()

func set_tilt(player_rotation: float) -> void:
	var tilt : Vector3 = Vector3.ZERO
	tilt.z = clamp(TILT_AMOUNT * player_rotation, -0.1, 0.1)
	if tilt.z == 0.0:
			tilt.z = 0.05
	ANIMATION.get_animation(PLAYER.STATES.SLIDE.ANIMATION).track_set_key_value(_animation_rotation_track, 1, tilt)
	ANIMATION.get_animation(PLAYER.STATES.SLIDE.ANIMATION).track_set_key_value(_animation_rotation_track, 2, tilt)

func finish():
	transition.emit(PLAYER.STATES.CROUCH.STATE_NAME)
