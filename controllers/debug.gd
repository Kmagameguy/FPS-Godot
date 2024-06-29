extends PanelContainer

@onready var _property_container = %VBoxContainer

var _debug_action = "debug"
var _property
var _frames_per_second: String

func _ready() -> void:
	visible = false
	_add_debug_property("FPS", _frames_per_second)
	
func _process(delta) -> void:
	if visible:
		_update_fps_display(delta)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(_debug_action):
		visible = !visible

func _update_fps_display(delta: float) -> void:
	_frames_per_second = "%2.f" % (1.0/delta)
	_property.text = _property.name + ": " + _frames_per_second
	
func _add_debug_property(title: String, value) -> void:
	_property = Label.new()
	_property_container.add_child(_property)
	_property.name = title
	_property.text = _property.name + value
