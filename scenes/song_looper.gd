extends AudioStreamPlayer2D

func _ready():
	connect("finished", Callable(self, "_on_finished"))
	play()

func _on_finished():
	play()  # restart when finished
