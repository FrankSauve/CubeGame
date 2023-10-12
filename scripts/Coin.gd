extends Area2D

@export var point_value: int = 50

signal on_coin_collected

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	on_coin_collected.emit(point_value)
	queue_free()
