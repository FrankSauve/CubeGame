extends Node

@export var spawntimer: float = 1
@export var spawn_distance_from_ceiling = 400
@export var max_num_emenies_per_spawn = 3

var time_since_spawn = 0
var num_emenies_per_spawn = 2

const enemyPath = preload('res://scenes/Enemy.tscn')

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if time_since_spawn > spawntimer:
		for i in range(0, num_emenies_per_spawn):
			var enemy = enemyPath.instantiate()
			enemy.position = Vector2(randf_range(0, get_viewport().get_visible_rect().size.x), randf_range(0, spawn_distance_from_ceiling))
			get_parent().add_child(enemy)
		
		time_since_spawn = 0
		num_emenies_per_spawn = clamp(num_emenies_per_spawn + 1, 0, max_num_emenies_per_spawn)
	else:
		time_since_spawn += delta
		
