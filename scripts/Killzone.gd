extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func _on_body_entered(body):
	var nodes = get_tree().get_nodes_in_group("enemy")
	for node in nodes:
		node.queue_free()
	get_tree().reload_current_scene()
