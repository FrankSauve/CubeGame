extends CharacterBody2D

@export var speed: float = 300

func _physics_process(delta):
	var player = get_player()
	if player is CharacterBody2D:
		velocity = player.position - position
		move_and_collide(velocity.normalized() * speed * delta)

func _on_hitbox_body_entered(body):
	if body.get_collision_layer_value(2): # Bullet
		queue_free()
	elif body.get_collision_layer_value(3): # Player
		# Destroy all enemies and restart level
		var nodes = get_tree().get_nodes_in_group("enemy")
		for node in nodes:
			node.queue_free()

		get_tree().reload_current_scene()

func get_player():
	var nodes = get_tree().get_nodes_in_group("player")
	if len(nodes) > 0:
		return nodes[0]
	push_error("The player is missing...")
