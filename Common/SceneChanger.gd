extends Node


export var fade_time := 0.25

var tween: SceneTreeTween
onready var fader := $Control/Fader


func reload_scene(delay: float = 0) -> void:
	yield(_fadeTo(Color("ff000000"), fade_time, delay), "completed")
	get_tree().reload_current_scene()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(_fadeTo(Color("00000000"), fade_time), "completed")



func change_scene(scene: String, delay: float = 0) -> void:
	yield(_fadeTo(Color("ff000000"), fade_time, delay), "completed")
	if get_tree().change_scene(scene) != OK:
		printerr("Failed to change to scene %s" % scene)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(_fadeTo(Color("00000000"), fade_time), "completed")



func _fadeTo(
		fadeToColor: Color, 
		fadeDuration: float, 
		startDelay: float = 0, 
		endDelay: float = 0
) -> void:
	if tween:
		tween.kill()
	if startDelay > 0:
		yield(get_tree().create_timer(startDelay), "timeout")
	if fadeDuration > 0:
		tween = create_tween()
		yield(tween.tween_property(fader, "color", fadeToColor, fadeDuration), "finished")
	else:
		print_debug("Useless call to _fadeTo with no duration.")
		fader.color = fadeToColor
	if endDelay > 0:
		yield(get_tree().create_timer(endDelay), "timeout")


func _fadeFromTo(
		fadeFromColor: Color, 
		fadeToColor: Color, 
		fadeDuration: float, 
		startDelay: float = 0, 
		endDelay: float = 0
) -> void:
	fader.color = fadeFromColor
	_fadeTo(fadeToColor, fadeDuration, startDelay, endDelay)
