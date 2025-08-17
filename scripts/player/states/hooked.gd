extends PlayerState

# Want to avoid "just_pressed" for retracting so that you can enter hooked with
# retracted pressed and it work as expected, so use this flag to toggle on/off
var retracting: bool = false


func enter(previous_state_path: String, data := {}) -> void:
	var hook_pos = data["hook_global_pos"]
	player.pinjoint.global_position = hook_pos
	player.hook.global_position = hook_pos
	player.pinjoint.node_b = player.get_path_to(player.hook)
	#rotate the hook so it is the right angle
	var direction = hook_pos - player.global_position
	player.hook.rotation = direction.angle()
	retracting = false


func exit() -> void:
	player.line.clear_points()
	player.pinjoint.node_b = NodePath("")
	retracting = false


func physics_update(delta: float) -> void:
	if Input.is_action_just_pressed("shoot_"+player.player_id):
		if player.get_contact_count() > 0:
			finished.emit(ON_GROUND)
		else:
			finished.emit(IN_AIR)
		return
	
	if Input.is_action_pressed("retract_"+player.player_id) and not retracting:
		var old_pos = player.global_position
		player.global_position = player.hook.global_position
		player.pinjoint.node_b = NodePath("")
		player.pinjoint.node_b = player.get_path_to(player.hook)
		player.global_position = old_pos
		retracting = true
	if Input.is_action_just_released("retract_"+player.player_id):
		player.pinjoint.node_b = NodePath("")
		player.pinjoint.node_b = player.get_path_to(player.hook)
		retracting = false
	
	player.line.clear_points()
	player.line.add_point(Vector2.ZERO)
	player.line.add_point(player.to_local(player.line_end.global_position))
	
	if Input.is_action_pressed("right_"+player.player_id):
		player.apply_central_impulse(Vector2.RIGHT * player.swing_speed)
	if Input.is_action_pressed("left_"+player.player_id):
		player.apply_central_impulse(Vector2.LEFT * player.swing_speed)
	if Input.is_action_just_pressed("up_"+player.player_id):
		player.apply_central_impulse(Vector2.UP * player.swing_speed)
	if Input.is_action_just_pressed("down_"+player.player_id):
		player.apply_central_impulse(Vector2.DOWN * player.swing_speed)
