extends Node

@export var enemy_spawn_timer: float
@export var coin_spawn_timer: float 
@export var spawn_distance_from_ceiling: float
@export var max_num_enemies_per_spawn: int
@export var is_spawn_enemies: bool

@export var enemy_scene: PackedScene
@export var coin_scene: PackedScene
@export var score_popup_scene: PackedScene
@export var coin_collected_effect_scene: PackedScene

var time_since_enemy_spawn = 0
var num_enemies_per_spawn = 2
var time_since_coin_spawn = 0
var score: int = 0
var high_score: int = 0
var is_game_over = false

signal on_score_updated

# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_tree().get_nodes_in_group("player")[0]
	player.connect("on_died", Callable(self, "game_over"))
	
	var killzone = get_tree().get_nodes_in_group("killzone")[0]
	killzone.connect("on_player_killed_by_zone", Callable(self, "game_over"))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_game_over:
		if is_spawn_enemies:
			spawn_enemies(delta)
		spawn_coins(delta)
		listen_for_score_updates()
		
func game_over():
	is_game_over = true
	# Remove enemies
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		enemy.queue_free()
	
	# Remove coins
	var coins = get_tree().get_nodes_in_group("coin")
	for coin in coins:
		coin.queue_free()
	
	save_game()

	$GameOverSound.play()
	await $GameOverSound.finished
	
	get_tree().change_scene_to_file('res://scenes/menu.tscn')

func spawn_enemies(delta):
	if time_since_enemy_spawn > enemy_spawn_timer:
		for i in range(0, num_enemies_per_spawn):
			var enemy_instance = enemy_scene.instantiate()
			enemy_instance.position = Vector2(randf_range(0, get_viewport().get_visible_rect().size.x), randf_range(0, spawn_distance_from_ceiling))
			get_parent().add_child(enemy_instance)
		
		time_since_enemy_spawn = 0
		max_num_enemies_per_spawn = clamp(num_enemies_per_spawn + 1, 0, max_num_enemies_per_spawn)
	else:
		time_since_enemy_spawn += delta
		
func spawn_coins(delta):
	if time_since_coin_spawn > coin_spawn_timer:
		var coin_instance = coin_scene.instantiate()
		coin_instance.position = Vector2(randf_range(100, get_viewport().get_visible_rect().size.x - 100), randf_range(450, 750)) # This is jank but whatever
		get_parent().add_child(coin_instance)
		time_since_coin_spawn = 0
	else:
		time_since_coin_spawn += delta

func listen_for_score_updates():
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if !enemy.is_connected("on_enemy_killed", Callable(self, "update_score")):
			enemy.connect("on_enemy_killed", Callable(self, "update_score"))
		
	var coins = get_tree().get_nodes_in_group("coin")
	for coin in coins:
		if !coin.is_connected("on_coin_collected", Callable(self, "handle_coin_collected")):
			coin.connect("on_coin_collected", Callable(self, "handle_coin_collected"))

func handle_coin_collected(value, position):
	update_score(value, position)
	var coin_collected_effect_instance = coin_collected_effect_scene.instantiate()
	coin_collected_effect_instance.position = position
	get_parent().add_child(coin_collected_effect_instance)

func update_score(value, position):
	score += value
	on_score_updated.emit(score)
	
	var score_popup_instance = score_popup_scene.instantiate()
	get_parent().add_child(score_popup_instance)
	score_popup_instance.start(value, position)

func save_game():
	load_game()
	if score > high_score:
		high_score = score
	
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var json_string = "{\"last_score\":" + str(score) + ", \"high_score\":" + str(high_score) + "}"
	save_game.store_line(json_string)
	
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
		
		if node_data.has("high_score"):
			high_score = node_data["high_score"]
