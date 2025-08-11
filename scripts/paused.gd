extends Node2D

@onready var resumeButton: Button = $ResumeButton


func _ready():
	Globals.pause_game.connect(paused)
	resumeButton.pressed.connect(_resume_game)

func paused():
	visible = true
	
func _resume_game():
	Globals.resume()
	visible = false
