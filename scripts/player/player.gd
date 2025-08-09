class_name Player extends RigidBody2D

@export var hook: StaticBody2D
@export var pinjoint : PinJoint2D
@export var speed = 5
@export var swing_speed = 3
@export var hook_range = 500
@export var raycast_count = 10

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var line = $Line2D
@onready var line_end = hook.get_node("Marker2D")
@onready var direction_hook: Sprite2D = $DirectionHook


func _ready() -> void:
	direction_hook.visible = false
	line.clear_points()
	pinjoint.node_b = NodePath("")


func _physics_process(delta: float) -> void:
	if Globals.gamestate != Globals.GAMESTATES.PLAYING:
		get_tree().paused = true
		return
	if Input.is_action_just_pressed("Paused"):
		Globals.pause()
