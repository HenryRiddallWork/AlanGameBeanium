extends PlayerState

func physics_update(delta: float) -> void:
	if Input.is_action_just_pressed("shoot_"+player.player):
			print("pew"+player.player)
	if (player.get_contact_count() > 0):
		finished.emit(ON_GROUND)
		return
	
	if _is_joystick_in_use():
		player.direction_hook.visible = true
		var joystickDirection = _get_joystick_direction()
		player.direction_hook.global_rotation = joystickDirection
		
		if Input.is_action_just_pressed("shoot_"+player.player):
			var collision_points = _get_raycast_angles_for_arc(joystickDirection).map(
				func(angle):
					player.ray_cast_2d.target_position = player.to_local(player.global_position + (Vector2.from_angle(angle - (PI / 2)) * player.hook_range))
					player.ray_cast_2d.force_raycast_update()
					if player.ray_cast_2d.is_colliding():
						var hook_pos = player.ray_cast_2d.get_collision_point()
						var collider = player.ray_cast_2d.get_collider()
						if collider.is_in_group("Hookable"):
							print("Found collision point:", hook_pos)
							return hook_pos
						else:
							return null
					else:
						return null
			)
			
			collision_points = collision_points.filter(func(v): return v != null)
			collision_points.sort_custom(func(v1, v2): return v1.distance_to(player.global_position) < v2.distance_to(player.global_position))
			
			if collision_points.size() > 0:
				finished.emit(HOOKED, {"hook_global_pos": collision_points[0]})
				return
	else:
		player.direction_hook.visible = false


func exit() -> void:
	player.direction_hook.visible = false


func _get_joystick_direction() -> float:
	# NE
	if Input.is_action_pressed("up_"+player.player) and Input.is_action_pressed("right_"+player.player):
		return PI / 4
	# SE
	elif Input.is_action_pressed("down_"+player.player) and Input.is_action_pressed("right_"+player.player):
		return 3 * PI / 4
	# SW
	elif Input.is_action_pressed("down_"+player.player) and Input.is_action_pressed("left_"+player.player):
		return 5 * PI / 4
	# NW
	elif Input.is_action_pressed("up_"+player.player) and Input.is_action_pressed("left_"+player.player):
		return 7 * PI / 4
	# E
	elif Input.is_action_pressed("right_"+player.player):
		return PI / 2
	# S
	elif Input.is_action_pressed("down_"+player.player):
		return PI
	# W
	elif Input.is_action_pressed("left_"+player.player):
		return 3 * PI / 2
	# N
	else:
		return 0


func _is_joystick_in_use() -> bool:
	return Input.is_action_pressed("up_"+player.player) or Input.is_action_pressed("right_"+player.player) or Input.is_action_pressed("down_"+player.player) or Input.is_action_pressed("left_"+player.player)


func _get_raycast_angles_for_arc(angle: float) -> Array[float]:
	# PI / 4 arc around direction
	var min_angle = angle - (PI / 8)
	var max_angle = angle + (PI / 8)
	var step = PI / (4 * player.raycast_count)
	
	var out_arr: Array[float] = []
	for i in range(0, player.raycast_count):
		out_arr.append(min_angle + (step * i))
	
	return out_arr
