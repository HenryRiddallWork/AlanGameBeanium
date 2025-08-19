extends Node2D

# player state
const PLAYER_1_ID = "1"
const PLAYER_2_ID = "2"

const MAX_PLAYER_HEALTH = 200

class PlayerData:
	var health: int = MAX_PLAYER_HEALTH

var player_data: Dictionary = {
	PLAYER_1_ID: PlayerData.new(),
	PLAYER_2_ID: PlayerData.new(),
}

# counters
var time_elapsed: float = 0

var winner = ""

var player_1_wins = 0
var player_2_wins = 0
