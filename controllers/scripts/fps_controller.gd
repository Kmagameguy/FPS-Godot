class_name Player extends CharacterBody3D

@export var MOUSE_SENSITIVITY : float = 0.5
@export var TILT_LOWER_LIMIT  : float = deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT  : float = deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Camera3D
@export var ANIMATION_PLAYER  : AnimationPlayer
@export var CROUCH_SHAPECAST  : ShapeCast3D

const STATES = {
	IDLE   = { STATE_NAME = "PlayerIdleState", ANIMATION = null, ACTION = null },
	CROUCH = { STATE_NAME = "PlayerCrouchingState", ANIMATION = "crouch", ACTION = "crouch" },
	WALK   = { STATE_NAME = "PlayerWalkingState", ANIMATION = "Walking", ACTION = null },
	SPRINT = { STATE_NAME = "PlayerSprintingState", ANIMATION = "Sprinting", ACTION = "sprint" },
	SLIDE  = { STATE_NAME = "PlayerSlidingState", ANIMATION = "Sliding", ACTION = "slide" },
	JUMP   = { STATE_NAME = "PlayerJumpingState", ANIMATION = null, ACTION = "jump" }
}

var _mouse_input         : bool = false
var _rotation_input      : float
var _tilt_input          : float
var _mouse_rotation      : Vector3
var _player_rotation     : Vector3
var _camera_rotation     : Vector3
var _exit_action         : String = "exit"
var _move_left_action    : String = "move_left"
var _move_forward_action : String = "move_forward"
var _move_right_action   : String = "move_right"
var _move_backward_action: String = "move_backward"
var _current_rotation    : float

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

func _update_camera(delta: float) -> void:
	# Rotates camera using euler rotation
	_current_rotation = _rotation_input
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

func _physics_process(delta: float) -> void:
	Global.debug.add_property("Velocity", "%.2f" % velocity.length(), 2)
	
	# Update camera movement based on mouse movement
	_update_camera(delta)

func update_gravity(delta: float) -> void:
	velocity.y -= gravity * delta

func update_input(speed: float, acceleration: float, deceleration: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector(_move_left_action, _move_right_action, _move_forward_action, _move_backward_action)
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration)
	else:
		# fix for weird left/right shift that can happen when coming to a stop.
		var vel = Vector3(velocity.x, velocity.y, velocity.z)
		var temp = move_toward(Vector3(velocity.x, velocity.y, velocity.z).length(), 0, deceleration)
		velocity.x = vel.normalized().x * temp
		velocity.z = vel.normalized().z * temp

func update_velocity() -> void:
	move_and_slide()
