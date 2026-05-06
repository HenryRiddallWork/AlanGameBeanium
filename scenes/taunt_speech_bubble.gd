extends NinePatchRect

@export var taunts: Array[Taunt]

@onready var label = $MarginContainer/Label
@onready var sound_player = $AudioStreamPlayer2D

var is_taunting = false

var player: Player

func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null)
	sound_player.finished.connect(on_taunt_finished)

func set_text(text: String):
	label.text = text
	await get_tree().process_frame
	custom_minimum_size = label.get_combined_minimum_size() + Vector2(12, 12)

func _process(delta: float) -> void:
	global_position = $"../..".global_position + Vector2(0, -custom_minimum_size.y) + Vector2(5, -60)


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("taunt_"+player.player_id) and !is_taunting:
		var taunt = taunts.pick_random()
		is_taunting = true
		visible = true
		set_text(taunt.text)
		sound_player.pitch_scale = randf_range(0.6, 2)
		sound_player.stream = taunt.sound
		sound_player.play(0)
	
func on_taunt_finished() -> void:
	visible = false
	await get_tree().create_timer(0.5).timeout
	is_taunting = false
	
		
