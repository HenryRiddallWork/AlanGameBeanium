extends PlayerState

func physics_update(delta: float) -> void:
	if (player.get_contact_count() == 0):
		finished.emit(IN_AIR)
		return
	
	if Input.is_action_pressed("right_"+player.player):
		player.apply_central_impulse(Vector2.RIGHT * player.speed)
	if Input.is_action_pressed("left_"+player.player):
		player.apply_central_impulse(Vector2.LEFT * player.speed)
	if Input.is_action_just_pressed("up_"+player.player):
		player.apply_central_impulse(Vector2.UP * 100)
