class_name Player extends RigidBody2D

const COLLISION_SCREEN_SHAKE_SCALE_FACTOR = 0.02

@export var hook: StaticBody2D
@export var pinjoint: PinJoint2D
@export var speed: int = 15
@export var swing_speed: int = 10
@export var hook_range: int = 1000
@export var raycast_count: int = 30
@export var particle_scene: PackedScene
@export var amount_scale = 0.1
@export var speed_scale = 0.05
@export var lifetime_scale = 0.001
@export var max_particle_speed = 2000.0
@export var max_lifetime = 0.5
@export var effect_threshold = 50
@export var konk_sound_scaler = 0.01

# If changing this enum, also change the player IDs in globals
@export_enum("1", "2") var player_id: String

# The factor by which the hook selection will prefer central angles to outside options
@export var hook_selection_factor: float = 1.5

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var line = $Line2D
@onready var line_end = hook.get_node("Marker2D")
@onready var direction_hook: Sprite2D = $DirectionHook
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var collision_point: Vector2 = Vector2(0, 0)
@onready var label: Label = $Label

signal player_collision(player_speeds: Dictionary)

func _ready() -> void:
	Globals.player_data[player_id] = Globals.PlayerData.new()
	line.clear_points()
	pinjoint.node_b = NodePath("")
	body_entered.connect(_on_body_entered)
	if (player_id == "1"):
		label.text = "1"
		label.add_theme_color_override("font_color", Color.DARK_RED)
	else:
		label.text = "2"
		label.add_theme_color_override("font_color", Color.CADET_BLUE)

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

func _physics_process(delta: float) -> void:
	$Label.text = str(linear_velocity.length()).get_slice(".", 0) + " m/s"

func _on_body_entered(body: Node) -> void:
	var player_velocity = linear_velocity.length()
	$Label.text = str(player_velocity) + " m/s"
	if body.is_in_group("Players"):
		player_collision.emit({
			player_id: player_velocity,
			body.player_id: body.linear_velocity.length(),
		})
	else:
		$"../Camera2D".shake(0.5, player_velocity * COLLISION_SCREEN_SHAKE_SCALE_FACTOR)
	
	if player_velocity > effect_threshold:
		$AudioStreamPlayer2D.volume_linear = player_velocity * konk_sound_scaler
		$AudioStreamPlayer2D.pitch_scale = 1 / (player_velocity * konk_sound_scaler) 
		$AudioStreamPlayer2D.play()
		var new_amount = clamp(int(player_velocity * amount_scale), 5, 200)
		var base_speed = clamp(player_velocity * speed_scale, 200, max_particle_speed)
		var initial_velocity_min = base_speed * 0.8
		var initial_velocity_max = base_speed * 1.2
		var new_lifetime = clamp(player_velocity * lifetime_scale, 0.2, max_lifetime)
		var particles: GPUParticles2D = particle_scene.instantiate()
		particles.position = collision_point
		var mat: ParticleProcessMaterial = particles.process_material
		particles.amount = new_amount
		mat.initial_velocity_min = initial_velocity_min
		mat.initial_velocity_max = initial_velocity_max
		particles.lifetime = new_lifetime
		
		particles.one_shot = true
		particles.emitting = true
		get_tree().current_scene.add_child(particles)
		
		var cleanup_time = particles.lifetime + 0.5
		get_tree().create_timer(cleanup_time).connect("timeout", Callable(particles, "queue_free"))	

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if state.get_contact_count() == 0:
		return

	var point = state.get_contact_local_position(0)
	collision_point = point
