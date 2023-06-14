

class_name AnchorCamera2D
extends Camera2D


const SLOW_RADIUS := 300.0


export var max_speed := 2000.0

export var mass := 2.0

var _velocity = Vector2.ZERO

var _anchor_position: Vector2
var _target_zoom := 1.0
var _x_axis_lock := false
var _y_axis_lock := false
var _target_offset := Vector2.ZERO


export var decay = 0.8  
export var max_offset = Vector2(100, 75)  
export var max_roll = 0.1  
var trauma = 0.0  
var trauma_power = 2  
onready var noise = OpenSimplexNoise.new()
var noise_y = 0


func _ready() -> void:
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2
	Events.connect("add_trauma", self, "_add_trauma")
	

	set_as_toplevel(true)
	
	var result := get_world_2d().direct_space_state.intersect_point(global_position, 1, [], 16, false, true)
	if not result.empty():
		_on_AnchorDetector2D_anchor_detected(result[0].collider)
		var target_position := Vector2.ZERO
		target_position.x = _anchor_position.x if _x_axis_lock else owner.global_position.x
		target_position.y = _anchor_position.y if _y_axis_lock else owner.global_position.y
		target_position += _target_offset
		global_position = target_position


func _physics_process(delta: float) -> void:
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
	
	if not owner.is_active:
		return
		
	update_zoom()
	
	var target_position := Vector2.ZERO
	target_position.x = _anchor_position.x if _x_axis_lock else owner.global_position.x
	target_position.y = _anchor_position.y if _y_axis_lock else owner.global_position.y
	target_position += _target_offset
	
	arrive_to(target_position)



func _on_AnchorDetector2D_anchor_detected(anchor: Anchor2D) -> void:
	limit_top = anchor.global_position.y - anchor.extents.y if anchor.use_extents_as_limit_top else -10_000_000
	limit_bottom = anchor.global_position.y + anchor.extents.y if anchor.use_extents_as_limit_bottom else 10_000_000
	limit_left = anchor.global_position.x - anchor.extents.x if anchor.use_extents_as_limit_left else -10_000_000
	limit_right = anchor.global_position.x + anchor.extents.x if anchor.use_extents_as_limit_right else 10_000_000
	_anchor_position = anchor.global_position
	_target_zoom = anchor.zoom_level
	_x_axis_lock = anchor.x_axis_lock
	_y_axis_lock = anchor.y_axis_lock
	_target_offset = anchor.target_offset
	global_position = get_camera_screen_center()



func _on_AnchorDetector2D_anchor_detached() -> void:
	limit_left = -10_000_000
	limit_top = -10_000_000
	limit_right = 10_000_000
	limit_bottom = 10_000_000
	_anchor_position = Vector2.ZERO
	_target_offset = Vector2.ZERO
	_target_zoom = 1.0
	_x_axis_lock = false
	_y_axis_lock = false
	global_position = get_camera_screen_center()



func update_zoom() -> void:
	if is_equal_approx(zoom.x, _target_zoom):
		return
	var new_zoom_level: float = lerp(
			zoom.x, _target_zoom, 1.0 - pow(0.008, get_physics_process_delta_time())
	)
	zoom = Vector2(new_zoom_level, new_zoom_level)



func arrive_to(target_position: Vector2) -> void:
	if global_position.is_equal_approx(target_position):
		return
	
	var distance_to_target := global_position.distance_to(target_position)
	

	if distance_to_target < 0.3:
		global_position = target_position
		return
	

	var desired_velocity := (target_position - global_position).normalized() * max_speed * zoom.x

	if distance_to_target < SLOW_RADIUS * zoom.x:
		desired_velocity *= (distance_to_target / (SLOW_RADIUS * zoom.x))
		
	_velocity += (desired_velocity - _velocity) / mass
	global_position += _velocity * get_physics_process_delta_time()
	
	
func _add_trauma(amount):
	trauma = min(trauma + amount, 1.0)
	
	
func shake():
	var amount = pow(trauma, trauma_power)
	noise_y += 1
	rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed*3, noise_y)
