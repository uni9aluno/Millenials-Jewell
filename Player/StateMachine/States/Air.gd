extends PlayerState

var gravity: float
onready var bounce_timer := $BounceTimer as Timer

func _ready() -> void:
	bounce_timer.connect("timeout", self, "_on_bounce_timer_timeout")

func enter(msg:= {}) -> void:
	player.animated_sprite.set_animation("Jump")
	
	if msg.get("is_stomping", false):
		bounce_timer.start()
	
	if msg.get("is_jumping", false):

		if player.velocity.y > -player.jump_speed:
			player.velocity.y = -(
					player.jump_speed if player.jumps_total == player.jumps_left else
					player.multi_jump_speed
			)
			player.animation_player.play("Stretch")
		gravity = player.jump_gravity
		if (
				player.min_jump_enabled 
				and not Input.is_action_pressed(player.jump_button) 
				and not msg.get("is_stomping", false)
		):
			gravity = player.min_jump_gravity
		player.jumps_left -= 1
		

		if player.multi_jump_enabled and player.jumps_left == 0:
			if not msg.get("is_stomping", false):
				AudioPlayer.play_sound(AudioPlayer.DOUBLE_JUMP)
			player.set_multi_jump_enabled(false)
			player.animated_sprite.modulate = Color.white
		else:
			if not msg.get("is_stomping", false):
				AudioPlayer.play_sound(AudioPlayer.JUMP)
		
	if msg.get("run_immediately", false):
		physics_update(get_physics_process_delta_time())


func physics_update(delta: float) -> void:
	if (
			player.jumps_left > 0 
			and player.jump_enabled 
			and player.consume_jump_press() 
			and bounce_timer.is_stopped()
	):
		state_machine.transition_to("Air", {"is_jumping": true, "run_immediately": true})
		return
	

	player.update_run_velocity(delta)
	
	# Apply gravity.
	if player.min_jump_enabled and Input.is_action_just_released(player.jump_button):
		gravity = player.min_jump_gravity
	if player.fast_fall_enabled and player.velocity.y > 0:
		gravity = player.fast_fall_gravity
	player.velocity.y += gravity * delta
	
	if player.velocity.y < 0:
		player.animated_sprite.set_animation("Jump")
	else:
		player.animated_sprite.set_animation("Fall")
	

	if player.terminal_velocity_enabled:
		player.velocity.y = clamp(player.velocity.y, -player.terminal_velocity, player.terminal_velocity)
		
	if player.perform_stomp_if_able(gravity, delta):
		state_machine.transition_to("Air", {"is_jumping": true, "is_stomping": true})
		return


	player.velocity = player.move_and_slide_with_vertical_velocity_verlet(
		player.velocity,
		gravity,
		delta
	)
	

	if player.dash_enabled and player.is_input_active and Input.is_action_just_pressed("dash"):
		state_machine.transition_to("Dash")
	elif player.is_on_floor():
		state_machine.transition_to("Ground")
		return
		
		
func exit() -> void:
	bounce_timer.stop()
		

func _on_bounce_timer_timeout() -> void:

	if not Input.is_action_pressed(player.jump_button) and player.min_jump_enabled:
		gravity = player.min_jump_gravity
