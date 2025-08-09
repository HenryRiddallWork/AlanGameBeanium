extends PlayerState

func physics_update(delta: float) -> void:
	if (player.get_contact_count() > 0):
		finished.emit(ON_GROUND)
		return
	
	if _is_joystick_in_use():
		player.direction_hook.visible = true
		var joystickDirection = _get_joystick_direction()
		player.direction_hook.global_rotation = joystickDirection
		
		if Input.is_action_just_pressed("shoot"):
			player.ray_cast_2d.target_position = player.to_local(player.global_position + (Vector2.from_angle(joystickDirection - (PI / 2)) * player.hook_range))
			player.ray_cast_2d.force_raycast_update()
			if player.ray_cast_2d.is_colliding():
				#get values from raycast
				var hook_pos = player.ray_cast_2d.get_collision_point()
				var collider = player.ray_cast_2d.get_collider()
				
				#if the ray collides with a hookable object, move pinjoint and hook to it
				if collider.is_in_group("Hookable"):
					finished.emit(HOOKED, {"hook_global_pos": hook_pos})
	else:
		player.direction_hook.visible = false


func exit() -> void:
	player.direction_hook.visible = false


func _get_joystick_direction() -> float:
	# NE
	if Input.is_action_pressed("up") and Input.is_action_pressed("right"):
		return PI / 4
	# SE
	elif Input.is_action_pressed("down") and Input.is_action_pressed("right"):
		return 3 * PI / 4
	# SW
	elif Input.is_action_pressed("down") and Input.is_action_pressed("left"):
		return 5 * PI / 4
	# NW
	elif Input.is_action_pressed("up") and Input.is_action_pressed("left"):
		return 7 * PI / 4
	# E
	elif Input.is_action_pressed("right"):
		return PI / 2
	# S
	elif Input.is_action_pressed("down"):
		return PI
	# W
	elif Input.is_action_pressed("left"):
		return 3 * PI / 2
	# N
	else:
		return 0


func _is_joystick_in_use() -> bool:
	return Input.is_action_pressed("up") or Input.is_action_pressed("right") or Input.is_action_pressed("down") or Input.is_action_pressed("left")
