extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	load_game()

func _on_play_button_pressed():
	get_tree().change_scene_to_file('res://scenes/main.tscn')

func _on_quit_button_pressed():
	get_tree().quit()
	
func update_last_score(score):
	$LastScore.text = "LAST SCORE: " + str(score)
	
func update_high_score(score):
	$HighScore.text = "HIGH SCORE: " + str(score)
	
func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return

	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		var node_data = json.get_data()
		
		update_last_score(node_data["last_score"])
		
		if node_data.has("high_score"):
			update_high_score(node_data["high_score"])
	
