extends Control

func set_winner_text(new_text: String):
	$konk2.frame = 0
	$konk2.play()
	$WinnerText.text = new_text
	$AudioStreamPlayer2D.play()
	$Player1Score.text = str(Globals.player_1_wins)
	$Player2Score.text = str(Globals.player_2_wins)
