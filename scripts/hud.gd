extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_tree().get_nodes_in_group("player")[0]
	player.connect("on_health_changed", Callable(self, "update_health_bar"))
	
	var main = get_tree().get_nodes_in_group("main")[0]
	main.connect("on_score_updated", Callable(self, "update_score_board"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func update_score_board(score):
	$ScoreLabel.text = str(score)
	
func update_health_bar(value):
	$HealthBar.value = value
	if value > 40:
		$HealthBar.modulate = Color("4afc00")
	else:
		$HealthBar.modulate = Color("ff0400")
