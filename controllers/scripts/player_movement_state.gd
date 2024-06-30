class_name PlayerMovementState extends PlayerState

var PLAYER   : Player
var ANIMATION: AnimationPlayer

func _ready() -> void:
	await owner.ready
	PLAYER = owner as Player
	ANIMATION = PLAYER.ANIMATION_PLAYER
