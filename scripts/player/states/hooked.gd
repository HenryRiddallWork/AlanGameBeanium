extends PlayerState


func enter(previous_state_path: String, data := {}) -> void:
	var hook_pos = data["hook_global_pos"]
	player.pinjoint.global_position = hook_pos
	player.hook.global_position = hook_pos
	player.pinjoint.node_b = player.get_path_to(player.hook)
	#rotate the hook so it is the right angle
	var direction = hook_pos - player.global_position
	player.hook.rotation = direction.angle()


func exit() -> void:
	player.line.clear_points()
	player.pinjoint.node_b = NodePath("")


func physics_update(delta: float) -> void:
	if not Input.is_action_pressed("shoot"):
		if player.get_contact_count() > 0:
			finished.emit(ON_GROUND)
		else:
			finished.emit(IN_AIR)
		return
	
	player.line.clear_points()
	player.line.add_point(Vector2.ZERO)
	player.line.add_point(player.to_local(player.line_end.global_position))
	
	if Input.is_action_pressed("right"):
		player.apply_central_impulse(Vector2.RIGHT * player.swing_speed)
	if Input.is_action_pressed("left"):
		player.apply_central_impulse(Vector2.LEFT * player.swing_speed)
	if Input.is_action_just_pressed("up"):
		player.apply_central_impulse(Vector2.UP * player.swing_speed)
	if Input.is_action_just_pressed("down"):
		player.apply_central_impulse(Vector2.DOWN * player.swing_speed)
