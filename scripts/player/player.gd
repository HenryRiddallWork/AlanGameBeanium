class_name Player extends RigidBody2D

@export var hook: StaticBody2D
@export var pinjoint: PinJoint2D
@export var speed: int = 10
@export var swing_speed: int = 5
@export var hook_range: int = 1000
@export var raycast_count: int = 30

# If changing this enum, also change the player IDs in globals
@export_enum("1", "2") var player_id: String

# The factor by which the hook selection will prefer central angles to outside options
@export var hook_selection_factor: float = 1.5

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var line = $Line2D
@onready var line_end = hook.get_node("Marker2D")
@onready var direction_hook: Sprite2D = $DirectionHook
@onready var sprite: AnimatedSprite2D = $Sprite2D

signal player_collision(player_speeds: Dictionary)

func reset_player(intial_position: Vector2) -> void:
	# TODO: Need to set all physics back to defauls!!!
	line.clear_points()
	pinjoint.node_b = NodePath("")
	body_entered.connect(_on_body_entered)
	global_position = intial_position
	global_rotation = 0
	Globals.player_data[Globals.PLAYER_1_ID] = Globals.PlayerData.new()

func _process(delta: float) -> void:
	if Globals.player_data[player_id].health < Globals.MAX_PLAYER_HEALTH*0.75:
		sprite.play("75_health")
	elif Globals.player_data[player_id].health < Globals.MAX_PLAYER_HEALTH*0.5:
		sprite.play("50_health")
	elif Globals.player_data[player_id].health < Globals.MAX_PLAYER_HEALTH*0.25:
		sprite.play("25_health")
	elif Globals.player_data[player_id].health <=0:
		sprite.play("death")
	else:
		sprite.play("100_health")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Players"):
		player_collision.emit({
			player_id: linear_velocity.length(),
			body.player_id: body.linear_velocity.length(),
		})
