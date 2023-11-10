extends Area2D

@export var point_value: int = 50

signal on_coin_collected

func _on_body_entered(body):
	$AudioStreamPlayer2D.play()
	on_coin_collected.emit(point_value, position)
	$Sprite2D.hide()
	await $AudioStreamPlayer2D.finished
	queue_free()
