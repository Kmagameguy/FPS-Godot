extends CenterContainer

@export var RETICLE_LINES     : Array[Line2D]
@export var PLAYER_CONTROLLER : CharacterBody3D
@export var RETICLE_SPEED     : float = 0.1
@export var RETICLE_DISTANCE  : float = 10.0
@export var DOT_RADIUS        : float = 1.0
@export var DOT_COLOR         : Color = Color.WHITE

var _reticle_left   : int = 0
var _reticle_top    : int = 1
var _reticle_right  : int = 2
var _reticle_bottom : int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	_adjust_reticle_lines()

func _draw() -> void:
	draw_circle(Vector2(0,0), DOT_RADIUS, DOT_COLOR)

func _adjust_reticle_lines() -> void:
	var _player_velocity = PLAYER_CONTROLLER.get_real_velocity()
	var _origin = Vector3.ZERO
	var _pos = Vector2.ZERO
	var _speed = _origin.distance_to(_player_velocity)

	RETICLE_LINES[_reticle_left].position   = lerp(RETICLE_LINES[_reticle_left].position,   _pos + Vector2(-_speed * RETICLE_DISTANCE, 0), RETICLE_SPEED)
	RETICLE_LINES[_reticle_top].position    = lerp(RETICLE_LINES[_reticle_top].position,    _pos + Vector2(0, -_speed * RETICLE_DISTANCE), RETICLE_SPEED)
	RETICLE_LINES[_reticle_right].position  = lerp(RETICLE_LINES[_reticle_right].position,  _pos + Vector2(_speed * RETICLE_DISTANCE, 0),  RETICLE_SPEED)
	RETICLE_LINES[_reticle_bottom].position = lerp(RETICLE_LINES[_reticle_bottom].position, _pos + Vector2(0, _speed * RETICLE_DISTANCE),  RETICLE_SPEED)
