extends CharacterBody2D

@export var speed: float = 300
@export var damage_to_player = -25
@export var point_value = 10
@export var kill_effect_scene: PackedScene
@export var score_popup_scene: PackedScene

signal on_enemy_killed
signal on_damage_player

func _physics_process(delta):
	var player = get_player()
	if player is CharacterBody2D:
		velocity = player.position - position
		move_and_collide(velocity.normalized() * speed * delta)

func _on_hitbox_body_entered(body):
	if body.get_collision_layer_value(2): # Bullet
		kill()
	elif body.get_collision_layer_value(3): # Player
		if !get_player().is_dashing:
			damage_player()
		else:
			kill()

func get_player():
	var nodes = get_tree().get_nodes_in_group("player")
	if len(nodes) > 0:
		return nodes[0]
	push_error("The player is missing...")

func kill():
	var score_popup_instance = score_popup_scene.instantiate()
	get_parent().add_child(score_popup_instance)
	score_popup_instance.start(point_value, position)
	
	var kill_effect_instance = kill_effect_scene.instantiate()
	kill_effect_instance.position = position
	get_tree().root.get_child(0).add_child(kill_effect_instance)
	
	queue_free()
	on_enemy_killed.emit(point_value, position)
	
func damage_player():
	on_damage_player.emit(damage_to_player)
	queue_free()
