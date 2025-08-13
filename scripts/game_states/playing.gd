extends GameState

const COLLISION_HEALTH_SCALE_FACTOR = 0.1

const COLLISION_TIMEOUT = 0.7 # Seconds
var current_collision_timeout = 0

func _ready() -> void:
	await game.ready
	game.game_boundary.body_exited.connect(_on_game_boundary_body_exited)
	game.player_1.player_collision.connect(_on_player_collision)
	game.player_2.player_collision.connect(_on_player_collision)

func update(_delta: float) -> void:
	Globals.time_elapsed += _delta
	if current_collision_timeout > 0:
		current_collision_timeout -= _delta
	if Input.is_action_just_pressed("Pause"):
		finished.emit(PAUSED)

func _on_player_collision(player_speeds: Dictionary) -> void:
	if current_collision_timeout <= 0:
		current_collision_timeout = COLLISION_TIMEOUT
		var player_1_speed: float = player_speeds[Globals.PLAYER_1_ID]
		var player_2_speed: float = player_speeds[Globals.PLAYER_2_ID]
		var player_1_damage = floor(COLLISION_HEALTH_SCALE_FACTOR * player_2_speed)
		var player_2_damage = floor(COLLISION_HEALTH_SCALE_FACTOR * player_1_speed)
		_damage_players(player_1_damage, player_2_damage)

func _damage_players(player_1_damage: int, player_2_damage: int) -> void:
	var player_1_new_health = max(0, Globals.player_data[Globals.PLAYER_1_ID].health - player_1_damage)
	var player_2_new_health = max(0, Globals.player_data[Globals.PLAYER_2_ID].health - player_2_damage)
	Globals.player_data[Globals.PLAYER_1_ID].health = player_1_new_health
	Globals.player_data[Globals.PLAYER_2_ID].health = player_2_new_health
	if player_1_new_health == 0 or player_2_new_health == 0:
		# TODO: Report winner here
		finished.emit(END_GAME)

func _on_game_boundary_body_exited(body: Node) -> void:
	if body.is_in_group("Players"):
		# TODO: Report winner here
		finished.emit(END_GAME)
