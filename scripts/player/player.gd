class_name Player extends RigidBody2D

@export var hook: StaticBody2D
@export var pinjoint: PinJoint2D
@export var speed: int = 10
@export var swing_speed: int = 5
@export var hook_range: int = 1000
@export var raycast_count: int = 30
@export var particle_scene: PackedScene
@export var velocity_multiplier = 0.3
@export var speed_scale = 0.05
@export var lifetime_scale = 0.005
@export var max_particle_speed = 1000.0
@export var max_lifetime = 2.0

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

signal player_collision(player_speeds: Dictionary)

func _ready() -> void:
	Globals.player_data[player_id] = Globals.PlayerData.new()
	line.clear_points()
	pinjoint.node_b = NodePath("")
	body_entered.connect(_on_body_entered)

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
		
	var player_velocity = linear_velocity.length()
	var new_amount = clamp(int(player_velocity * velocity_multiplier), 5, 200)
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
	var point = state.get_contact_local_position(0)
	collision_point = point
