class_name StartScreen extends Control

signal start_game_triggered

func _start_game():
	start_game_triggered.emit()
