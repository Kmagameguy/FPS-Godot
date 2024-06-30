class_name PlayerStateMachine

extends Node

@export var CURRENT_STATE : PlayerState
var states: Dictionary = {}

func _ready() -> void:
	# Get the child nodes of PlayerStateMachine
	# For each one, add it to our list of "known" states
	for child in get_children():
		if child is PlayerState:
			states[child.name] = child
			child.transition.connect(_on_child_transition)
		else:
			push_warning("State machine contains incompatible child node")

	await owner.ready
	CURRENT_STATE.enter()

# Some inheritance stuff; each state inherits from PlayerState which provides a base
# set of functions, like "update" and "physics_upate".  We can call those on any PlayerState object.
func _process(delta: float) -> void:
	CURRENT_STATE.update(delta)
	Global.debug.add_property("Current State", CURRENT_STATE.name, 1)

func _physics_process(delta: float) -> void:
	CURRENT_STATE.physics_update(delta)

# Handles state changes.  The new_state_name should match one of the defined states.
# From there we exit the current state and enter the new one if it is different.
# Again this is taking advantage of inheritance since any state will contain the "exit" and
# "enter" methods by virtue of inheriting from the base PlayerState class.
func _on_child_transition(new_state_name: StringName) -> void:
	var new_state = states.get(new_state_name)
	if new_state != null:
		if new_state != CURRENT_STATE:
			CURRENT_STATE.exit()
			new_state.enter()
			CURRENT_STATE = new_state
		else:
			push_warning("State does not exist")
