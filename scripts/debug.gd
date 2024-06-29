extends PanelContainer

@onready var _property_container = %VBoxContainer

var _debug_action = "debug"
var _frames_per_second: String

func _ready() -> void:
	Global.debug = self
	
	visible = false
	
	add_property("FPS", _frames_per_second, 0)
	
func _process(delta) -> void:
	if visible:
		_frames_per_second = "%2.f" % (1.0/delta)
		add_property("FPS", _frames_per_second, 0)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(_debug_action):
		visible = !visible

func add_property(title: String, value, order: int) -> void:
	var _target: Label
	_target = _property_container.find_child(title, true, false)
	if !_target:
		_target = Label.new()
		_property_container.add_child(_target)
		_target.name = title
		_target.text = _target.name + ": " + str(value)
	elif visible:
		_target.text = title + ": " + str(value)
		_property_container.move_child(_target, order)
