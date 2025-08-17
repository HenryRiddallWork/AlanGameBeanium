class_name Game extends Node

@onready var start_screen: StartScreen = $StartLayer/Start
@onready var ui_layer: Control = $UiLayer/Ui
@onready var paused_layer: PauseLayer = $PausedLayer/Paused
@onready var end_screen: Node2D = $EndGameLayer/EndScene

@onready var player_1: Player = $Player1
@onready var player_2: Player = $Player2
@onready var game_boundary: Area2D = $GameBoundary
