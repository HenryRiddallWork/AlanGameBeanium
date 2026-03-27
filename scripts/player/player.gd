class_name Player extends RigidBody2D

const COLLISION_SCREEN_SHAKE_SCALE_FACTOR = 0.02

@export var wall_hit_particle_color: Color
@export var player_hit_particle_color: Color
@export var flame_material: ParticleProcessMaterial
@export var hook: StaticBody2D
@export var pinjoint: PinJoint2D
@export var speed: int = 15
@export var swing_speed: int = 10
@export var hook_range: int = 1000

@export var particle_scene: PackedScene
@export var impact_particle_amount_scale = 0.1
@export var impact_particle_speed_scale = 0.05
@export var impact_particle_lifetime_scale = 0.001
@export var max_particle_speed = 2000.0
@export var max_particle_lifetime = 0.5
@export var effect_threshold = 50
@export var konk_sound_scaler = 0.01

# If changing this enum, also change the player IDs in globals
@export_enum("1", "2") var player_id: String

@export var raycast_count: int = 31
# The factor by which the hook selection will prefer central angles to outside options
@export var hook_selection_factor: float = 2
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var line = $Line2D
@onready var line_end = hook.get_node("Marker2D")
@onready var direction_hook: Sprite2D = $DirectionHook
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var collision_point: Vector2 = Vector2(0, 0)

@onready var speed_bar: TextureProgressBar = $CanvasLayer/SpeedBar1 if player_id == Globals.PLAYER_1_ID else $CanvasLayer/SpeedBar2
@onready var state: StateMachine = $State
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var flame_emitter:GPUParticles2D = $GPUParticles2D

var shake_magnitude: float = 0.5
var shake_duration: float = 0.5
var shake_frequency: float = 30.0  # times per second
var speed_shaking: bool = false
var time_elapsed: float = 0.0
var original_position: Vector2

var prev_velocity: Vector2 = Vector2.ZERO

signal player_collision(player_speeds: Dictionary)

func _ready() -> void:
	original_position = speed_bar.global_position
	Globals.player_data[player_id] = Globals.PlayerData.new()
	line.clear_points()
	pinjoint.node_b = NodePath("")
	speed_bar.show()
	body_entered.connect(_on_body_entered)
	flame_emitter.process_material = flame_material

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
	
	if speed_shaking:
		time_elapsed += delta
		if time_elapsed >= shake_duration:
			speed_shaking = false
			speed_bar.global_position = original_position
		else:
			var progress = time_elapsed / shake_duration
			var dampening = 1.0 - progress  # optional: smooth fade out
			var offset = Vector2(
				randf_range(-1, 1),
				randf_range(-1, 1)
			) * shake_magnitude * dampening
			speed_bar.global_position = original_position + offset

func _physics_process(delta: float) -> void:
	speed_bar.value = linear_velocity.length()
	
	if (linear_velocity.length() >= speed_bar.max_value):
			shake_duration = 0.5
			shake_magnitude = 2
			time_elapsed = 0.0
			speed_shaking = true
	
	if linear_velocity.length() < 400:
		flame_emitter.amount_ratio = 0
	else:
		flame_emitter.amount_ratio = linear_velocity.length() * linear_velocity.length()

func _on_body_entered(body: Node) -> void:
	var player_velocity = linear_velocity.length()
	speed_bar.value = player_velocity
	
	if player_velocity != null && player_velocity > effect_threshold:
		$AudioStreamPlayer2D.volume_db = player_velocity * konk_sound_scaler
		$AudioStreamPlayer2D.pitch_scale = 1 / (player_velocity * konk_sound_scaler) 
		$AudioStreamPlayer2D.play()
		var new_amount = clamp(int(player_velocity * impact_particle_amount_scale), 5, 200)
		var base_speed = clamp(player_velocity * impact_particle_speed_scale, 200, max_particle_speed)
		var initial_velocity_min = base_speed * 0.8
		var initial_velocity_max = base_speed * 1.2
		var new_lifetime = clamp(player_velocity * impact_particle_lifetime_scale, 0.2, max_particle_lifetime)
		var particles: GPUParticles2D = particle_scene.instantiate()
		particles.position = collision_point
		var mat: ParticleProcessMaterial = particles.process_material
		particles.amount = new_amount
		mat.initial_velocity_min = initial_velocity_min
		mat.initial_velocity_max = initial_velocity_max
		particles.lifetime = new_lifetime
		
		particles.one_shot = true
		particles.emitting = true
		
		if !body.is_in_group("Players"):
			$"../Camera2D".shake(0.5, player_velocity * COLLISION_SCREEN_SHAKE_SCALE_FACTOR)
			particles.process_material.color = wall_hit_particle_color
		else:
			particles.process_material.color = player_hit_particle_color
		
		get_tree().current_scene.add_child(particles)
		
		var cleanup_time = particles.lifetime + 0.5
		get_tree().create_timer(cleanup_time).connect("timeout", Callable(particles, "queue_free"))	

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if state.get_contact_count() >= 0:
		var point = state.get_contact_local_position(0)
		collision_point = point
		
		var has_contacted_player = false
		for i in state.get_contact_count():
			var body = state.get_contact_collider_object(i)
			if body != null && body.is_in_group("Players") && (prev_velocity.length() + body.linear_velocity.length()) > effect_threshold:
				has_contacted_player = true
				if player_id == "1":
					var collision_normal = state.get_contact_local_normal(i)
					player_collision.emit({
						"player_1_velocity": prev_velocity,
						"player_2_velocity": (body as Player).prev_velocity,
						"collision_normal": collision_normal,
					})
		if !has_contacted_player:
			prev_velocity = linear_velocity
	else:
		prev_velocity = linear_velocity


func unhook():
	state._transition_to_next_state(PlayerState.IN_AIR)

func play_damage_animation():
	animation_player.play("damage_player")
