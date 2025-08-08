extends RigidBody2D

var hooked: bool = false
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var speed = 5
@export var hook: StaticBody2D
@export var pinjoint : PinJoint2D
@onready var line = $Line2D
@onready var line_end = hook.get_node("Marker2D")
@onready var directionHook: Sprite2D = $DirectionHook
@onready var player: RigidBody2D = $"."

func _physics_process(delta: float) -> void:
	if Globals.gamestate != Globals.GAMESTATES.PLAYING:
		get_tree().paused = true
		return
	if Input.is_action_just_pressed("Paused"):
		Globals.pause()
	
	var joystickRotation: float = _get_joystick_direction()

	if Input.is_action_just_pressed("shoot") and not hooked:
		ray_cast_2d.target_position = to_local(global_position + (Vector2.from_angle(joystickRotation - (PI / 2)) * 300))
		ray_cast_2d.force_raycast_update()
		if ray_cast_2d.is_colliding():

			#get values from raycast
			var hook_pos = ray_cast_2d.get_collision_point()
			var collider = ray_cast_2d.get_collider()
			
			#if the ray collides with a hookable object, move pinjoint and hook to it
			if collider.is_in_group("Hookable"):
				hooked = true
				pinjoint.global_position = hook_pos
				hook.global_position = hook_pos
				pinjoint.node_b = get_path_to(hook)
				#rotate the hook so it is the right angle
				var direction = hook_pos - global_position
				hook.rotation = direction.angle()
	elif Input.is_action_just_released("shoot") and hooked:
		hooked = false
		pinjoint.node_b = NodePath("")
	
	if hooked:
		line.clear_points()
		line.add_point(Vector2.ZERO)
		line.add_point(to_local(line_end.global_position))
		directionHook.visible = false
	else:
		line.clear_points()
		directionHook.visible = _is_joystick_in_use()
		directionHook.global_rotation = joystickRotation
		
	var grounded = get_contact_count()>0
	
	#basic platformer code below
	if Input.is_action_pressed("right") and (grounded or hooked):
		apply_central_impulse(Vector2.RIGHT * speed)
	if Input.is_action_pressed("left") and (grounded or hooked):
		apply_central_impulse(Vector2.LEFT * speed)
	if Input.is_action_just_pressed("jump") and grounded:
		apply_central_impulse(Vector2.UP * 100)

func _get_joystick_direction() -> float:
	# NE
	if Input.is_action_pressed("up") and Input.is_action_pressed("right"):
		return PI / 4
	# SE
	elif Input.is_action_pressed("down") and Input.is_action_pressed("right"):
		return 3 * PI / 4
	# SW
	elif Input.is_action_pressed("down") and Input.is_action_pressed("left"):
		return 5 * PI / 4
	# NW
	elif Input.is_action_pressed("up") and Input.is_action_pressed("left"):
		return 7 * PI / 4
	# E
	elif Input.is_action_pressed("right"):
		return PI / 2
	# S
	elif Input.is_action_pressed("down"):
		return PI
	# W
	elif Input.is_action_pressed("left"):
		return 3 * PI / 2
	# N
	else:
		return 0
		
func _is_joystick_in_use() -> bool:
	return Input.is_action_pressed("up") or Input.is_action_pressed("right") or Input.is_action_pressed("down") or Input.is_action_pressed("left")
