extends PlayerState

func physics_update(delta: float) -> void:
	if (player.get_contact_count() > 0):
		finished.emit(ON_GROUND)
		return
	
	if _is_joystick_in_use():
		player.direction_hook.visible = true
		var joystickDirection = _get_joystick_direction()
		player.direction_hook.global_rotation = joystickDirection
		
		if Input.is_action_just_pressed("shoot_"+player.player_id):
			var collision_points = _get_raycast_angles_for_arc(joystickDirection).map(
				func(angle_and_scale_factor):
					var angle = angle_and_scale_factor[0]
					var scale_factor = angle_and_scale_factor[1]
					player.ray_cast_2d.target_position = player.to_local(player.global_position + (Vector2.from_angle(angle - (PI / 2)) * player.hook_range))
					player.ray_cast_2d.force_raycast_update()
					if player.ray_cast_2d.is_colliding():
						var hook_pos = player.ray_cast_2d.get_collision_point()
						var collider = player.ray_cast_2d.get_collider()
						if collider.is_in_group("Hookable"):
							return [hook_pos, scale_factor]
						else:
							return null
					else:
						return null
			)
			
			collision_points = collision_points.filter(func(v): return v != null)
			collision_points.sort_custom(
				func(v1, v2):
					return (v1[0].distance_to(player.global_position) * v1[1]) < (v2[0].distance_to(player.global_position) * v2[1])
			)
			
			if collision_points.size() > 0:
				finished.emit(HOOKED, {"hook_global_pos": collision_points[0][0]})
				return
	else:
		player.direction_hook.visible = false


func exit() -> void:
	player.direction_hook.visible = false


func _get_joystick_direction() -> float:
	# NE
	if Input.is_action_pressed("up_"+player.player_id) and Input.is_action_pressed("right_"+player.player_id):
		return PI / 4
	# SE
	elif Input.is_action_pressed("down_"+player.player_id) and Input.is_action_pressed("right_"+player.player_id):
		return 3 * PI / 4
	# SW
	elif Input.is_action_pressed("down_"+player.player_id) and Input.is_action_pressed("left_"+player.player_id):
		return 5 * PI / 4
	# NW
	elif Input.is_action_pressed("up_"+player.player_id) and Input.is_action_pressed("left_"+player.player_id):
		return 7 * PI / 4
	# E
	elif Input.is_action_pressed("right_"+player.player_id):
		return PI / 2
	# S
	elif Input.is_action_pressed("down_"+player.player_id):
		return PI
	# W
	elif Input.is_action_pressed("left_"+player.player_id):
		return 3 * PI / 2
	# N
	else:
		return 0


func _is_joystick_in_use() -> bool:
	return Input.is_action_pressed("up_"+player.player_id) or Input.is_action_pressed("right_"+player.player_id) or Input.is_action_pressed("down_"+player.player_id) or Input.is_action_pressed("left_"+player.player_id)


func _get_raycast_angles_for_arc(angle: float) -> Array[Array]:
	# PI / 4 arc around direction
	var min_angle = angle - (PI / 8)
	var max_angle = angle + (PI / 8)
	var step = PI / (4 * player.raycast_count)
	
	var out_arr: Array[Array] = []
	for i in range(0, player.raycast_count):
		var angle_value = min_angle + (step * i)
		out_arr.append([angle_value, _triangle_weighting_function(min_angle, max_angle, angle_value)])
	
	return out_arr


func _triangle_weighting_function(min: float, max: float, value: float) -> float:
	assert(value >= min)
	assert(value <= max)
	var mid_point_of_range = (min + max) / 2
	var scaling_factor: float
	if value < mid_point_of_range:
		scaling_factor = (value - min) / (mid_point_of_range - min)
	else:
		scaling_factor = (value - mid_point_of_range) / (max - mid_point_of_range)
	
	return scaling_factor * player.hook_selection_factor
