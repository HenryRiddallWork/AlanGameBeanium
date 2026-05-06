extends PlayerState

# Want to avoid "just_pressed" for retracting so that you can enter hooked with
# retracted pressed and it work as expected, so use this flag to toggle on/off
var retracting: bool = false

var max_length = null

var thwip_rotation_offset = 0

@onready var thwip:RichTextLabel = $RichTextLabel


func enter(previous_state_path: String, data := {}) -> void:
	var hook_pos = data["hook_global_pos"]
	player.pinjoint.global_position = hook_pos
	player.hook.global_position = hook_pos
	player.pinjoint.node_b = player.get_path_to(player.hook)
	#rotate the hook so it is the right angle
	var direction = hook_pos - player.global_position
	player.hook.rotation = direction.angle()
	retracting = false
	max_length = (hook_pos - player.global_position).length()
	thwip_rotation_offset = deg_to_rad(randf_range(-45.0, 45.0))
	player.thwip.rotation = -player.rotation + thwip_rotation_offset
	player.thwip.show()
	get_tree().create_timer(0.8).timeout.connect(player.thwip.hide)

func exit() -> void:
	player.line.clear_points()
	player.pinjoint.node_b = NodePath("")
	retracting = false
	max_length = null


func physics_update(delta: float) -> void:
	if player.thwip.visible:
		player.thwip.rotation = -player.rotation + thwip_rotation_offset	
	if Input.is_action_just_pressed("shoot_"+player.player_id):
		if player.get_contact_count() > 0:
			finished.emit(ON_GROUND)
		else:
			finished.emit(IN_AIR)
		return
	
	if (max_length != null and max_length < (player.hook.global_position - player.global_position).length()):
		if (player.pinjoint.node_b == NodePath("")):
			player.pinjoint.node_b = NodePath("")
			player.pinjoint.node_b = player.get_path_to(player.hook)
	else:
		player.pinjoint.node_b = NodePath("")
	
	if Input.is_action_pressed("retract_"+player.player_id):#and not retracting:
		#var old_pos = player.global_position
		#player.global_position = player.hook.global_position
		#player.pinjoint.node_b = player.get_path_to(player.hook)
		#player.global_position = old_pos
		var retract_vector = player.hook.global_position - player.global_position
		var retract_force = retract_vector * 1500 / retract_vector.length()
		player.apply_force(retract_force)
		retracting = true
	if Input.is_action_just_released("retract_"+player.player_id):
		max_length = (player.hook.global_position - player.global_position).length()
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
