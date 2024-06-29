extends CharacterBody3D

@export_range(5, 10, 0.1) var CROUCH_SPEED : float = 7.0
@export var SPEED_DEFAULT     : float = 5.0
@export var SPEED_CROUCH      : float = 2.0
@export var TOGGLE_CROUCH     : bool  = true
@export var SPEED             : float = 5.0
@export var JUMP_VELOCITY     : float = 4.0
@export var MOUSE_SENSITIVITY : float = 0.5
@export var TILT_LOWER_LIMIT  : float = deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT  : float = deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Camera3D
@export var ANIMATION_PLAYER  : AnimationPlayer
@export var CROUCH_SHAPECAST  : ShapeCast3D

enum MOVEMENT_SPEED { DEFAULT, CROUCHING }

var _speed               : float
var _mouse_input         : bool = false
var _rotation_input      : float
var _tilt_input          : float
var _mouse_rotation      : Vector3
var _player_rotation     : Vector3
var _camera_rotation     : Vector3
var _crouch_action       : String = "crouch"
var _exit_action         : String = "exit"
var _jump_action         : String = "jump"
var _move_left_action    : String = "move_left"
var _move_forward_action : String = "move_forward"
var _move_right_action   : String = "move_right"
var _move_backward_action: String = "move_backward"
var _crouch_anim         : String = "crouch"
var _is_crouching        : bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _unhandled_input(event: InputEvent) -> void:

	_mouse_input = event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY

func _input(event: InputEvent) -> void:

	if event.is_action_pressed(_exit_action):
		get_tree().quit()

	# Toggle crouch
	if event.is_action_pressed(_crouch_action) && is_on_floor() && TOGGLE_CROUCH == true:
		_toggle_crouch()
	
	# Hold to crouch
	if event.is_action_pressed(_crouch_action) && _is_crouching == false && is_on_floor() && TOGGLE_CROUCH == false: # Hold to crouch
		crouching(true)
	if event.is_action_released(_crouch_action) && TOGGLE_CROUCH == false: # Release to uncrouch
		if CROUCH_SHAPECAST.is_colliding() == false:
			crouching(false)
		elif CROUCH_SHAPECAST.is_colliding() == true:
			uncrouch_check()

func _update_camera(delta: float) -> void:

	# Rotates camera using euler rotation
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta

	_player_rotation = Vector3(0.0,_mouse_rotation.y,0.0)
	_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)

	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)

	CAMERA_CONTROLLER.rotation.z = 0.0

	_rotation_input = 0.0
	_tilt_input = 0.0

func _ready() -> void:

	# Get mouse input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Make sure none of the elements of the Player trigger the is_colliding()
	# function of the shapecast.  Where '$"."' is a reference to the root
	# CharacterBody3D node.
	CROUCH_SHAPECAST.add_exception($".")
	_speed = SPEED_DEFAULT

func _physics_process(delta: float) -> void:

	Global.debug.add_property("MovementSpeed", _speed, 1)
	Global.debug.add_property("MouseRotation", _mouse_rotation, 2)
	
	# Update camera movement based on mouse movement
	_update_camera(delta)

	# Add the gravity.
	if !is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed(_jump_action) && is_on_floor() && _is_crouching == false:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector(_move_left_action, _move_right_action, _move_forward_action, _move_backward_action)

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * _speed
		velocity.z = direction.z * _speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _set_movement_speed(state: int) -> void:
	match state:
		MOVEMENT_SPEED.DEFAULT:
			_speed = SPEED_DEFAULT
		MOVEMENT_SPEED.CROUCHING:
			_speed = SPEED_CROUCH

func _toggle_crouch() -> void:
	if _is_crouching == true && CROUCH_SHAPECAST.is_colliding() == false:
		crouching(false)
	elif _is_crouching == false:
		crouching(true)

func crouching(state: bool) -> void:
	# Use a var to label the animation player's "play from end" boolean parameter.
	# I wish GDScript supported keyword arguments.
	var PLAY_FROM_END = true
	
	match state:
		true:
			ANIMATION_PLAYER.play(_crouch_anim, 0, CROUCH_SPEED)
			_set_movement_speed(MOVEMENT_SPEED.CROUCHING)
		false:
			ANIMATION_PLAYER.play(_crouch_anim, 0, -CROUCH_SPEED, PLAY_FROM_END)
			_set_movement_speed(MOVEMENT_SPEED.DEFAULT)

func uncrouch_check() -> void:
	if CROUCH_SHAPECAST.is_colliding() == false:
		crouching(false)
	if CROUCH_SHAPECAST.is_colliding() == true:
		await get_tree().create_timer(0.1).timeout
		uncrouch_check()

func _on_animation_player_animation_started(anim_name):
	if anim_name == _crouch_anim:
		_is_crouching = !_is_crouching
