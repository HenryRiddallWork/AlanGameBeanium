extends Camera2D

@export var shake_magnitude: float = 0.5
@export var shake_duration: float = 0.5
@export var shake_frequency: float = 30.0  # times per second

var _shaking: bool = false
var _time_elapsed: float = 0.0
var _original_position: Vector2

func _ready():
	_original_position = global_position

func shake(duration: float = 0.5, magnitude: float = 0.5):
	shake_duration = duration
	shake_magnitude = magnitude
	_time_elapsed = 0.0
	_shaking = true

func _process(delta: float) -> void:
	if _shaking:
		_time_elapsed += delta
		if _time_elapsed >= shake_duration:
			_shaking = false
			global_position = _original_position
		else:
			var progress = _time_elapsed / shake_duration
			var dampening = 1.0 - progress  # optional: smooth fade out
			var offset = Vector2(
				randf_range(-1, 1),
				randf_range(-1, 1)
			) * shake_magnitude * dampening
			global_position = _original_position + offset
