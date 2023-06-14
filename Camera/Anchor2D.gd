class_name Anchor2D
extends Area2D


export var zoom_level := 1.0


export var x_axis_lock := true
export var y_axis_lock := true


export var target_offset := Vector2.ZERO

# Extents
export var use_extents_as_limit_left := true
export var use_extents_as_limit_right := true
export var use_extents_as_limit_top := true
export var use_extents_as_limit_bottom := true
var extents := Vector2.ZERO

func _ready():
	extents = $CollisionShape2D.get_shape().get_extents()
	extents *= scale
