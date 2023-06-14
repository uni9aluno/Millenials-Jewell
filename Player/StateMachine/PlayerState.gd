

class_name PlayerState
extends Node


var player: Player

var state_machine = null


func _ready() -> void:


	yield(owner, "ready")

	player = owner as Player

	assert(player != null)



func handle_input(_event: InputEvent) -> void:
	pass



func update(_delta: float) -> void:
	pass



func physics_update(_delta: float) -> void:
	pass



func enter(_msg := {}) -> void:
	pass



func exit() -> void:
	pass
